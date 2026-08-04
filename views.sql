-- TripMate: представления (views)

-- 1. Профиль пользователя со средним рейтингом и числом сохранённых туров
CREATE OR REPLACE VIEW user_profiles_view AS
SELECT
    u.user_id,
    u.name,
    u.surname,
    u.gender,
    u.age,
    u.city,
    u.email,
    u.avg_rating,
    COUNT(s.saved_trip_id) AS saved_trips_count
FROM users u
LEFT JOIN saved_trips s ON u.user_id = s.user_id
GROUP BY u.user_id;

-- 2. Отзывы о турах с именами автора и адресата
CREATE OR REPLACE VIEW trip_reviews_view AS
SELECT
    r.review_id,
    t.trip_title,
    au.name AS author_name,
    tu.name AS target_user_name,
    r.rating,
    r.comment,
    r.review_date
FROM reviews r
JOIN users au ON r.author_id = au.user_id
JOIN users tu ON r.target_user_id = tu.user_id
JOIN trips t ON r.trip_id = t.trip_id;

-- 3. Популярные туры по числу сохранений
CREATE OR REPLACE VIEW popular_trips_view AS
SELECT
    t.trip_id,
    t.trip_title,
    t.countries,
    t.cities,
    t.budget,
    t.travel_type,
    u.name AS author_name,
    COUNT(s.saved_trip_id) AS total_saves
FROM trips t
JOIN users u ON t.author_id = u.user_id
LEFT JOIN saved_trips s ON t.trip_id = s.trip_id
GROUP BY t.trip_id, u.name
ORDER BY total_saves DESC;

-- 4. Ближайшие туры пользователя по поданным заявкам
CREATE OR REPLACE VIEW upcoming_user_trips_view AS
SELECT
    u.user_id,
    u.name,
    t.trip_title,
    t.start_date,
    t.end_date,
    tr.status
FROM trip_requests tr
JOIN users u ON tr.user_id = u.user_id
JOIN trips t ON tr.trip_id = t.trip_id
WHERE t.start_date >= CURRENT_DATE;

-- 5. Участники тура и статус их заявок
CREATE OR REPLACE VIEW trip_participants_view AS
SELECT
    t.trip_id,
    t.trip_title,
    u.user_id,
    u.name,
    tr.status
FROM trip_requests tr
JOIN trips t ON tr.trip_id = t.trip_id
JOIN users u ON tr.user_id = u.user_id;

-- 6. Предпочтения пользователей (для рекомендаций)
CREATE OR REPLACE VIEW user_preferences_view AS
SELECT
    u.user_id,
    u.name,
    up.preference,
    up.importance
FROM userpreferences up
JOIN users u ON up.user_id = u.user_id
ORDER BY u.user_id, up.importance DESC;

-- 7. Маршруты туров с точками на карте
CREATE OR REPLACE VIEW trip_waypoints_map_view AS
SELECT
    t.trip_id,
    t.trip_title,
    w.name AS waypoint_name,
    w.latitude,
    w.longitude,
    tw.order_number
FROM trips t
JOIN trip_waypoints tw ON t.trip_id = tw.trip_id
JOIN waypoints w ON tw.waypoint_id = w.waypoint_id
ORDER BY t.trip_id, tw.order_number;
