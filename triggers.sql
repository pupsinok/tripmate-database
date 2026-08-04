-- TripMate: триггеры

-- 1. Автоустановка даты регистрации пользователя
CREATE OR REPLACE FUNCTION set_registration_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.registration_date IS NULL THEN
        NEW.registration_date := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_registration_date
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION set_registration_date();

-- 2. Обновление среднего рейтинга пользователя при новом отзыве
CREATE OR REPLACE FUNCTION update_user_avg_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users
    SET avg_rating = (
        SELECT ROUND(AVG(rating), 2)
        FROM reviews
        WHERE target_user_id = NEW.target_user_id
    )
    WHERE user_id = NEW.target_user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_user_avg_rating
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_user_avg_rating();

-- 3. Статус заявки по умолчанию — "в рассмотрении"
CREATE OR REPLACE FUNCTION default_request_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IS NULL THEN
        NEW.status := 'в рассмотрении';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_default_request_status
BEFORE INSERT ON trip_requests
FOR EACH ROW
EXECUTE FUNCTION default_request_status();

-- 4. Удаление сохранённых туров при удалении пользователя
CREATE OR REPLACE FUNCTION delete_user_saved_trips()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM saved_trips WHERE user_id = OLD.user_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_delete_user_saved_trips
AFTER DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION delete_user_saved_trips();

-- 5. Проверка допустимого диапазона рейтинга (1–5)
CREATE OR REPLACE FUNCTION check_rating_range()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        RAISE EXCEPTION 'Рейтинг должен быть от 1 до 5';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_rating_range
BEFORE INSERT OR UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION check_rating_range();

-- 6. Удаление заявок при удалении тура
CREATE OR REPLACE FUNCTION delete_trip_requests_on_trip_delete()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM trip_requests WHERE trip_id = OLD.trip_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_delete_trip_requests
AFTER DELETE ON trips
FOR EACH ROW
EXECUTE FUNCTION delete_trip_requests_on_trip_delete();

-- 7. Минимальный возраст регистрации — 16 лет
CREATE OR REPLACE FUNCTION check_user_age()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.age < 16 THEN
        RAISE EXCEPTION 'Минимальный возраст для регистрации — 16 лет.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_user_age
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION check_user_age();

-- 8. Запрет повторного отзыва на один тур от одного автора
CREATE OR REPLACE FUNCTION prevent_duplicate_reviews()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM reviews
        WHERE author_id = NEW.author_id AND trip_id = NEW.trip_id
    ) THEN
        RAISE EXCEPTION 'Вы уже оставляли отзыв на этот тур.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_duplicate_reviews
BEFORE INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_reviews();
