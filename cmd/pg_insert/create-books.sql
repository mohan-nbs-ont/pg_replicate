DROP SEQUENCE books_sequence;
DROP TABLE books;
CREATE TABLE books (id SERIAL PRIMARY KEY, title VARCHAR(100) UNIQUE NOT NULL, primary_author VARCHAR(100) UNIQUE NOT NULL);
CREATE SEQUENCE books_sequence start 1 increment 1;
