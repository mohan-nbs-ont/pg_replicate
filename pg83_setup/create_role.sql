CREATE ROLE testdb_owner;
ALTER DATABASE testdb OWNER TO testdb_owner ;
ALTER ROLE testdb_owner ENCRYPTED PASSWORD 'welcome';
ALTER ROLE testdb_owner LOGIN ;
