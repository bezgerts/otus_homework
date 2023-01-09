-- Создание табличного пространства (https://www.postgresql.org/docs/current/sql-createtablespace.html)

-- Перед созданием в докере необходимо создать каталог и дать права на этот каталог для пользователя postgres
-- mkdir /data/dbs
-- chown postgres:postgres /data/dbs
CREATE TABLESPACE otus_tablespace OWNER otus_admin LOCATION '/tablespaces';
ALTER TABLESPACE otus_tablespace OWNER TO otus_admin;
COMMENT ON TABLESPACE otus_tablespace IS 'Табличное пространство для интернет-магазина';