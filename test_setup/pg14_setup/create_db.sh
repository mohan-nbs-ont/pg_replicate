#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

export PATH="/usr/lib/postgresql/14/bin:$PATH"
export BASE="$PWD/database"

rm -rf "${BASE}"
mkdir -p "${BASE}"

export PGDATA="${BASE}/14"
export PGHOST="${PGDATA}"

DBSUPER=$(id -n -u)
DBUSER=$DBSUPER
DBNAME="testdb"

sockwait() {
  set +o pipefail
  timeout "${1}" stdbuf -oL netstat --tcp --listening --numeric --continuous |
    tee /dev/stdout |
    grep -E -m 1 ":$2\b"
}

mkdir -p "${PGDATA}"
chmod 0700 "${PGDATA}"

export TZ="America/Toronto"
initdb --encoding=UTF8 --locale=en_CA.UTF-8 >/dev/null

cat >"${PGDATA}/postgresql.conf" <<EOF
data_directory = '${PGDATA}'
hba_file = '${PGDATA}/pg_hba.conf'
ident_file = '${PGDATA}/pg_ident.conf'
listen_addresses = '127.0.0.14'
max_connections = 300
unix_socket_directories = '${PGDATA}'
shared_buffers = 128MB
log_line_prefix = '%t %d %u %v '
log_statement = 'all'
log_connections = 'yes'
log_disconnections = 'yes'
EOF

cat >"${PGDATA}/pg_hba.conf" <<EOF
local   all         all                               trust
host    billing all 127.0.0.0/24 md5
host    all ${DBSUPER} 127.0.0.0/24 trust
host    ${DBNAME} all 127.0.0.0/24 md5
EOF

pg_ctl start -D "${PGDATA}" -s
sockwait 5 5432

createuser --host="${PGDATA}" --username="${DBSUPER}" --no-password --login \
  --superuser postgres
createdb --host="${PGDATA}" --username="${DBSUPER}" --encoding=UTF8 --owner="${DBSUPER}" \
  --template=template0 --locale=en_CA.UTF-8 "${DBNAME}"

psql -h "${PGDATA}" -d postgres -f create_role.sql
#psql -h "${PGDATA}" -d postgres -f create_roles.sql
#psql -h "${PGDATA}" -d billing -f billing_schema.sql -U billing_owner

pg_ctl stop -W -D "${PGDATA}" -s -m immediate -W
rm -f "${PGDATA}/.s.PGSQL.5432.*" "${PGDATA}/postmaster.pid"
