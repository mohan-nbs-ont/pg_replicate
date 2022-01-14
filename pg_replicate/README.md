# Replicate table between src and dst tables using tx id(unique sequence)

* tables should have a unique sequence id (int) value that can be used to replicate
  tuples to another database/table.
* batches of data is extracted from the source database and inserted into
  destination database
* batches use go routines so they are independent of each other

* details are in

`RFC_2021_01_04_Copy_large_tables_from_billing_database`

```
mv pg_go_replicate.go main.go
go mod init pg_go_replicate
go mod tidy

go build
./pg_go_replicate
```

* use env variable

```
SRC_DB_URL=postgres://testdb_owner:welcome@127.0.0.83:5432/testdb?sslmode=disable
DST_DB_URL=postgres://testdb_owner:welcome@127.0.0.12:5432/testdb?sslmode=disable
export SRC_DB_URL
export DST_DB_URL
```

* run

```
usage: ./pg_go_replicate src-table-to-replicate src-table-numeric-id dst-table-to-replicate dst-table-numeric-id

example:
./pg_go_replicate books id books id
```

## References

<https://stackoverflow.com/questions/60348559/using-go-to-copy-from-one-postgres-db-to-another>
<https://pkg.go.dev/github.com/go-pg/pg>
<https://pkg.go.dev/github.com/go-pg/pg/v10#section-readme>
<https://pkg.go.dev/github.com/go-pg/pg/v10#Conn.CopyFrom>
<http://go-database-sql.org/errors.html>
<https://dev.to/0xarjunshetty/connecting-to-postgres-with-standard-sql-package-in-golang-hmh>
