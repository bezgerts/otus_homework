# группировка по пользователям с having
# Запрос выводит пользователей, у которых суммарно оформлено заказов бол чем на 500 рублей
select u.id, u.first_name, u.last_name, SUM(p.cost * op.count) as sum
from otus.orders o
         left join otus.order_product op on o.id = op.order_id
         left join otus.users u on o.user_id = u.id
         left join otus.products p on op.product_id = p.id
group by (u.id)
having sum > 500;

# Просмотр эксплейна запроса в формате TREE
EXPLAIN FORMAT=TREE select u.id, u.first_name, u.last_name, SUM(p.cost * op.count) as sum
                from otus.orders o
                         left join otus.order_product op on o.id = op.order_id
                         left join otus.users u on o.user_id = u.id
                         left join otus.products p on op.product_id = p.id
                group by (u.id)
                having sum > 500;

# -> Filter: (sum > 500)
#     -> Table scan on <temporary>
#         -> Aggregate using temporary table
#             -> Nested loop left join
#                 -> Nested loop left join
#                     -> Nested loop left join
#                         -> Index scan on o using order_user_id__fk
#                         -> Index lookup on op using PRIMARY (order_id=otus.o.id)
#                     -> Single-row index lookup on u using PRIMARY (id=otus.o.user_id)
#                 -> Single-row index lookup on p using PRIMARY (id=otus.op.product_id)

# Просмотр эксплейна запроса в формате TREE
EXPLAIN FORMAT=JSON select u.id, u.first_name, u.last_name, SUM(p.cost * op.count) as sum
    from otus.orders o
    left join otus.order_product op on o.id = op.order_id
    left join otus.users u on o.user_id = u.id
    left join otus.products p on op.product_id = p.id
    group by (u.id)
    having sum > 500;
# {
#   "query_block": {
#     "select_id": 1,
#     "cost_info": {
#       "query_cost": "2.15"
#     },
#     "grouping_operation": {
#       "using_temporary_table": true,
#       "using_filesort": false,
#       "nested_loop": [
#         {
#           "table": {
#             "table_name": "o",
#             "access_type": "index",
#             "key": "order_user_id__fk",
#             "used_key_parts": [
#               "user_id"
#             ],
#             "key_length": "4",
#             "rows_examined_per_scan": 1,
#             "rows_produced_per_join": 1,
#             "filtered": "100.00",
#             "using_index": true,
#             "cost_info": {
#               "read_cost": "1.00",
#               "eval_cost": "0.10",
#               "prefix_cost": "1.10",
#               "data_read_per_join": "24"
#             },
#             "used_columns": [
#               "id",
#               "user_id"
#             ]
#           }
#         },
#         {
#           "table": {
#             "table_name": "op",
#             "access_type": "ref",
#             "possible_keys": [
#               "PRIMARY"
#             ],
#             "key": "PRIMARY",
#             "used_key_parts": [
#               "order_id"
#             ],
#             "key_length": "4",
#             "ref": [
#               "otus.o.id"
#             ],
#             "rows_examined_per_scan": 1,
#             "rows_produced_per_join": 1,
#             "filtered": "100.00",
#             "cost_info": {
#               "read_cost": "0.25",
#               "eval_cost": "0.10",
#               "prefix_cost": "1.45",
#               "data_read_per_join": "16"
#             },
#             "used_columns": [
#               "order_id",
#               "product_id",
#               "count"
#             ]
#           }
#         },
#         {
#           "table": {
#             "table_name": "u",
#             "access_type": "eq_ref",
#             "possible_keys": [
#               "PRIMARY",
#               "user_id_uindex",
#               "users_email_last_name_first_name_index"
#             ],
#             "key": "PRIMARY",
#             "used_key_parts": [
#               "id"
#             ],
#             "key_length": "4",
#             "ref": [
#               "otus.o.user_id"
#             ],
#             "rows_examined_per_scan": 1,
#             "rows_produced_per_join": 1,
#             "filtered": "100.00",
#             "cost_info": {
#               "read_cost": "0.25",
#               "eval_cost": "0.10",
#               "prefix_cost": "1.80",
#               "data_read_per_join": "616"
#             },
#             "used_columns": [
#               "id",
#               "first_name",
#               "last_name"
#             ]
#           }
#         },
#         {
#           "table": {
#             "table_name": "p",
#             "access_type": "eq_ref",
#             "possible_keys": [
#               "PRIMARY",
#               "products_id_uindex"
#             ],
#             "key": "PRIMARY",
#             "used_key_parts": [
#               "id"
#             ],
#             "key_length": "4",
#             "ref": [
#               "otus.op.product_id"
#             ],
#             "rows_examined_per_scan": 1,
#             "rows_produced_per_join": 1,
#             "filtered": "100.00",
#             "cost_info": {
#               "read_cost": "0.25",
#               "eval_cost": "0.10",
#               "prefix_cost": "2.15",
#               "data_read_per_join": "1K"
#             },
#             "used_columns": [
#               "id",
#               "cost"
#             ]
#           }
#         }
#       ]
#     }
#   }
# }

# Просмотр эксплейна аналайза запроса
# Самый большой кост у внешней Nested loop на строке 187
# Nested loop left join  (cost=2.15 rows=1) (actual time=0.076..0.170 rows=8 loops=1)
EXPLAIN ANALYZE select u.id, u.first_name, u.last_name, SUM(p.cost * op.count) as sum
    from otus.orders o
    left join otus.order_product op on o.id = op.order_id
    left join otus.users u on o.user_id = u.id
    left join otus.products p on op.product_id = p.id
    group by (u.id)
    having sum > 500;
# -> Filter: (sum > 500)  (actual time=0.346..0.347 rows=2 loops=1)
#     -> Table scan on <temporary>  (actual time=0.001..0.001 rows=3 loops=1)
#         -> Aggregate using temporary table  (actual time=0.341..0.342 rows=3 loops=1)
#             -> Nested loop left join  (cost=2.15 rows=1) (actual time=0.076..0.170 rows=8 loops=1)
#                 -> Nested loop left join  (cost=1.80 rows=1) (actual time=0.071..0.157 rows=8 loops=1)
#                     -> Nested loop left join  (cost=1.45 rows=1) (actual time=0.065..0.146 rows=8 loops=1)
#                         -> Index scan on o using order_user_id__fk  (cost=1.10 rows=1) (actual time=0.032..0.041 rows=6 loops=1)
#                         -> Index lookup on op using PRIMARY (order_id=o.id)  (cost=0.35 rows=1) (actual time=0.011..0.013 rows=1 loops=6)
#                     -> Single-row index lookup on u using PRIMARY (id=o.user_id)  (cost=0.35 rows=1) (actual time=0.001..0.001 rows=1 loops=8)
#                 -> Single-row index lookup on p using PRIMARY (id=op.product_id)  (cost=0.35 rows=1) (actual time=0.001..0.001 rows=1 loops=8)
