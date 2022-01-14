# Outline

* Application `pg_replicate` replicates a table from source database to destination
  database

* the table should be available in both the source and destination database

* the table should have the following characteristics

  * primary key that is a unique sequence number
  * the sequence number (primary key) is incremented with each new record inserted
    into table

* the replication will use this to break the table into batches - based on the
  sequence number

* data is read in batches from the source database and written to the destination
  database table

## testing

the `pg_replicate` repo contains the application itself  - `pg_replicate` - and
auxiliary programs to test it.
those are creating a source (postgres 8.3) database and destination (postgres 14)
database, the `pg_insert` program will create a table to test - books - which will
insert 10000 records that will  be replicated by `pg_replicate` between postgres
source 8.3 and destination 14

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
  key that is an incrementing sequence number

```
cd pg_insert
./run-this-to-create-and-load-source-table.sh
```

## running the replicator

```
cd pg_replicate
./run
```
