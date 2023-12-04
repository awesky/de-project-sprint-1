# 1.3. Качество данных

## Оцените, насколько качественные данные хранятся в источнике.
Информация приведена только для значимых и/или используемых в построении витрины `dm_rfm_segments` полей.

Таблица `users` схемы `production` имеет следующие типы полей и ограничения (constraints):
`id`: int4, NOT NULL, PRIMARY KEY
`name`: varchar(2048), NULL
`login`: varchar(2048), NOT NULL
Проверка качества данных:
```SQL
SELECT
    -- Всего пользователей
    COUNT(id) AS total_users_id,
    -- Всего пользователей с уникальным id
    COUNT(DISTINCT id) AS uniq_users_id,
    -- Всего NOT NULL зачений id пользователей
    SUM(CASE WHEN id IS NULL THEN 0 ELSE 1 END) AS user_id_not_null,
    -- Всего уникальных логинов пользователей
    COUNT(DISTINCT name) AS uniq_login,
    -- Всего NOT NULL зачений логинов пользователей
    SUM(CASE WHEN name IS NULL THEN 0 ELSE 1 END) AS login_not_null   
FROM production.users;
```
Результат:
```
total_users_id|uniq_users_id|user_id_not_null|uniq_login|login_not_null|
--------------+-------------+----------------+----------+--------------+
          1000|         1000|            1000|      1000|          1000|
```
В таблице `users` схемы `production`:
- отсутствует дублирование и/или пропуски данных;
- перепутаны местами поля `name` и `login`, что не влияет на построение витрины `dm_rfm_segments`, но порождает риск заведения значения NOT NULL в поле `name` (фактически испольхуется для хранения логина).


Таблица `orderstatuses` схемы `production` имеет следующие типы полей и ограничения (constraints):
`id`: int4, NOT NULL, PRIMARY KEY
`key`: varchar(255), NOT NULL
Проверка качества данных:
```SQL
SELECT
    -- Всего статусов
    COUNT(id) AS total_status_id,
    -- Всего статусов с уникальным id
    COUNT(DISTINCT id) AS uniq_status_id,
    -- Всего NOT NULL зачений id статусов
    SUM(CASE WHEN id IS NULL THEN 0 ELSE 1 END) AS status_id_not_null,
    -- Всего уникальных наименований статусов
    COUNT(DISTINCT key) AS uniq_key,
    -- Всего NOT NULL наименований статусов
    SUM(CASE WHEN key IS NULL THEN 0 ELSE 1 END) AS key_not_null   
FROM production.orderstatuses;
```
Результат:
```
total_status_id|uniq_status_id|status_id_not_null|uniq_key|key_not_null|
---------------+--------------+------------------+--------+------------+
              5|             5|                 5|       5|           5|
```
В таблице `orderstatuses` схемы `production`:
- отсутствует дублирование и/или пропуски данных.


Таблица `orders` схемы `production` имеет следующие типы полей и ограничения (constraints):
`order_id`: int4, NOT NULL, PRIMARY KEY
`user_id`: int4, NOT NULL
`order_ts`: timestamp, NOT NULL
`status`: int4, NOT NULL
`payment`: numeric(19, 5), NOT NULL
Проверка качества данных:
```SQL
SELECT
    -- Всего заказов
    COUNT(order_id) AS total_order_id,
    -- Всего заказов с уникальным id
    COUNT(DISTINCT order_id) AS uniq_order_id,
    -- Всего NOT NULL зачений order_id
    SUM(CASE WHEN order_id IS NULL THEN 0 ELSE 1 END) AS order_id_not_null,
    -- Всего NOT NULL зачений user_id
    SUM(CASE WHEN user_id IS NULL THEN 0 ELSE 1 END) AS user_id_not_null
    -- Всего NOT NULL зачений order_ts
    SUM(CASE WHEN order_ts IS NULL THEN 0 ELSE 1 END) AS order_ts_not_null
    -- Всего NOT NULL зачений status
    SUM(CASE WHEN status IS NULL THEN 0 ELSE 1 END) AS status_not_null
    -- Всего NOT NULL зачений payment
    SUM(CASE WHEN payment IS NULL THEN 0 ELSE 1 END) AS payment_not_null
FROM production.orders;
```
Результат:
```
total_order_id|uniq_order_id|order_id_not_null|user_id_not_null|order_ts_not_null|status_not_null|payment_not_null|
--------------+-------------+-----------------+----------------+-----------------+---------------+----------------+
         10000|        10000|            10000|           10000|            10000|          10000|           10000|
```

Проверка консистентности данных таблиц `orders` и `users` схемы `production`:
```SQL
SELECT
    -- Выбор order_id, в котором указан ошибочный пользователь
	orders.order_id,
    -- Ошибочный пользователь user_id
	orders.user_id AS wrong_user_id
FROM production.orders AS orders
    LEFT JOIN production.users AS users
    ON users.id = orders.user_id
WHERE users.id IS NULL
```
Результат: несоответствий не выявлено
```
order_id|wrong_user_id|
--------+-------------+
```

Проверка консистентности данных таблиц `orders` и `orderstatuses` схемы `production`:
```SQL
SELECT
    -- Выбор order_id, в котором указан ошибочный статус
	orders.order_id,
    -- Ошибочный статус order_id
	orders.status AS wrong_order_status
FROM production.orders AS orders
    LEFT JOIN production.orderstatuses AS statuses
    ON statuses.id = orders.status
WHERE statuses.id IS NULL
```
Результат:
```
order_id|wrong_user_id|
--------+-------------+
```

В таблице `orders` схемы `production`:
- отсутствует дублирование и/или пропуски данных;
- отсутствует связь с таблицей `users` (отсутствует FOREIGN KEY поля `user_id`), но данные консистентны;
- отсутствует связь с таблицей `orderstatuses` (отсутствует FOREIGN KEY поля `status`), но данные консистентны;
- несоответствий со смежными таблицами `users` и `orderstatuses` не вывлено.


Таблица `orderstatuslog` схемы `production` имеет следующие типы полей и ограничения (constraints):
`id`: int4, NOT NULL, PRIMARY KEY
`order_id`: int4, NOT NULL, UNIQUE (order_id, status_id), FOREIGN KEY (orders_pkey)
`status_id`: int4, NOT NULL, FOREIGN KEY (orderstatuses_pkey)
`dttm`: timestamp, NOT NULL
Проверка качества данных:
```SQL
SELECT
    -- Всего записей статусов заказов id
    COUNT(id) AS total_order_status_id,
    -- Всего записей статусов заказов с уникальным id
    COUNT(DISTINCT id) AS uniq_order_status_id,
    -- Всего NOT NULL зачений записей статусов заказов id
    SUM(CASE WHEN id IS NULL THEN 0 ELSE 1 END) AS order_status_id_not_null,
    -- Всего NOT NULL зачений order_id
    SUM(CASE WHEN order_id IS NULL THEN 0 ELSE 1 END) AS order_id_not_null
    -- Всего NOT NULL зачений status_id
    SUM(CASE WHEN status_id IS NULL THEN 0 ELSE 1 END) AS status_id_not_null
    -- Всего NOT NULL зачений dttm
    SUM(CASE WHEN dttm IS NULL THEN 0 ELSE 1 END) AS dttm_not_null
FROM production.orderstatuslog;
```
Результат:
```
total_order_status_id|uniq_order_status_id|order_status_id_not_null|order_id_not_null|status_id_not_null|dttm_not_null|
---------------------+--------------------+------------------------+-----------------+------------------+-------------+
                29982|               29982|                   29982|            29982|             29982|        29982|
```

Проверка консистентности данных таблиц `orderstatuslog` и `orders` схемы `production`:
```SQL
SELECT
    -- Выбор id, в котором указан ошибочный статус
	orderstatuslog.id,
    -- Ошибочный order_id
	orderstatuslog.order_id AS wrong_order
FROM production.orderstatuslog AS orderstatuslog
    LEFT JOIN production.orders AS orders
    ON orders.order_id = orderstatuslog.order_id
WHERE orders.order_id IS NULL
```
Результат:
```
id|wrong_order|
--+-----------+
```

Проверка консистентности данных таблиц `orderstatuslog` и `orderstatuses` схемы `production`:
```SQL
SELECT
    -- Выбор id, в котором указан ошибочный статус
	orderstatuslog.id,
    -- Ошибочный статус order_id
	orderstatuslog.status_id AS wrong_order_status
FROM production.orderstatuslog AS orderstatuslog
    LEFT JOIN production.orderstatuses AS statuses
    ON statuses.id = orderstatuslog.status_id
WHERE statuses.id IS NULL
```
Результат:
```
id|wrong_order_status|
--+------------------+
```

Проверка ограничения `UNIQUE (order_id, status_id)` таблицы `orderstatuslog` схемы `production`:
```SQL
SELECT *
    FROM (
        SELECT orders.id, orders.order_id, orders.status_id as duplicated_status, COUNT(*) AS rate 
        FROM production.orderstatuslog AS orders, production.orderstatuslog AS statuses
        WHERE orders.order_id = statuses.order_id AND orders.status_id = statuses.status_id
        GROUP BY orders.id, orders.order_id
    ) AS statuses_count
WHERE statuses_count.rate > 1
ORDER BY order_id
```
Результат:
```
id|order_id|duplicated_status|rate|
--+--------+-----------------+----+
```
В таблице `orderstatuslog` схемы `production`:
- отсутствует дублирование и/или пропуски данных;
- несоответствий со смежными таблицами `orders` и `orderstatuses` не вывлено.

----
Вывод: данные таблиц схемы `production` удовлетворяют потребностям для построения витрины `dm_rfm_segments`.
