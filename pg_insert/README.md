# create and insert data into mock table in source database

## requirement

* create table and load mock data in source database to test the replication
  program - `pgx_replicate`

* `pgx_replicate` uses the table primary key that is a unique sequence number
   to bread the table into batches

* these batches are to be inserted into the destination database using go routines

## build instructions

* first create the binary

```
mv pgx_insert.go main.go
go mod init pgx_insert
go mod tidy

go build
./pgx_insert
```

## create table on source database and load data

* all the steps in this README can be done by running following shell script

```
./run-this-to-create-and-load-source-table.sh
```

* create database tables - books and books2 (books will replicate into books2)

```
cat > create-books.sql<<EOF
DROP SEQUENCE books_sequence;
DROP TABLE books;
CREATE TABLE books (id SERIAL PRIMARY KEY, title VARCHAR(100) UNIQUE NOT NULL, primary_author VARCHAR(100) UNIQUE NOT NULL);
CREATE SEQUENCE books_sequence start 1 increment 1;
EOF

cat > create-books-2.sql<<EOF
DROP SEQUENCE books_sequence2;
DROP TABLE books2;
CREATE TABLE books2 (id SERIAL PRIMARY KEY, title VARCHAR(100) UNIQUE NOT NULL, primary_author VARCHAR(100) UNIQUE NOT NULL);
CREATE SEQUENCE books_sequence2 start 1 increment 1;
EOF

psql -h 127.0.0.83 -d testdb -U testdb_owner -f create-books.sql
psql -h 127.0.0.83 -d testdb -U testdb_owner -f create-books-2.sql
```

* use env variable

```
SRC_DB_URL=postgres://testdb_owner:welcome@127.0.0.83:5432/testdb?sslmode=disable
DST_DB_URL=postgres://testdb_owner:welcome@127.0.0.12:5432/testdb?sslmode=disable
```

* insert large amounts of data

```
for s in $(seq 1 1000000); do
  ./pgx_insert "a$s" "t$s"
done
```
