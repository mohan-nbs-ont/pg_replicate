# Outline

* Application `pg_replicate` replicates a table from source database to
  destination database

* The table should be available in both the source and destination database

* The table should have the following characteristics

  * Primary key that is a unique sequence number
  * The sequence number (primary key) is incremented with each new record
    inserted into table

* The replication will use this to break the table into batches based on the
  sequence number

* Data is read in batches from the source database and written to the
  destination database table

## Testing

The `pg_replicate` repo contains the application itself  - `pg_replicate` - and
auxiliary programs to test it.

`pg83_setup` is for creating a source (postgres 8.3) database
`pg14_setup` is for creating a destination (postgres 14) database

`pg_insert`

create the 'books' table in both databases
insert data records to source database

### create and run test source/destination databases

console 1: create and start destination database

```
cd pg14_setup
./create_db.sh
./start_db.sh
```

console 2: create and start source database

```
cd pg83_setup
./create_db.sh
./start_db.sh
```

### create test table and insert test data into source database

* will insert 10000 records into 'books' table, with a primary
  key that is an incremental sequence number

```
cd pg_insert
./run-this-to-create-and-load-source-table.sh
```

## running the replicator

```
cd pg_replicate
./run
```
