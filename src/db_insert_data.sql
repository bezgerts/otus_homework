-- Добавление пользователей

INSERT INTO otus.users (id, first_name, last_name, email)
VALUES (1, 'Иван', 'Иванов', 'ivan@mail.ru'),
       (2, 'Петр', 'Петров', 'petrov@gmail.com'),
       (3, 'Александр', 'Григорьев', 'gg88@yandex.ru')
RETURNING (id, first_name, last_name, email);

-- Добавление категории продуктов

INSERT INTO otus.product_categories (id, name)
VALUES (1, 'Одежда'),
       (2, 'Бытовая техника'),
       (3, 'Продукты питания')
RETURNING (id, name);

-- Добавление продуктов

INSERT INTO otus.products (id, name, cost, category_id)
VALUES (1, 'Хлеб', 59, 3),
       (2, 'Молоко', 100, 3),
       (3, 'Халва', 150, 3),
       (4, 'Колбаса', 200, 3),
       (5, 'Холодильник', 24999, 2),
       (6, 'Телевизор', 50000, 2),
       (7, 'Посудомойка', 32149, 2),
       (8, 'Джинсы', 3499, 1),
       (9, 'Рубашка', 2999, 1)
RETURNING (id, name, cost, category_id);

-- Добавление типов оплаты

INSERT INTO otus.payment_types (id, payment_type)
VALUES (1, 'Банковская карта'),
       (2, 'Наличные')
RETURNING (id, payment_type);

-- Добавление статусов заказа

INSERT INTO otus.order_statuses (id, status)
VALUES (1, 'Оплачено'),
       (2, 'В работе'),
       (3, 'Доставлено'),
       (4, 'Покупатель забрал заказ')
RETURNING (id, status);

-- Добавление заказов

INSERT INTO otus.orders (id, user_id, order_status_id, payment_type_id)
VALUES (1, 1, 2, 2),
       (2, 2, 1, 1),
       (3, 3, 2, 2),
       (4, 1, 1, 1),
       (5, 3, 1, 1)
RETURNING (id, user_id, order_status_id, payment_type_id);

-- Добавление продуктов в заказы

INSERT INTO otus.order_product (order_id, product_id, count)
VALUES (1, 2, 5),
       (2, 1, 1),
       (3, 5, 1),
       (4, 1, 3),
       (5, 3, 10),
       (5, 4, 4),
       (5, 6, 1)
RETURNING (order_id, product_id, count);
