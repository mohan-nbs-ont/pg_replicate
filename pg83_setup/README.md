#  install, initialize, create and run postgresql 14 database for testing

* shell scripts

```
install_db.sh - download, extract, install pre-requisites, pg14 to $HOME/database/14

create_db.sh - initialize and create a pg14 database in $PWD/data/

start_db.sh - start the database created in $PWD/data/ (PGDATA = $PWD/data/tmp/data)

login_db.sh - login as superuser to database that was started above

login_role.sh - login as non-superuser
```

* sql files

```
create_role.sql - create testdb, users
```

```
*
!.gitignore
!*.sh
!*.sql
!README.md
```

* initialize, add, push

```
git init
git add .gitignore
git add .
git status
git commit
git remote add origin git@github.com:mohan-nbs-ont/pg14_setup.git
gh auth login
gh repo create pg14_setup --public
git push --set-upstream origin master
git push
```
