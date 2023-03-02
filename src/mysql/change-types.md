# Смена типов после переезда с Postgres

1. В таблице `products` поменят тип у столбца `cost` с `int` на `decimal `.
2. У идентификаторов указал `int unsigned`, так как айдишники не могут быть с отрицательным знаком.
3. В таблице `order_product` поменят тип у столбца `count` с `int` на `mediumint unsigned`.

# Добавление поля JSON в таблицу products

Добавил в таблицу `products` поле `attributes_json`:   

`attributes_json         JSON            comment 'Джейсон с аттрибутами продукта',`

В `init.sql` в таблицу `products` данные добавляются следующим образом:

`INSERT INTO otus.products (id, name, cost, category_id, attributes_json)
VALUES (1, 'Хлеб', 59, 3, '{"weight":"800g", "type":"ржаной"}'),
(2, 'Молоко', 100, 3, '{"volume":"1L", "fat":"5%"}'),
(3, 'Халва', 150, 3, null),
(4, 'Колбаса', 200, 3, '{"weight":"1kg"}'),
(5, 'Холодильник', 24999, 2, '{}'),
(6, 'Телевизор', 50000, 2, null),
(7, 'Посудомойка', 32149, 2, null),
(8, 'Джинсы', 3499, 1, null),
(9, 'Рубашка', 2999, 1, '{"color": "blue", "size":"M"}');`

Выборка всех продуктов, у которых есть атрибут `weight`:

`SELECT * from products p where p.attributes_json is not null AND JSON_EXTRACT(p.attributes_json, '$.weight') IS NOT NULL;`

Выборка всех продуктов, у которых атрибут `weight` равен `800g`:

`SELECT * from products p where p.attributes_json is not null AND JSON_EXTRACT(p.attributes_json, '$.weight') = '800g';`
