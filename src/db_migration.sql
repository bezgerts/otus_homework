create table if not exists otus.product_categories
(
    id serial not null
        constraint product_categories_pk
            primary key,
    name varchar(255) not null
) TABLESPACE otus_tablespace;
comment on table otus.product_categories is 'Категории продуктов';
comment on column otus.product_categories.id is 'Идентификатор категории продуктов';
comment on column otus.product_categories.name is 'Название категории';

create table if not exists otus.products
(
    id          serial       not null
        constraint products_pk
            primary key,
    name        varchar(255) not null,
    cost        integer      not null,
    category_id integer      not null
        constraint category_id
            references otus.product_categories
) TABLESPACE otus_tablespace;
comment on table otus.products is 'Таблица с продуктами интернет-магазина';
comment on column otus.products.id is 'Идентификатор продукта';
comment on column otus.products.name is 'Название продукта';
comment on column otus.products.cost is 'Цена';

create unique index if not exists products_id_uindex on otus.products (id);
create unique index if not exists product_categories_id_uindex on otus.product_categories (id);

create table if not exists otus.users
(
    first_name varchar(50) not null,
    id serial not null
        constraint user_pk
            primary key,
    last_name varchar(50),
    email varchar(50)
) TABLESPACE otus_tablespace;
comment on table otus.users is 'Таблица пользователей';
comment on column otus.users.first_name is 'Имя';
comment on column otus.users.id is 'Идентификатор пользователя';
comment on column otus.users.last_name is 'Фамилия';
comment on column otus.users.email is 'Электронный адрес';

create unique index if not exists user_id_uindex on otus.users (id);

create table if not exists otus.order_statuses
(
    id serial not null
        constraint order_statuses_pk
            primary key,
    status varchar(50) not null
) TABLESPACE otus_tablespace;
comment on table otus.order_statuses is 'Таблица со статусами заказов';
comment on column otus.order_statuses.id is 'Идентификатор статуса заказа';
comment on column otus.order_statuses.status is 'Статус заказа';

create unique index if not exists order_statuses_id_uindex on otus.order_statuses (id);

create table if not exists otus.payment_types
(
    id serial not null
        constraint payment_types_pk
            primary key,
    payment_type varchar(50) not null
) TABLESPACE otus_tablespace;
comment on table otus.payment_types is 'Типы оплаты';
comment on column otus.payment_types.id is 'Идентификатор типа оплаты';
comment on column otus.payment_types.payment_type is 'Тип оплаты';

create table if not exists otus.orders
(
    id serial not null
        constraint order_pk
            primary key,
    user_id integer not null
        constraint order_user_id__fk
            references otus.users,
    order_status_id integer
        constraint orders_order_status__fk
            references otus.order_statuses,
    payment_type_id integer not null
        constraint orders_payment_type_id_fk
            references otus.payment_types
) PARTITION BY HASH(id) TABLESPACE otus_tablespace ;
comment on table otus.orders is 'Таблица заказов';
comment on column otus.orders.id is 'Идентификатор заказа';
comment on column otus.orders.user_id is 'Идентификатор пользователя, оформившего заказ';
comment on column otus.orders.order_status_id is 'Идентификатор статуса заказа';

create table orders_part_0 partition of otus.orders for values with (modulus 4, remainder 0);
create table orders_part_1 partition of otus.orders for values with (modulus 4, remainder 1);
create table orders_part_2 partition of otus.orders for values with (modulus 4, remainder 2);
create table orders_part_3 partition of otus.orders for values with (modulus 4, remainder 3);

create unique index if not exists order_id_uindex on otus.orders (id);

create table if not exists otus.order_product
(
    order_id integer not null
        constraint order_product_order_id_fk
            references otus.orders,
    product_id integer not null
        constraint order_product_product_id_fk
            references otus.products,
    count integer not null,
    constraint order_product_pk
        primary key (order_id, product_id)
) TABLESPACE otus_tablespace;
comment on table otus.order_product is 'Таблица для связи продуктов в заказе';
comment on column otus.order_product.order_id is 'Идентификатор заказа';
comment on column otus.order_product.product_id is 'Идентификатор продукта';
comment on column otus.order_product.count is 'Количество';

create unique index if not exists payment_types_id_uindex  on otus.payment_types (id);
