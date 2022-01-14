#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

export PATH="/usr/lib/postgresql/14/bin:$PATH"
export BASE="$PWD/database"
export PGDATA="${BASE}/14"
export PGHOST="${PGDATA}"

rm -f "${PGDATA}/.s.PGSQL.5432.lock" "${PGDATA}/postmaster.pid" "${PGDATA}/.s.PGSQL.5432"
postgres -D "${PGDATA}"
