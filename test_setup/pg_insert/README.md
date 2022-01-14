# Create and insert data into table in source database for testing `pg_replicate`

## Requirement

* Create table(books) and load data into it in source database to test the
  replication program - `pg_replicate`

* `pg_replicate` uses the table primary key that is a unique sequence number
   to bread the table into batches

* These batches are to be inserted into the destination database using go routines

## Build instructions

* Create the binary

```
go mod init pg_insert
go mod tidy

go fmt
CGO_ENABLED=0 go build -trimpath -ldflags "-s -w"
```

## Create table on source/destination databases

* Create database table 'books'

```
cat > create-books.sql<<EOF
DROP SEQUENCE books_sequence;
DROP TABLE books;
CREATE TABLE books (id SERIAL PRIMARY KEY, title VARCHAR(100) UNIQUE NOT NULL, primary_author VARCHAR(100) UNIQUE NOT NULL);
CREATE SEQUENCE books_sequence start 1 increment 1;
EOF

export PGPASSWORD=welcome
psql -h 127.0.0.83 -d testdb -U testdb_owner -f create-books.sql
psql -h 127.0.0.14 -d testdb -U testdb_owner -f create-books.sql
```

* Create and export env variables used by the program to access the databases

```
SRC_DB_URL=postgres://testdb_owner:welcome@127.0.0.83:5432/testdb?sslmode=disable
DST_DB_URL=postgres://testdb_owner:welcome@127.0.0.12:5432/testdb?sslmode=disable
export SRC_DB_URL
export DST_DB_URL
```

* Insert data using the program into the source database

```
for s in $(seq 1 1000000); do
  ./pg_insert "a$s" "t$s"
done
```
