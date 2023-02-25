# Подключение по SSH к виртуалке
https://medium.com/@pierangelo1982/setting-ssh-connection-to-ubuntu-on-virtualbox-af243f737b8b
ssh yourusername@127.0.0.1 -p 2222

# Установка Postgres
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-22-04

sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql.service

sudo -i -u postgres
psql

# Создание второго кластера

pg_lsclusters - кластера Postgres

sudo pg_ctlcluster 14 main start - запуск кластера

sudo pg_ctlcluster 14 main stop - остановка кластера

sudo pg_createcluster -d /var/lib/postgresql/14/main2 14 main2 - создаем второй кластер

sudo rm -rf /var/lib/postgresql/14/main2 - удаляем из него все файлы

Сделаем бэкап нашей БД. Ключ -R создаст заготовку управляющего файла recovery.conf.
sudo -u postgres pg_basebackup -p 5432 -R -D /var/lib/postgresql/14/main2

echo 'port = 5433' >> /var/lib/postgresql/10/main2/postgresql.auto.conf - Зададим другой порт (задан по умолчанию)

sudo echo 'hot_standby = on' >> /var/lib/postgresql/14/main2/postgresql.auto.conf - Добавим параметр горячего резерва, чтобы реплика принимала запросы на чтение (задан по умолчанию ключом D) 

Стартуем и проверяем кластер

- sudo pg_ctlcluster 14 main2 start
- pg_lsclusters

## Проверка состояния репликации

на мастере
sudo -u postgres psql -p 5432
SELECT * FROM pg_stat_replication \gx
SELECT * FROM pg_current_wal_lsn();

на реплике
sudo -u postgres psql -p 5433
select * from pg_stat_wal_receiver \gx
select pg_last_wal_receive_lsn();
select pg_last_wal_replay_lsn();

## Логическая репликация
Устанавливаем параметр логической репликации
ALTER SYSTEM SET wal_level = logical;

sudo pg_ctlcluster 12 main restart - рестартуем кластер

sudo -u postgres psql -p 5432 -d repl

Создаем публикацию на первом сервере:
CREATE PUBLICATION test_pub FOR TABLE student;

Просмотр созданной публикации:
\dRp+

Задать пароль для postgres:
\password
pas123


Создаем подписку на втором экземпляре
--создадим подписку к БД по Порту с Юзером и Паролем и Копированием данных=false
CREATE SUBSCRIPTION test_sub
CONNECTION 'host=localhost port=5432 user=postgres password=pas123 dbname=repl'
PUBLICATION test_pub WITH (copy_data = true);

\dRs
SELECT * FROM pg_stat_subscription \gx


--добавим одинаковые данные
---добавить индекс
create unique index on student(id);
\dS+ test

добавить одиноковые значения
удалить на втором экземпляре конфликтные записи

SELECT * FROM pg_stat_subscription \gx	просмотр состояния (при конфликте пусто)

просмотр логов
$ tail /var/log/postgresql/postgresql-14-main.log


drop publication test_pub;
drop subscription test_sub;

Удаление кластера
sudo pg_dropcluster 12 main2

----------