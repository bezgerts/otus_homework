create table if not exists product_categories
(
    id serial not null
    constraint product_categories_pk
    primary key,
    name varchar(255) not null
);
comment on table product_categories is 'Категории продуктов';
comment on column product_categories.id is 'Идентификатор категории продуктов';
comment on column product_categories.name is 'Название категории';

create table if not exists products
(
    id serial not null
    constraint products_pk
    primary key,
    name varchar(255) not null,
    cost integer not null,
    category_id integer not null
    constraint category_id
    references product_categories
);
comment on table products is 'Таблица с продуктами интернет-магазина';
comment on column products.id is 'Идентификатор продукта';
comment on column products.name is 'Название продукта';
comment on column products.cost is 'Цена';

create unique index if not exists products_id_uindex on products (id);
create unique index if not exists product_categories_id_uindex on product_categories (id);

create table if not exists users
(
    first_name varchar(50) not null,
    id serial not null
    constraint user_pk
    primary key,
    last_name varchar(50),
    email varchar(50)
);
comment on table users is 'Таблица пользователей';
comment on column users.first_name is 'Имя';
comment on column users.id is 'Идентификатор пользователя';
comment on column users.last_name is 'Фамилия';
comment on column users.email is 'Электронный адрес';

create unique index if not exists user_id_uindex on users (id);

create table if not exists order_statuses
(
    id serial not null
    constraint order_statuses_pk
    primary key,
    status varchar(50) not null
);
comment on table order_statuses is 'Таблица со статусами заказов';
comment on column order_statuses.id is 'Идентификатор статуса заказа';
comment on column order_statuses.status is 'Статус заказа';


create unique index if not exists order_statuses_id_uindex on order_statuses (id);

create table if not exists payment_types
(
    id serial not null
    constraint payment_types_pk
    primary key,
    payment_type varchar(50) not null
);
comment on table payment_types is 'Типы оплаты';
comment on column payment_types.id is 'Идентификатор типа оплаты';
comment on column payment_types.payment_type is 'Тип оплаты';

create table if not exists orders
(
    id serial not null
    constraint order_pk
    primary key,
    user_id integer not null
    constraint order_user_id__fk
    references users,
    order_status_id integer
    constraint orders_order_status__fk
    references order_statuses,
    payment_type_id integer not null
    constraint orders_payment_type_id_fk
    references payment_types
);
comment on table orders is 'Таблица заказов';
comment on column orders.id is 'Идентификатор заказа';
comment on column orders.user_id is 'Идентификатор пользователя, оформившего заказ';
comment on column orders.order_status_id is 'Идентификатор статуса заказа';

create unique index if not exists order_id_uindex on orders (id);

create table if not exists order_product
(
    order_id integer not null
    constraint order_product_order_id_fk
    references orders,
    product_id integer not null
    constraint order_product_product_id_fk
    references products,
    count integer not null,
    constraint order_product_pk
    primary key (order_id, product_id)
);
comment on table order_product is 'Таблица для связи продуктов в заказе';
comment on column order_product.order_id is 'Идентификатор заказа';
comment on column order_product.product_id is 'Идентификатор продукта';
comment on column order_product.count is 'Количество';

create unique index if not exists payment_types_id_uindex  on payment_types (id);

