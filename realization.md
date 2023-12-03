# Витрина RFM

## 1.1. Выясните требования к целевой витрине.
Витрина должна располагаться в той же базе в схеме `analysis`.
Витрина должна состоять из таких полей:
`user_id`
`recency` (число от 1 до 5): Recency (пер. «давность») — сколько времени прошло с момента последнего заказа.
`frequency` (число от 1 до 5): Frequency (пер. «частота») — количество заказов.
`monetary_value` (число от 1 до 5): Monetary Value (пер. «денежная ценность») — сумма затрат клиента.
В витрине нужны данные с начала 2022 года.
Назовите витрину `dm_rfm_segments`.
Обновления не нужны.
Успешно выполненный заказ = заказ со статусом `Closed`.

## 1.2. Изучите структуру исходных данных.
Для построения витрины `analysis.dm_rfm_segments` используются следующие данные из схемы `production`:
`user_id`: `users.id`

`recency` (число от 1 до 5):
`users.id`, `orders.order_ts`, `orderstatuslog.order_id`, `orderstatuslog.status_id`, `orderstatuslog.dttm`

`frequency` (число от 1 до 5):
`users.id`, `orderstatuslog.order_id`, `orderstatuslog.status_id`, `orderstatuslog.dttm`

`monetary_value` (число от 1 до 5):
`users.id`, `orders.payment`, `orderstatuslog.order_id`, `orderstatuslog.status_id`, `orderstatuslog.dttm`

## 1.3. Проанализируйте качество данных
`data_quality.md`
Информация приведена только для значимых и/или используемых в построении витрины `dm_rfm_segments` полей.

Таблица `users` схемы `production` имеет следующие типы полей и ограничения (constraints):
`id`: int4, NOT NULL, PRIMARY KEY

Таблица `orders` схемы `production` имеет следующие типы полей и ограничения (constraints):
`order_id`: int4, NOT NULL, PRIMARY KEY
`user_id`: int4, NOT NULL
`order_ts`: timestamp, NOT NULL
`status`: int4, NOT NULL
`payment`: numeric(19, 5), NOT NULL

Таблица `orderstatuses` схемы `production` имеет следующие типы полей и ограничения (constraints):
`ìd`: int4, NOT NULL, PRIMARY KEY
`key`: varchar(255), NOT NULL

Таблица `orderstatuslog` схемы `production` имеет следующие типы полей и ограничения (constraints):
`id`: int4, NOT NULL, PRIMARY KEY
`order_id`: int4, NOT NULL, UNIQUE (order_id, status_id)
`status_id`: int4, NOT NULL
`dttm`: timestamp, NOT NULL

В таблице `orders` схемы `production` отсутствует связь с таблицей `users` (отсутствует FOREIGN KEY поля `user_id`).
В таблице `orders` схемы `production` отсутствует связь с таблицей `orderstatuses` (отсутствует FOREIGN KEY поля `status`).
В таблице `orderstatuslog` схемы `production` отсутствует связь с таблицей `orders` (отсутствует FOREIGN KEY поля `order_id`).
В таблице `orderstatuslog` схемы `production` отсутствует связь с таблицей `orderstatuses` (отсутствует FOREIGN KEY поля `status_id`).

В общем и целом установленные ограничения таблицы `orders` схемы `production` удовлетворяют потребностям для построения витрины `dm_rfm_segments`.
Однако консистентность данных в таблицах `orders` и `orderstatuslog` схемы `production` не обеспечивается должным образом.


## 1.4. Подготовьте витрину данных

### 1.4.1. Сделайте VIEW для таблиц из базы production.**
`views.sql`
```SQL
CREATE OR REPLACE VIEW analysis.users AS SELECT * FROM production.users;
CREATE OR REPLACE VIEW analysis.orders AS SELECT * FROM production.orders;
CREATE OR REPLACE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE OR REPLACE VIEW analysis.orderstatuslog AS SELECT * FROM production.orderstatuslog;

-- Не используется:
CREATE OR REPLACE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE OR REPLACE VIEW analysis.products AS SELECT * FROM production.products;
```

### 1.4.2. Напишите DDL-запрос для создания витрины.**
`datamart_ddl.sql`
```SQL
CREATE TABLE analysis.dm_rfm_segments (
    user_id INT4 PRIMARY KEY,
    recency SMALLINT CHECK(recency >= 1 AND recency <= 5),
    frequency SMALLINT CHECK(frequency >= 1 AND recency <= 5),
    monetary_value SMALLINT CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

CREATE TABLE analysis.tmp_rfm_recency (
    user_id INT4 NOT NULL PRIMARY KEY,
    recency SMALLINT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

CREATE TABLE analysis.tmp_rfm_frequency (
    user_id INT4 NOT NULL PRIMARY KEY,
    frequency SMALLINT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);

CREATE TABLE analysis.tmp_rfm_monetary_value (
    user_id INT4 NOT NULL PRIMARY KEY,
    monetary_value SMALLINT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);
```

### 1.4.3. Напишите SQL запрос для заполнения витрины
`datamart_query.sql`
```SQL
INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT
    users_data.id, 
    recency_data.recency,
    frequency_data.frequency,
    monetary_value_data.monetary_value 
FROM
    analysis.users AS users_data
    LEFT JOIN analysis.tmp_rfm_recency AS recency_data ON users_data.id = recency_data.user_id 
    LEFT JOIN analysis.tmp_rfm_frequency AS frequency_data ON users_data.id = frequency_data.user_id 
    LEFT JOIN analysis.tmp_rfm_monetary_value AS monetary_value_data ON users_data.id = monetary_value_data.user_id;

SELECT * 
FROM analysis.dm_rfm_segments
ORDER BY user_id
LIMIT 10;
```
