-- Создание пользователя
create user otus_admin superuser createrole replication;
comment on role otus_admin is 'Администратор интернет-магазина';

grant connect, create on database "otus_db_yaos" TO otus_admin;

