create schema otus;

create table otus.product_categories
(
    id   int unsigned auto_increment comment 'Идентификатор категории продуктов',
    name VARCHAR(255) not null comment 'Название категории',
    constraint product_categories_pk
        primary key (id)
)
comment 'Категория продуктов';

create unique index product_categories_id_uindex on otus.product_categories (id);

create table otus.products
(
    id                      int             unsigned auto_increment comment 'Идентификатор продукта',
    name                    varchar(255)    not null comment 'Название продукта',
    category_id             int             unsigned not null,
    cost                    decimal         not null,
    attributes_json         JSON            comment 'Джейсон с аттрибутами продукта',
    description             text            not null comment 'Описание товара',
    constraint products_pk
        primary key (id),
    constraint products_product_categories_id_fk
        foreign key (category_id) references otus.product_categories (id)
)    comment 'Таблица с продуктами интернет-магазина';

create unique index products_id_uindex on otus.products (id);

create table if not exists otus.users
(
    id int unsigned auto_increment comment 'Идентификатор пользователя',
    first_name varchar(50) not null comment 'Имя',
    last_name varchar(50) comment 'Фамилия',
    email varchar(50) comment 'Электронный адрес',
    constraint user_pk primary key (id)
) comment 'Таблица пользователей';

create unique index user_id_uindex on otus.users (id);

create table if not exists otus.order_statuses
(
    id int unsigned auto_increment comment 'Идентификатор статуса заказа',
    status varchar(50) not null comment 'Статус заказа',
    constraint order_statuses_pk
        primary key (id)
) comment 'Таблица со статусами заказов';

create unique index order_statuses_id_uindex on otus.order_statuses (id);

create table if not exists otus.payment_types
(
    id int unsigned auto_increment comment 'Идентификатор типа оплаты',
    payment_type varchar(50) not null comment 'Типы оплаты',
    constraint payment_types_pk
        primary key (id)
) comment 'Тип оплаты';

create table if not exists otus.orders
(
    id int unsigned auto_increment comment 'Идентификатор заказа',
    user_id int unsigned not null comment 'Идентификатор пользователя, оформившего заказ',
    creation_datetime datetime not null comment 'Дата и время создания заказа',
    order_status_id int unsigned not null comment 'Идентификатор статуса заказа',
    payment_type_id int unsigned not null comment 'Тип оплаты заказа',
    constraint order_pk
        primary key (id),
    constraint order_user_id__fk
        foreign key (user_id) references otus.users(id),
    constraint orders_order_status__fk
     foreign key (order_status_id) references otus.order_statuses(id),
     constraint  orders_payment_type_id_fk
        foreign key (payment_type_id) references otus.payment_types(id)
) comment 'Таблица заказов';

create unique index order_id_uindex on otus.orders (id);


create table if not exists otus.order_product
(
    order_id int unsigned not null comment 'Идентификатор заказа',
    product_id int unsigned not null comment 'Идентификатор продукта',
    count mediumint unsigned not null comment 'Количество',
    constraint order_product_pk
        primary key (order_id, product_id),
    constraint order_product_order_id_fk
        foreign key (order_id) references otus.orders(id),
    constraint order_product_product_id_fk
        foreign key (product_id) references otus.products(id)
) comment 'Таблица для связи продуктов в заказе';

create unique index payment_types_id_uindex  on otus.payment_types (id);


-- Добавление пользователей

INSERT INTO otus.users (id, first_name, last_name, email)
    VALUES (1, 'Иван', 'Иванов', 'ivan@mail.ru'),
           (2, 'Петр', 'Петров', 'petrov@gmail.com'),
           (3, 'Александр', 'Григорьев', 'gg88@yandex.ru');

-- Добавление категории продуктов

INSERT INTO otus.product_categories (id, name)
    VALUES (1, 'Одежда'),
           (2, 'Бытовая техника'),
           (3, 'Продукты питания');

-- Добавление продуктов

INSERT INTO otus.products (id, name, cost, category_id, attributes_json, description)
    VALUES (1, 'Хлеб', 59, 3, '{"weight":"800g", "type":"ржаной"}','вкусный'),
           (2, 'Молоко', 100, 3, '{"volume":"1L", "fat":"5%"}', 'коровье'),
           (3, 'Халва', 150, 3, null, 'подсолнечная'),
           (4, 'Колбаса', 200, 3, '{"weight":"1kg"}', 'вареная'),
           (5, 'Холодильник', 24999, 2, '{}', 'двухкамерный'),
           (6, 'Телевизор', 50000, 2, null, 'жк'),
           (7, 'Посудомойка', 32149, 2, null, 'хорошо отмывает посуду'),
           (8, 'Джинсы', 3499, 1, null, 'левис'),
           (9, 'Рубашка', 2999, 1, '{"color": "blue", "size":"M"}', 'синяя');

-- Добавление типов оплаты

INSERT INTO otus.payment_types (id, payment_type)
    VALUES (1, 'Банковская карта'),
           (2, 'Наличные');

-- Добавление статусов заказа

INSERT INTO otus.order_statuses (id, status)
    VALUES (1, 'Оплачено'),
           (2, 'В работе'),
           (3, 'Доставлено'),
           (4, 'Покупатель забрал заказ');

-- Добавление заказов

INSERT INTO otus.orders (id, user_id, creation_datetime, order_status_id, payment_type_id)
    VALUES (1, 1, '2023-04-03 11:36:22', 2, 2),
           (2, 2, '2022-04-03 11:36:22', 1, 1),
           (3, 3, '2023-03-03 14:36:22', 2, 2),
           (4, 1, '2023-02-05 11:38:22', 1, 1),
           (5, 3, '2023-04-04 16:36:22', 1, 1);

-- Добавление продуктов в заказы

INSERT INTO otus.order_product (order_id, product_id, count)
    VALUES (1, 2, 5),
           (2, 1, 1),
           (3, 5, 1),
           (4, 1, 3),
           (5, 3, 10),
           (5, 4, 4),
           (5, 6, 1);