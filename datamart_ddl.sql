-- 2
-- Напишите DDL-запрос для создания витрины.
-- Далее вам необходимо создать витрину. Напишите запрос с CREATE TABLE и
-- выполните его на предоставленной базе данных в схеме analysis.
-- Помните, что при создании таблицы необходимо учитывать названия полей, типы данных и ограничения.
-- Создайте документ datamart_ddl.sql и сохраните в него написанный запрос.
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
