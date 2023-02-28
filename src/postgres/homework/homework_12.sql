-- Создание таблицы со статистикой
CREATE TABLE otus_db_yaos.otus.statistic
(
    player_name VARCHAR(100) NOT NULL,
    player_id   INT          NOT NULL,
    year_game   SMALLINT     NOT NULL CHECK (year_game > 0),
    points      DECIMAL(12, 2) CHECK (points >= 0),
    PRIMARY KEY (player_name, year_game)
);

-- Заполнение таблицы данными
INSERT INTO otus_db_yaos.otus.statistic(player_name, player_id, year_game, points)
VALUES ('Mike', 1, 2018, 18),
       ('Jack', 2, 2018, 14),
       ('Jackie', 3, 2018, 30),
       ('Jet', 4, 2018, 30),
       ('Luke', 1, 2019, 16),
       ('Mike', 2, 2019, 14),
       ('Jack', 3, 2019, 15),
       ('Jackie', 4, 2019, 28),
       ('Jet', 5, 2019, 25),
       ('Luke', 1, 2020, 19),
       ('Mike', 2, 2020, 17),
       ('Jack', 3, 2020, 18),
       ('Jackie', 4, 2020, 29),
       ('Jet', 5, 2020, 27);

-- Получение суммы очков с группировкой и сортировкой по годам
SELECT s.year_game, sum(s.points) AS points_by_year
FROM otus_db_yaos.otus.statistic AS s
GROUP BY s.year_game
ORDER BY year_game DESC;

-- Тоже самое, но при помощи CTE
WITH stats AS (SELECT s.year_game, SUM(s.points)
               FROM otus_db_yaos.otus.statistic AS s
               GROUP BY s.year_game
               ORDER BY year_game DESC)
SELECT *
FROM stats;

-- Получение кол-ва очков по всем игрокам за текущий код и за предыдущий, используя функцию LAG
WITH stats AS (SELECT s.year_game, SUM(s.points) AS sum
               FROM otus_db_yaos.otus.statistic AS s
               GROUP BY s.year_game
               ORDER BY year_game DESC)
SELECT s.year_game,
       s.sum                                     AS cur_year_points,
       LAG(s.sum, 1) OVER (ORDER BY s.year_game) AS previous_year_points
FROM stats AS s;

-- Удаление таблицы
drop table if exists otus_db_yaos.otus.statistic cascade;
