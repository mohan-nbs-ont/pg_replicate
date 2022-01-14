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

Applications used for testing

`pg83_setup` - creats a source database (postgres 8.3)
`pg14_setup` - creats a destination database (postgres 14)
`pg_insert` - create the 'books' table in both databases
            - insert data records to source database

### Create and run test source/destination databases

Console 1: Create and start destination database

```
cd pg14_setup
./create_db.sh
./start_db.sh
```

Console 2: Create and start source database

```
cd pg83_setup
./create_db.sh
./start_db.sh
```

### Create test table and insert test data into source database

```
cd pg_insert
./run-this-to-create-and-load-source-table.sh
```

## running the replicator

```
for s in $(seq 1 1000000); do
  ./pg_insert "a$s" "t$s"
done
```

## Test environment has been setup

* Replicate table 'books' from source to destination

```
cd pg_replicate
./pg_replicate books id books id
```
