-- Ищем в списке продуктов названия таких продуктов, которые начинаются на символ Х, и далее следует либо символ 'а' либо символ 'л'
select products.name
from otus_db_yaos.otus.products
where name similar to 'Х(а|л)%';

-- Запрос на получение данных о заказах определенного пользователя
select ord.id, os.status, p.name, p.cost * op.count
from otus_db_yaos.otus.orders ord
         INNER JOIN otus_db_yaos.otus.order_product op on ord.id = op.order_id
         INNER JOIN otus_db_yaos.otus.products p on op.product_id = p.id
         INNER JOIN otus_db_yaos.otus.order_statuses os on ord.order_status_id = os.id
where ord.user_id = 1;

-- Запрос на вывод всех категорий продуктов с присоединением к ним продуктов справа.
select *
from otus_db_yaos.otus.product_categories pc
         LEFT JOIN otus_db_yaos.otus.products p on pc.id = p.category_id;

-- Запрос на вывод всех продуктов с присоединением к ним категорий продуктов справа.
-- Если бы была возможность не указывать категорию продуктов у продукта, то к нему ничего бы не присоединилось,
-- и слева были бы значения null
select *
from otus_db_yaos.otus.products p
         LEFT JOIN otus_db_yaos.otus.product_categories pc on p.category_id = pc.id;

-- Запрос на вывод всех продуктов с присоединением к ним категорий продуктов.
-- В результатах будут выведены только те продукты, у которых есть категории продуктов.
select *
from otus_db_yaos.otus.products p
         INNER JOIN otus_db_yaos.otus.product_categories pc on p.category_id = pc.id;

-- Создание таблицы со статистикой заказов для пользователей
create table if not exists otus_db_yaos.otus.users_orders_stat
(
    id           serial       not null
        constraint users_orders_stat_pk primary key,
    user_id      integer      not null
        constraint users_orders_stat_user_id__fk
            references otus.users,
    order_id     integer      not null
        constraint users_orders_stat_product_order_id_fk
            references otus.orders,
    order_status varchar(50),
    name         varchar(255) not null,
    total_cost   integer
) TABLESPACE otus_tablespace;

-- Заполнение таблицы со статистикой заказов пользователей
INSERT INTO otus_db_yaos.otus.users_orders_stat (user_id, order_id, order_status, name, total_cost)
select ord.user_id, ord.id, os.status, p.name, p.cost * op.count
from otus_db_yaos.otus.orders ord
         INNER JOIN otus_db_yaos.otus.order_product op on ord.id = op.order_id
         INNER JOIN otus_db_yaos.otus.products p on op.product_id = p.id
         INNER JOIN otus_db_yaos.otus.order_statuses os on ord.order_status_id = os.id;

-- Добавление столбца с общей стоимостью заказов в работе
alter table otus_db_yaos.otus.users
    add total_cost integer;

-- Запрос для получения общей стоимости заказов со статусом в работе для пользователей
select ord.user_id as user_id, SUM(p.cost * op.count) as total_cost
from otus_db_yaos.otus.orders ord
         INNER JOIN otus_db_yaos.otus.order_product op on ord.id = op.order_id
         INNER JOIN otus_db_yaos.otus.products p on op.product_id = p.id
         INNER JOIN otus_db_yaos.otus.order_statuses os on ord.order_status_id = os.id
WHERE os.id = 1
GROUP BY ord.user_id;

-- Запрос на обновление столбца с общей стоимостью заказов в работе для пользователей
UPDATE otus_db_yaos.otus.users
SET total_cost = utc.total_cost
FROM (select ord.user_id as user_id, SUM(p.cost * op.count) as total_cost
      from otus_db_yaos.otus.orders ord
               INNER JOIN otus_db_yaos.otus.order_product op on ord.id = op.order_id
               INNER JOIN otus_db_yaos.otus.products p on op.product_id = p.id
               INNER JOIN otus_db_yaos.otus.order_statuses os on ord.order_status_id = os.id
      WHERE os.id = 1
      GROUP BY ord.user_id) as utc
WHERE users.id = utc.user_id;

-- Удаление столбца с общей стоимостью заказов в работе
alter table otus_db_yaos.otus.users
    drop column total_cost;

-- Удаление таблицы со статистикой заказов для пользователей
drop table if exists otus_db_yaos.otus.users_orders_stat cascade;

-- Получение всех продуктов, у которых категория продукта начинается с символа 'О'
select *
from otus_db_yaos.otus.products p
         INNER JOIN otus_db_yaos.otus.product_categories pc ON p.category_id = pc.id
where pc.name like 'О%';

-- Удаление всех продуктов, у которых категория продукта начинается с символа 'О'
DELETE
FROM otus_db_yaos.otus.products p
USING otus_db_yaos.otus.product_categories pc
WHERE p.category_id = pc.id AND pc.name like 'О%'
RETURNING p.id, p.name;

