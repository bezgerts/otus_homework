use otus;

-- Вывод имени продукта и наименования категории
select p.name, pc.name from products p
    INNER JOIN product_categories pc on p.category_id = pc.id;

-- Вывод количества купленных товаров определенным пользователем
select u.first_name as 'имя', count(op.product_id) as 'кол-во купленных товаров' from orders o
    LEFT JOIN order_product op on o.id = op.order_id
    LEFT JOIN users u on o.user_id = u.id
group by u.first_name;

-- Вывод айдишников пользователей, к которых имя начинается на букву 'и'
select u.id from users u where first_name like 'И%';

-- Вывод товаров, у которых цена больше 100
select p.name, p.cost from products p where p.cost > 100;

-- Вывод товаров, которые стоят меньше 3000 и начинаются с буквы 'Р'
select p.name from products p where p.cost < 3000 AND p.name  like 'Р%';

-- Вывод товаров, у которых есть атрибут вес, или стоимость меньше 100;
select * from products p where json_extract(attributes_json, '$.weight') is not null OR cost < 1000;

-- Вывод товаров, у которых отстутствует джейсон атрибуты
select * from products p where attributes_json is null;
