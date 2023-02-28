-- Создание базы данных
create database otus_db_yaos with owner otus_admin;
comment on database otus_db_yaos is 'База данных для еще одного интернет магазина';

-- Создание схемы
create schema otus;
comment on schema otus is 'Схема для хранения таблиц интернет магазина';
alter schema otus owner to otus_admin;

