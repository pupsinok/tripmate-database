-- TripMate: хранимые функции (PL/pgSQL)

-- 1. Средняя оценка пользователя (скалярная)
CREATE OR REPLACE FUNCTION get_user_avg_rating(user_id INT)
RETURNS NUMERIC(3,2) AS $$
DECLARE
    avg_rating NUMERIC(3,2);
BEGIN
    SELECT ROUND(AVG(rating), 2)
    INTO avg_rating
    FROM reviews
    WHERE target_user_id = user_id;
    RETURN COALESCE(avg_rating, 0.00);
END;
$$ LANGUAGE plpgsql;

-- 2. Туры, соответствующие предпочтениям пользователя (табличная)
CREATE OR REPLACE FUNCTION get_trips_by_preference(uid INT)
RETURNS TABLE (
    trip_id INT,
    trip_title VARCHAR,
    travel_type VARCHAR,
    budget NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.trip_id, t.trip_title, t.travel_type, t.budget
    FROM trips t
    WHERE t.travel_type IN (
        SELECT preference
        FROM userpreferences
        WHERE user_id = uid
    );
END;
$$ LANGUAGE plpgsql;

-- 3. Участники тура и статус их заявок (табличная)
CREATE OR REPLACE FUNCTION get_trip_participants(tid INT)
RETURNS TABLE (
    user_id INT,
    user_name VARCHAR,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.user_id, u.name, tr.status
    FROM trip_requests tr
    JOIN users u ON u.user_id = tr.user_id
    WHERE tr.trip_id = tid;
END;
$$ LANGUAGE plpgsql;

-- 4. Количество активных туров автора (скалярная)
CREATE OR REPLACE FUNCTION get_active_trip_count_by_user(uid INT)
RETURNS INT AS $$
DECLARE
    count_trips INT;
BEGIN
    SELECT COUNT(*)
    INTO count_trips
    FROM trips
    WHERE author_id = uid
      AND end_date >= CURRENT_DATE;
    RETURN count_trips;
END;
$$ LANGUAGE plpgsql;

-- 5. Переписка пользователя (табличная)
CREATE OR REPLACE FUNCTION get_user_messages(uid INT)
RETURNS TABLE (
    sender_id INT,
    receiver_id INT,
    message_text TEXT,
    send_date TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT sender_id, receiver_id, message_text, send_date
    FROM messages
    WHERE sender_id = uid OR receiver_id = uid
    ORDER BY send_date DESC;
END;
$$ LANGUAGE plpgsql;

-- 6. Средняя оценка тура (скалярная)
CREATE OR REPLACE FUNCTION get_trip_rating(tid INT)
RETURNS NUMERIC(3,2) AS $$
DECLARE
    avg_rating NUMERIC(3,2);
BEGIN
    SELECT ROUND(AVG(rating), 2)
    INTO avg_rating
    FROM reviews
    WHERE trip_id = tid;
    RETURN COALESCE(avg_rating, 0.00);
END;
$$ LANGUAGE plpgsql;

-- 7. Сохранённые туры пользователя (табличная)
CREATE OR REPLACE FUNCTION get_user_saved_trips(uid INT)
RETURNS TABLE (
    trip_id INT,
    trip_title VARCHAR,
    saved_date TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.trip_id, t.trip_title, st.saved_date
    FROM saved_trips st
    JOIN trips t ON t.trip_id = st.trip_id
    WHERE st.user_id = uid
    ORDER BY st.saved_date DESC;
END;
$$ LANGUAGE plpgsql;

-- 8. Топ типов путешествий по количеству туров (табличная)
CREATE OR REPLACE FUNCTION get_top_travel_types()
RETURNS TABLE (
    travel_type VARCHAR,
    total_trips INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT travel_type, COUNT(*) AS total_trips
    FROM trips
    GROUP BY travel_type
    ORDER BY total_trips DESC;
END;
$$ LANGUAGE plpgsql;
