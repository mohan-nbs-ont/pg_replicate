# Install, initialize, create and run postgresql 8.3 database

## Process

* Install postgresql 8.3 software - see instructions below

```
./create_db.sh
./start_db.sh
```

```
create_db.sh - initialize and create a pg83 database in $PWD/data/
install_db.sh - download, extract, install pre-requisites, pg83 to $HOME/database/83
login_db.sh - login as superuser to database that was started above
start_db.sh - start the database created in $PWD/data/ (PGDATA = $PWD/data/tmp/data)
```

## Install via postgresql apt

```
sudo apt install curl ca-certificates gnupg

curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor \
 | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
 > /etc/apt/sources.list.d/pgdg.list'

sudo apt update
sudo apt install postgresql-8.3
sudo systemctl stop postgresql
sudo systemctl disable postgresql
```

* Binary path `/usr/lib/postgresql/8.3/bin`

## Alternative: install via source and set the path to it in script

* See `install_db.sh`

## Create test database and user

* Note: This is run via `create_db.sh`

```
create_role.sql - create testdb, users

cat >create_role.sql <<EOF
CREATE ROLE testdb_owner;
ALTER DATABASE testdb OWNER TO testdb_owner ;
ALTER ROLE testdb_owner ENCRYPTED PASSWORD 'welcome';
ALTER ROLE testdb_owner LOGIN ;
EOF
```

## Reference

<https://wiki.postgresql.org/wiki/Apt>
