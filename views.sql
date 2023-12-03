-- 1
-- Сделайте представление для таблиц из базы production.
-- Вас попросили обращаться только к объектам из схемы analysis при расчёте витрины.
-- Чтобы не дублировать данные, которые находятся в этой же базе, сделайте представления.
-- Представления будут находиться в схеме analysis и отображать данные из схемы production. 
-- Напишите SQL-запросы, чтобы создать пять представлений (по одному на каждую таблицу):
-- Users,
-- OrderItems,
-- OrderStatuses,
-- Products,
-- Orders.
-- Выполните написанные SQL-скрипты.
-- Создайте документ views.sql. В этот документ вставьте код создания представлений.
CREATE OR REPLACE VIEW analysis.users AS SELECT * FROM production.users;
CREATE OR REPLACE VIEW analysis.orders AS SELECT * FROM production.orders;
CREATE OR REPLACE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE OR REPLACE VIEW analysis.orderstatuslog AS SELECT * FROM production.orderstatuslog;

-- Не используется:
CREATE OR REPLACE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE OR REPLACE VIEW analysis.products AS SELECT * FROM production.products;
