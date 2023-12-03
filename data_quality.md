# 1.3. Качество данных

## Оцените, насколько качественные данные хранятся в источнике.
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
