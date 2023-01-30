-- Что и как делал:
-- - добавил функции для рандомной генерации данных в таблице продукты;
-- - добавил в таблицу 1000 фейковых записей;
-- - создавал индексы;
-- - сразу запускал ANALYSE;
-- - писал запросы и смотрел, как они выполняются.

-- Создаем функции для того, чтобы сгенерить рандомные продукты

-- Создаем функцию для получения рандомного int в определенных границах
CREATE OR REPLACE FUNCTION
random_in_range(INTEGER, INTEGER) RETURNS INTEGER
AS $$
SELECT floor(($1 + ($2 - $1 + 1) * random()))::INTEGER;
$$ LANGUAGE SQL;


-- Создаем функцию для получения рандомного текста определенной длины
CREATE FUNCTION random_text(INTEGER)
    RETURNS TEXT
    LANGUAGE SQL
    AS $$
select upper(
               substring(
                       (SELECT string_agg(md5(random()::TEXT), '')
                        FROM generate_series(
                                1,
                                CEIL($1 / 32.)::integer)
                       ), 1, $1) );
$$;


-- Создаем 1000 рандомных продуктов
INSERT INTO otus_db_yaos.otus.products(id, name, cost, category_id)
SELECT nextval('otus_db_yaos.otus.products_id_seq'::regclass),
       random_text(20),
       random_in_range(1, 100000),
       random_in_range(1, 3)
FROM generate_series(1, 1000);

-- Создаем индекс для поиска по цене
drop index if exists otus_db_yaos.otus.products_cost_index;
create index products_cost_index on otus_db_yaos.otus.products (cost);
comment on index otus_db_yaos.otus.products_cost_index is 'Индекс для осуществления фильтрации по стоимости продукта';

-- Выполняем ANALYSE
ANALYSE;

-- Выполняем эксплейн на запрос по цене
explain (costs, verbose, format json)--, analyze)
select * from otus_db_yaos.otus.products where cost > 99000;

-- Выполняем эксплейн с аналайз на запрос по цене
explain (costs, verbose, format json, analyze)
select * from otus_db_yaos.otus.products where cost > 99000;

-- Результат выполнения без аналайз
-- explain (costs, verbose, format json)--, analyze)
-- select * from otus_db_yaos.otus.products where cost > 99000;
--
-- [
--   {
--     "Plan": {
--       "Node Type": "Bitmap Heap Scan",
--       "Parallel Aware": false,
--       "Async Capable": false,
--       "Relation Name": "products",
--       "Schema": "otus",
--       "Alias": "products",
--       "Startup Cost": 4.36,
--       "Total Cost": 13.98,
--       "Plan Rows": 11,
--       "Plan Width": 33,
--       "Output": ["id", "name", "cost", "category_id"],
--       "Recheck Cond": "(products.cost > 99000)",
--       "Plans": [
--         {
--           "Node Type": "Bitmap Index Scan",
--           "Parent Relationship": "Outer",
--           "Parallel Aware": false,
--           "Async Capable": false,
--           "Index Name": "products_cost_index",
--           "Startup Cost": 0.00,
--           "Total Cost": 4.36,
--           "Plan Rows": 11,
--           "Plan Width": 0,
--           "Index Cond": "(products.cost > 99000)"
--         }
--       ]
--     }
--   }
-- ]

-- Результат выполнения с без аналайз
-- explain (costs, verbose, format json, analyze)
-- select * from otus_db_yaos.otus.products where cost > 99000;
--
-- [
--   {
--     "Plan": {
--       "Node Type": "Bitmap Heap Scan",
--       "Parallel Aware": false,
--       "Async Capable": false,
--       "Relation Name": "products",
--       "Schema": "otus",
--       "Alias": "products",
--       "Startup Cost": 4.36,
--       "Total Cost": 13.98,
--       "Plan Rows": 11,
--       "Plan Width": 33,
--       "Actual Startup Time": 0.010,
--       "Actual Total Time": 0.019,
--       "Actual Rows": 13,
--       "Actual Loops": 1,
--       "Output": ["id", "name", "cost", "category_id"],
--       "Recheck Cond": "(products.cost > 99000)",
--       "Rows Removed by Index Recheck": 0,
--       "Exact Heap Blocks": 8,
--       "Lossy Heap Blocks": 0,
--       "Plans": [
--         {
--           "Node Type": "Bitmap Index Scan",
--           "Parent Relationship": "Outer",
--           "Parallel Aware": false,
--           "Async Capable": false,
--           "Index Name": "products_cost_index",
--           "Startup Cost": 0.00,
--           "Total Cost": 4.36,
--           "Plan Rows": 11,
--           "Plan Width": 0,
--           "Actual Startup Time": 0.005,
--           "Actual Total Time": 0.005,
--           "Actual Rows": 13,
--           "Actual Loops": 1,
--           "Index Cond": "(products.cost > 99000)"
--         }
--       ]
--     },
--     "Planning Time": 0.126,
--     "Triggers": [
--     ],
--     "Execution Time": 0.034
--   }
-- ]


-- Создание полнотекстового индекса
-- Добавляем поле с текстовой лексемой в таблицу products
alter table otus_db_yaos.otus.products add column name_lexeme tsvector;
update otus_db_yaos.otus.products
set name_lexeme = to_tsvector(name)
where cost < 5000;

-- Смотрим что получилось
select * from otus_db_yaos.otus.products where cost < 5000;

-- Создаем полнотекстовый индекс по полю с лексемой (name_lexeme)
drop index if exists products_title_gin_index;
create index products_title_gin_index ON otus_db_yaos.otus.products USING gin (name_lexeme);

-- Выполняем ANALYSE
ANALYSE;

explain (costs, verbose, format json)--, analyze)
select id, name, cost from otus_db_yaos.otus.products where products.name_lexeme @@ to_tsquery('346f4c45c7467e857a27 | 624f1288151eef209944' );

-- Результат выполнения
-- explain (costs, verbose, format json)--, analyze)
-- select id, name, cost from otus_db_yaos.otus.products where products.name_lexeme @@ to_tsquery('346f4c45c7467e857a27 | 624f1288151eef209944' );
-- [
--   {
--     "Plan": {
--       "Node Type": "Bitmap Heap Scan",
--       "Parallel Aware": false,
--       "Async Capable": false,
--       "Relation Name": "products",
--       "Schema": "otus",
--       "Alias": "products",
--       "Startup Cost": 12.27,
--       "Total Cost": 18.11,
--       "Plan Rows": 2,
--       "Plan Width": 29,
--       "Output": ["id", "name", "cost"],
--       "Recheck Cond": "(products.name_lexeme @@ to_tsquery('346f4c45c7467e857a27 | 624f1288151eef209944'::text))",
--       "Plans": [
--         {
--           "Node Type": "Bitmap Index Scan",
--           "Parent Relationship": "Outer",
--           "Parallel Aware": false,
--           "Async Capable": false,
--           "Index Name": "products_title_gin_index",
--           "Startup Cost": 0.00,
--           "Total Cost": 12.26,
--           "Plan Rows": 2,
--           "Plan Width": 0,
--           "Index Cond": "(products.name_lexeme @@ to_tsquery('346f4c45c7467e857a27 | 624f1288151eef209944'::text))"
--         }
--       ]
--     }
--   }
-- ]

-- Удаляем колонку name_lexeme из таблицы
alter table otus_db_yaos.otus.products drop column name_lexeme;


-- Создание индекса с полнотекстовым поиском без использования дополнительного столбца
drop index if exists products_title_gin_index;
CREATE INDEX products_title_gin_index ON otus_db_yaos.otus.products USING GIN (to_tsvector('english', name));

-- Выполняем ANALYSE
ANALYSE;

explain (costs, verbose, format json)--, analyze)
SELECT id, name, cost
FROM otus_db_yaos.otus.products
WHERE to_tsvector('english', name) @@ to_tsquery('346f4c45c7467e857a27 | 624f1288151eef209944');

-- Результат выполнения
-- explain (costs, verbose, format json)--, analyze)
-- SELECT id, name, cost
-- FROM otus_db_yaos.otus.products
-- WHERE to_tsvector('english', name) @@ to_tsquery('346f4c45c7467e857a27 | 624f1288151eef209944');
-- [
--   {
--     "Plan": {
--       "Node Type": "Bitmap Heap Scan",
--       "Parallel Aware": false,
--       "Async Capable": false,
--       "Relation Name": "products",
--       "Schema": "otus",
--       "Alias": "products",
--       "Startup Cost": 12.27,
--       "Total Cost": 18.61,
--       "Plan Rows": 2,
--       "Plan Width": 29,
--       "Output": ["id", "name", "cost"],
--       "Recheck Cond": "(to_tsvector('english'::regconfig, (products.name)::text) @@ to_tsquery('346f4c45c7467e857a27 | 624f1288151eef209944'::text))",
--       "Plans": [
--         {
--           "Node Type": "Bitmap Index Scan",
--           "Parent Relationship": "Outer",
--           "Parallel Aware": false,
--           "Async Capable": false,
--           "Index Name": "products_title_gin_index",
--           "Startup Cost": 0.00,
--           "Total Cost": 12.26,
--           "Plan Rows": 2,
--           "Plan Width": 0,
--           "Index Cond": "(to_tsvector('english'::regconfig, (products.name)::text) @@ to_tsquery('346f4c45c7467e857a27 | 624f1288151eef209944'::text))"
--         }
--       ]
--     }
--   }
-- ]

-- Создание индекса только для тех записей, у которых category_id = 1
drop index if exists products_cost_for_first_category_id_index;
create index products_cost_for_first_category_id_index on otus_db_yaos.otus.products(cost) where category_id = 1;

-- Выполняем ANALYSE
ANALYSE;

explain (costs, verbose, format json)--, analyze)
select id, name, cost from otus_db_yaos.otus.products where cost < 2000 and category_id = 1;

-- Результат выполнения
-- explain (costs, verbose, format json)--, analyze)
-- select id, name, cost from otus_db_yaos.otus.products where cost < 2000 and category_id = 1;
-- [
--   {
--     "Plan": {
--       "Node Type": "Bitmap Heap Scan",
--       "Parallel Aware": false,
--       "Async Capable": false,
--       "Relation Name": "products",
--       "Schema": "otus",
--       "Alias": "products",
--       "Startup Cost": 4.23,
--       "Total Cost": 14.81,
--       "Plan Rows": 10,
--       "Plan Width": 29,
--       "Output": ["id", "name", "cost"],
--       "Recheck Cond": "((products.cost < 2000) AND (products.category_id = 1))",
--       "Plans": [
--         {
--           "Node Type": "Bitmap Index Scan",
--           "Parent Relationship": "Outer",
--           "Parallel Aware": false,
--           "Async Capable": false,
--           "Index Name": "products_cost_for_first_category_id_index",
--           "Startup Cost": 0.00,
--           "Total Cost": 4.22,
--           "Plan Rows": 10,
--           "Plan Width": 0,
--           "Index Cond": "(products.cost < 2000)"
--         }
--       ]
--     }
--   }
-- ]

-- Создание индекса на два поля (стоимость и категория)
drop index if exists products_cost_and_category_id_index;
create index products_cost_and_category_id_index on otus_db_yaos.otus.products(cost, category_id);

-- Выполняем ANALYSE
ANALYSE;

explain (costs, verbose, format json)--, analyze)
select id, name, cost from otus_db_yaos.otus.products where cost < 2000 and category_id = 2;
-- Результат выполнения
-- explain (costs, verbose, format json)--, analyze)
-- select id, name, cost from otus_db_yaos.otus.products where cost < 2000 and category_id = 2;
-- [
--   {
--     "Plan": {
--       "Node Type": "Bitmap Heap Scan",
--       "Parallel Aware": false,
--       "Async Capable": false,
--       "Relation Name": "products",
--       "Schema": "otus",
--       "Alias": "products",
--       "Startup Cost": 4.57,
--       "Total Cost": 15.13,
--       "Plan Rows": 9,
--       "Plan Width": 29,
--       "Output": ["id", "name", "cost"],
--       "Recheck Cond": "((products.cost < 2000) AND (products.category_id = 2))",
--       "Plans": [
--         {
--           "Node Type": "Bitmap Index Scan",
--           "Parent Relationship": "Outer",
--           "Parallel Aware": false,
--           "Async Capable": false,
--           "Index Name": "products_cost_and_category_id_index",
--           "Startup Cost": 0.00,
--           "Total Cost": 4.57,
--           "Plan Rows": 9,
--           "Plan Width": 0,
--           "Index Cond": "((products.cost < 2000) AND (products.category_id = 2))"
--         }
--       ]
--     }
--   }
-- ]