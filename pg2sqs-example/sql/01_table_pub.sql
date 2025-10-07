CREATE TABLE users (
     id SERIAL PRIMARY KEY,
     email TEXT NOT NULL UNIQUE,
     created_at TIMESTAMP DEFAULT now()
);
CREATE PUBLICATION users_pub FOR TABLE users;