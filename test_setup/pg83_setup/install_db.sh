#! /bin/bash
set -o pipefail
set -o errexit
set -o nounset

# download and install postgresql 14
# https://www.postgresql.org/ftp/source/
# wget https://ftp.postgresql.org/pub/source/v14rc1/postgresql-14rc1.tar.gz

# pre-requisites
sudo apt-get install -y build-essential libreadline-dev zlib1g-dev \
  flex bison libxml2-dev libxslt-dev libssl-dev clang

mkdir -p "$HOME/database"
rm -rf "$HOME/database/14"

rm -rf postgresql-14rc1
tar xzf postgresql-14rc1.tar.gz

cd postgresql-14rc1
./configure --prefix="$HOME/database/14" --with-openssl CFLAGS="-O1" CC=clang
make
make install

cd contrib
make
make install

# tls certs - will be in /tmp
# copy to $PGDATA after running create_db

openssl req -new -x509 -days 365 -nodes -text -out server.crt   -keyout server.key -subj "/CN=db.yourdomain.com"
chmod og-rwx server.key
openssl req -new -nodes -text -out root.csr   -keyout root.key -subj "/CN=root.yourdomain.com"
chmod og-rwx root.key
openssl x509 -req -in root.csr -text -days 3650 \
 -extfile /etc/ssl/openssl.cnf -extensions v3_ca   -signkey root.key -out root.crt

cp -fp server.crt /tmp
cp -fp server.key /tmp
cp -fp root.crt /tmp
cp -fp root.key /tmp

