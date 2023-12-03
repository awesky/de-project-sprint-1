-- 3
-- Затем создайте документ datamart_query.sql и напишите в нём запрос,
-- который на основе данных, подготовленных в таблицах
-- analysis.tmp_rfm_recency,  analysis.tmp_rfm_frequency и analysis.tmp_rfm_monetary_value,
-- заполнит витрину analysis.dm_rfm_segments
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

-- Скопируйте в этот же файл первые десять строк из полученной таблицы, отсортированные по user_id.
-- Это значит, что нужно скопировать user_id и соответствующие им параметры RFM
-- для 10 пользователей с минимальными user_id.
SELECT * 
FROM analysis.dm_rfm_segments
ORDER BY user_id
LIMIT 10;
