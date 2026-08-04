-- TripMate database schema
-- Платформа для поиска попутчиков и организации совместных путешествий

CREATE TABLE users (
    user_id            SERIAL PRIMARY KEY,
    name               VARCHAR(50) CHECK (name ~* '^[A-Za-zА-Яа-яЁё\-]{2,50}$'),
    surname            VARCHAR(50) CHECK (surname ~* '^[A-Za-zА-Яа-яЁё\-]{2,50}$'),
    gender             VARCHAR(10) CHECK (gender ~ '^(male|female|other|мужчина|женщина|другое)$'),
    age                INTEGER,
    city               VARCHAR(100),
    phone_number       VARCHAR(15) CHECK (phone_number ~ '^\+?[0-9]{10,15}$'),
    email              VARCHAR(255) CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    languages          TEXT,
    registration_date  TIMESTAMP,
    avg_rating         NUMERIC(3,2)
);

CREATE TABLE trips (
    trip_id       SERIAL PRIMARY KEY,
    trip_title    VARCHAR(255),
    start_date    DATE,
    end_date      DATE,
    countries     TEXT,
    cities        TEXT,
    budget        NUMERIC,
    travel_type   VARCHAR(50),
    author_id     INTEGER REFERENCES users(user_id)
);

CREATE TABLE trip_requests (
    request_id    SERIAL PRIMARY KEY,
    user_id       INTEGER REFERENCES users(user_id),
    trip_id       INTEGER REFERENCES trips(trip_id),
    status        VARCHAR(50),
    request_date  TIMESTAMP
);

CREATE TABLE saved_trips (
    saved_trip_id  SERIAL PRIMARY KEY,
    user_id        INTEGER REFERENCES users(user_id),
    trip_id        INTEGER REFERENCES trips(trip_id),
    saved_date     TIMESTAMP
);

CREATE TABLE reviews (
    review_id        SERIAL PRIMARY KEY,
    author_id        INTEGER REFERENCES users(user_id),
    target_user_id   INTEGER REFERENCES users(user_id),
    trip_id          INTEGER REFERENCES trips(trip_id),
    rating           INTEGER,
    comment          TEXT CHECK (comment ~* '^((?!дурак|тупой|идиот).)*$'),
    review_date      TIMESTAMP
);

CREATE TABLE userpreferences (
    preference_id  SERIAL PRIMARY KEY,
    user_id        INTEGER REFERENCES users(user_id),
    preference     VARCHAR(100) CHECK (preference ~* '^[A-Za-zА-Яа-яЁё\s]{2,100}$'),
    importance     INTEGER
);

CREATE TABLE messages (
    message_id     SERIAL PRIMARY KEY,
    sender_id      INTEGER REFERENCES users(user_id),
    receiver_id    INTEGER REFERENCES users(user_id),
    message_text   TEXT,
    send_date      TIMESTAMP
);

CREATE TABLE waypoints (
    waypoint_id  SERIAL PRIMARY KEY,
    name         VARCHAR(255),
    description  TEXT,
    latitude     DECIMAL,
    longitude    DECIMAL
);

CREATE TABLE trip_waypoints (
    trip_id       INTEGER REFERENCES trips(trip_id),
    waypoint_id   INTEGER REFERENCES waypoints(waypoint_id),
    order_number  INTEGER,
    PRIMARY KEY (trip_id, waypoint_id)
);
