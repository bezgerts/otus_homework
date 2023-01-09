-- Таблица order_statuses ---

-- Индекс необходим для фильтрации продукта по стоимости (не уверен, что этот индекс будет нужен, так как статусов не будет много)
create unique index order_statuses_status_index on otus.order_statuses (status);
comment on index otus.order_statuses_status_index is 'Индекс для фильтрации по статусу заказа';

-- Таблица orders ---

-- Индекс необходим для фильтрации заказов по пользователю, чтобы можно было быстро отображать
-- пользователям в UI их заказы
create index orders_user_id_index on otus.orders (user_id);
comment on index otus.orders_user_id_index is 'Индекс для фильтрации заказов по пользователю';

-- Таблица products ---

-- Индекс необходим для фильтрации продукта по стоимости
create index products_cost_index on otus.products (cost);
comment on index otus.products_cost_index is 'Индекс для осуществления фильтрации по стоимости продукта';

-- Индекс необходим для фильтрации продукта по категориям
create index products_category_id_index on otus.products (category_id);
comment on index otus.products_category_id_index is 'Индекс для осуществления фильтрации по категориям продукта';

-- Индекс необходим для фильтрации продукта по наименованию и стоимости продукта.
-- Первым полем указано наименование продукта, так как его координальность выше, чем стоимость продукта.
create index products_name_cost_index on otus.products (name, cost);
comment on index otus.products_name_cost_index is 'Индекс для осуществления фильтрации по наименованию и стоимости продукта';

-- Проверка на то, что цена больше нуля
alter table otus.products add constraint check_cost_for_positive check (cost > 0);
comment on constraint check_cost_for_positive on otus.products is 'Проверка на то, что цена больше нуля';

-- Таблица users ---
create index users_email_last_name_first_name_index on otus.users (email, last_name, first_name);
comment on index otus.users_email_last_name_first_name_index is 'Индекс для осуществления фильтрации по имейлу, фамилии, имени пользователей';
