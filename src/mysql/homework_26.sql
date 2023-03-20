# пример с case
select p.name, p.cost,
case
    when p.cost > 10000
        then 'Очень дорогой'
    when p.cost > 1000
        then 'Дорогой'
    when p.cost > 100
        then 'Средний'
    else 'Дешевый'
end as 'cost estimation'
from otus.products p;

# группировка по пользователям с having
# Запрос выводит пользователей, у которых суммарно оформлено заказов бол чем на 500 рублей
select u.id, u.first_name, u.last_name, SUM(p.cost * op.count) as sum from otus.orders o
    left join otus.order_product op on o.id = op.order_id
    left join otus.users u on o.user_id = u.id
    left join otus.products p on op.product_id = p.id
group by (u.id)
having sum > 500;

# минимальная и максимальная цена продуктов в определенной категории
select p.category_id, min(p.cost), max(p.cost) from otus.products p group by category_id;

# количество товаров в категории с роллапом
select pc.id, count(p.id) as 'количество товаров в категории' from otus.products p
    left join otus.product_categories pc on pc.id = p.category_id
group by (pc.id) with rollup;