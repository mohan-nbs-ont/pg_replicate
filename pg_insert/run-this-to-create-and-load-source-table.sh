#! /bin/bash
set -o pipefail
set -o errexit
set -o nounset

export PGPASSWORD=welcome

# create database tables - books - on SRC_DB and DST_DB
cat > create-books.sql<<EOF
DROP SEQUENCE books_sequence;
DROP TABLE books;
CREATE TABLE books (id SERIAL PRIMARY KEY, title VARCHAR(100) UNIQUE NOT NULL, primary_author VARCHAR(100) UNIQUE NOT NULL);
CREATE SEQUENCE books_sequence start 1 increment 1;
EOF

psql -h 127.0.0.83 -d testdb -U testdb_owner -f create-books.sql
psql -h 127.0.0.12 -d testdb -U testdb_owner -f create-books.sql

# create and export env variable - used by pgx_insert
SRC_DB_URL=postgres://testdb_owner:welcome@127.0.0.83:5432/testdb?sslmode=disable
DST_DB_URL=postgres://testdb_owner:welcome@127.0.0.12:5432/testdb?sslmode=disable
export SRC_DB_URL
export DST_DB_URL

# insert large amounts of data to the SRC_DB_URL (source database)
for s in $(seq 1 10000); do
  ./pgx_insert "a$s" "t$s"
done
