-- Таблица order_statuses ---

-- Индекс необходим для фильтрации продукта по стоимости (не уверен, что этот индекс будет нужен, так как статусов не будет много)
create unique index order_statuses_status_index on otus.order_statuses (status) comment 'Индекс для фильтрации по статусу заказа';

-- Таблица orders ---

-- Индекс необходим для фильтрации заказов по пользователю, чтобы можно было быстро отображать
-- пользователям в UI их заказы
create index orders_user_id_index on otus.orders (user_id) comment 'Индекс для фильтрации заказов по пользователю';

-- Таблица products ---

-- Индекс необходим для фильтрации продукта по стоимости
create index products_cost_index on otus.products (cost) comment 'Индекс для осуществления фильтрации по стоимости продукта';

-- Индекс необходим для фильтрации продукта по категориям
create index products_category_id_index on otus.products (category_id) comment 'Индекс для осуществления фильтрации по категориям продукта';

-- Индекс необходим для фильтрации продукта по наименованию и стоимости продукта.
-- Первым полем указано наименование продукта, так как его координальность выше, чем стоимость продукта.
create index products_name_cost_index on otus.products (name, cost) comment 'Индекс для осуществления фильтрации по наименованию и стоимости продукта';

-- Индекс для полнотекстового поиска по названию и описанию продукта
create fulltext index products_fulltext_name_and_description_index on otus.products(name, description) comment 'Индекс для полнотекстового поиска по названию и описанию продукта';
explain SELECT * FROM otus.products p WHERE MATCH (name,description) AGAINST ('Хлеб');

-- вывод explain
# [
#   {
#     "id": 1,
#     "select_type": "SIMPLE",
#     "table": "p",
#     "partitions": null,
#     "type": "fulltext",
#     "possible_keys": "products_fulltext_name_and_description_index",
#     "key": "products_fulltext_name_and_description_index",
#     "key_len": "0",
#     "ref": "const",
#     "rows": 1,
#     "filtered": 100,
#     "Extra": "Using where; Ft_hints: sorted"
#   }
# ]

-- Таблица users ---

-- Индекс для осуществления фильтрации по имейлу, фамилии, имени пользователей
create index users_email_last_name_first_name_index on otus.users (email, last_name, first_name) comment 'Индекс для осуществления фильтрации по имейлу, фамилии, имени пользователей';


