# Создание процедуры, которая выводит список продуктов
drop procedure if exists otus.get_products;
delimiter //
CREATE PROCEDURE otus.get_products(
    IN use_sort boolean,            # флаг использования сортировки
    IN sort_field_name CHAR(10),    # наименование колонки по которой сортировать
    in sort_type CHAR(4),           # тип сортировки (ASC, DESC)
    IN min_cost INT,                # фильтр по минимальной стоимости
    IN max_cost INT,                # фильтр по максимальной стоимости
    IN product_category_id INT,     # фильтр по категории продуктов
    IN limit_count INT,             # лимит по записям
    IN offset_count INT,            # смещение
    OUT sql_text TEXT)              # выполняемый запрос
BEGIN

    SET @first = false;
    SET @s = CONCAT('SELECT * FROM otus.products p WHERE 1=1 ');

    if (min_cost is not null) then
        if (@first) then SET @first = false; else SET @s = CONCAT(@s, ' AND '); end if;
        SET @min_cost_filter = CONCAT('p.cost >= ', min_cost);
        SET @s = CONCAT(@s, @min_cost_filter);
    end if;

    if (max_cost is not null) then
        if (@first) then SET @first = false; else SET @s = CONCAT(@s, ' AND '); end if;
        SET @max_cost_filter = CONCAT('p.cost <= ', max_cost);
        SET @s = CONCAT(@s, @max_cost_filter);
    end if;

    if (product_category_id is not null) then
        if (@first) then SET @first = false; else SET @s = CONCAT(@s, ' AND '); end if;
        SET @product_category_id_filter = CONCAT('p.category_id = ', product_category_id);
        SET @s = CONCAT(@s, @product_category_id_filter);
    end if;

    if (use_sort) then
        SET @s = CONCAT(@s, ' ORDER BY p.');
        SET @s = CONCAT(@s, sort_field_name);
        SET @s = CONCAT(@s, ' ');
        SET @s = CONCAT(@s, sort_type);
    end if;

    if (limit_count is not null) then
        SET @s = CONCAT(@s, ' LIMIT ');
        SET @s = CONCAT(@s, limit_count);
    end if;

    if (offset_count is not null) then
        SET @s = CONCAT(@s, ' OFFSET ');
        SET @s = CONCAT(@s, offset_count);
    end if;

    SELECT @s INTO sql_text;
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//
delimiter ;

# Вызов процедуры, которая выводит список продуктов
CALL get_products(true, 'name', 'ASC', 100, 1000, 3, 1, 1, @products);
SELECT @products;

# создание пользователя client и назначение ему прав на вызов процедуры get_products
CREATE USER IF NOT EXISTS 'client'@'docker-mysql' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON otus.* TO 'client'@'docker-mysql';
GRANT EXECUTE ON PROCEDURE otus.get_products TO 'client'@'docker-mysql';


# Создание процедуры, которая выводит список заказов
drop procedure if exists otus.get_orders;
delimiter //
CREATE PROCEDURE otus.get_orders(
    IN  group_column_name VARCHAR(20),  # название колонки, по которой выполняется группировка
    IN  interval_type     VARCHAR(20),  # тип интервала (день, неделя, месяц, год)
    IN  interval_count    VARCHAR(20),  # количество интервалов до текущего момента
    OUT sql_text TEXT)                  # выполняемый запрос
BEGIN
    SET @s = CONCAT('SELECT o.', group_column_name);
    SET @s = CONCAT(@s, ', SUM(op.count * p.cost)');

    SET @s = CONCAT(@s, '
        from otus.orders o inner
            join order_product op on o.id = op.order_id inner
            join products p on op.product_id = p.id
        WHERE o.creation_datetime between DATE(NOW() - INTERVAL ');
    SET @s = CONCAT(@s, interval_count);
    SET @s = CONCAT(@s, ' ');
    SET @s = CONCAT(@s, interval_type);
    SET @s = CONCAT(@s, ') and NOW()
                            GROUP BY o.');
    SET @s = CONCAT(@s, group_column_name);

    SELECT @s INTO sql_text;
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//
delimiter ;

# Вызов процедуры, которая выводит список продуктов
CALL get_orders('user_id', 'YEAR', 1, @orders);
SELECT @orders;

# создание пользователя manager и назначение ему прав на вызов процедуры get_orders
CREATE USER IF NOT EXISTS 'manager'@'docker-mysql' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON otus.* TO 'manager'@'docker-mysql';
GRANT EXECUTE ON PROCEDURE otus.get_orders TO 'manager'@'docker-mysql';