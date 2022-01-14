#! /bin/bash
set -x
set -o pipefail
set -o errexit
set -o nounset

rm -f go.mod go.sum pg_go_replicate
go mod init pg_go_replicate
go mod tidy
go fmt main.go
CGO_ENABLED=0 go build -trimpath -ldflags "-s -w"

SRC_DB_URL="postgres://testdb_owner:welcome@127.0.0.83:5432/testdb?sslmode=disable"
DST_DB_URL="postgres://testdb_owner:welcome@127.0.0.12:5432/testdb?sslmode=disable"
export SRC_DB_URL
export DST_DB_URL

./pg_go_replicate books id books id
