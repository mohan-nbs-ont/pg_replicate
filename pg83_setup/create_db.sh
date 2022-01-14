#! /bin/bash
## NOTE: This script will delete old $PGDATA - $PWD/data
set -o errexit
set -o nounset
set -o pipefail

export PATH="/usr/lib/postgresql/8.3/bin:$PATH"
export BASE="$PWD/database"

rm -rf "${BASE}"
mkdir -p "${BASE}"

export PGDATA="${BASE}/83"
export PGHOST="${PGDATA}"

DBSUPER=$(id -n -u)
DBNAME="testdb"

sockwait() {
  set +o pipefail
  timeout "${1}" stdbuf -oL netstat --tcp --listening --numeric --continuous |
    tee /dev/stdout |
    grep -E -m 1 ":$2\b"
}

rm -rf "${BASE}"
mkdir -p "${BASE}/data"
chmod 0700 "${BASE}/data"

export TZ="America/Toronto"
initdb --encoding=UTF8 >/dev/null

cat >"${PGDATA}/postgresql.conf" <<EOF
# https://www.postgresql.org/docs/8.3/runtime-config-connection.html
data_directory = '${PGDATA}'
hba_file = '${PGDATA}/pg_hba.conf'
ident_file = '${PGDATA}/pg_ident.conf'
listen_addresses = '127.0.0.83'
max_connections = 300
unix_socket_directory = '${PGDATA}'
shared_buffers = 128MB
log_line_prefix = '%t %d %u %v '
log_statement = 'all'
log_connections = 'yes'
log_disconnections = 'yes'

#ssl = on
EOF

cat >"${PGDATA}/pg_hba.conf" <<EOF
local   all         all                               trust
host    all ${DBSUPER} 127.0.0.0/24 trust
host    ${DBNAME} all 127.0.0.0/24 md5
EOF

pg_ctl start -D "${PGDATA}" -s
sockwait 5 5432

# cp -pf /tmp/server.key "$PGDATA"
# cp -pf /tmp/server.crt "$PGDATA"
# cp -pf /tmp/root.key "$PGDATA"
# cp -pf /tmp/root.crt "$PGDATA"

createuser --host="${PGDATA}" --username="${DBSUPER}" --login --superuser postgres
createdb --host="${PGDATA}" --username="${DBSUPER}" --encoding=UTF8 --owner="${DBSUPER}" \
   --template=template0 "${DBNAME}"

psql -h "${PGDATA}" -d postgres -f create_role.sql

pg_ctl stop -W -D "${PGDATA}" -s -m immediate -W
rm -f "${PGDATA}/.s.PGSQL.5432.*" "${PGDATA}/postmaster.pid"
