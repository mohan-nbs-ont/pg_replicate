# Replicate a table between source and destination databases

* Source table should have a unique sequence id (int) value that can be used to replicate
  data to a destination database/table.
* Batches of data is extracted from the source database and inserted into
  destination database
* Uses go routines per batch so they are independent of each other

* Details:

`RFC_2021_01_04_Copy_large_tables_from_billing_database`

## To build

```
go mod init pg_replicate
go mod tidy

go fmt
CGO_ENABLED=0 go build -trimpath -ldflags "-s -w"
```

## Setup

* Create and export environment variable for the database
* Used by the application

```
SRC_DB_URL=postgres://testdb_owner:welcome@127.0.0.83:5432/testdb?sslmode=disable
DST_DB_URL=postgres://testdb_owner:welcome@127.0.0.14:5432/testdb?sslmode=disable
export SRC_DB_URL
export DST_DB_URL
```

## Running

* Specify the source table/key and destination table/key

```
usage: ./pg_replicate src-table-to-replicate src-table-numeric-id dst-table-to-replicate dst-table-numeric-id

example:
./pg_replicate books id books id
```

* Details of table with unique key (sequence number)

```
DROP SEQUENCE books_sequence;
DROP TABLE books;
CREATE TABLE books (id SERIAL PRIMARY KEY, title VARCHAR(100) UNIQUE NOT NULL, primary_author VARCHAR(100) UNIQUE NOT NULL);
CREATE SEQUENCE books_sequence start 1 increment 1;
EOF
```

## References

<https://stackoverflow.com/questions/60348559/using-go-to-copy-from-one-postgres-db-to-another>
<https://pkg.go.dev/github.com/go-pg/pg>
<https://pkg.go.dev/github.com/go-pg/pg/v10#section-readme>
<https://pkg.go.dev/github.com/go-pg/pg/v10#Conn.CopyFrom>
<http://go-database-sql.org/errors.html>
<https://dev.to/0xarjunshetty/connecting-to-postgres-with-standard-sql-package-in-golang-hmh>
