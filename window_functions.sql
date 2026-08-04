-- TripMate: аналитические запросы с оконными функциями

-- 1. Средний рейтинг каждого тура с количеством отзывов
SELECT
    trip_id,
    trip_title,
    COUNT(r.review_id) OVER (PARTITION BY t.trip_id) AS review_count,
    ROUND(AVG(r.rating) OVER (PARTITION BY t.trip_id), 2) AS avg_rating
FROM trips t
LEFT JOIN reviews r ON t.trip_id = r.trip_id
GROUP BY t.trip_id, t.trip_title, r.review_id, r.rating
ORDER BY avg_rating DESC NULLS LAST;

-- 2. Рейтинг пользователей с ранжированием (RANK)
SELECT
    user_id,
    name,
    surname,
    avg_rating,
    RANK() OVER (ORDER BY avg_rating DESC NULLS LAST) AS rating_rank
FROM users
WHERE avg_rating IS NOT NULL
ORDER BY rating_rank;

-- 3. Последние 3 сообщения каждого отправителя (ROW_NUMBER)
SELECT *
FROM (
    SELECT
        message_id,
        sender_id,
        receiver_id,
        message_text,
        send_date,
        ROW_NUMBER() OVER (PARTITION BY sender_id ORDER BY send_date DESC) AS msg_rank
    FROM messages
) ranked
WHERE msg_rank <= 3;

-- 4. Кумулятивный бюджет по турам каждого автора (SUM OVER)
SELECT
    author_id,
    trip_id,
    trip_title,
    budget,
    SUM(budget) OVER (PARTITION BY author_id ORDER BY trip_id) AS cumulative_budget
FROM trips
ORDER BY author_id, trip_id;

-- 5. Скользящее среднее рейтинга пользователей по городам
SELECT DISTINCT
    city,
    AVG(avg_rating) OVER (
        PARTITION BY city
        ORDER BY registration_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS moving_avg_rating
FROM users
WHERE avg_rating IS NOT NULL
ORDER BY city;
