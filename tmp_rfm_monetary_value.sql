-- 3
-- в документе tmp_rfm_monetary_value.sql  — 
-- SQL-запрос для заполнения таблицы analysis.tmp_rfm_monetary_value
INSERT INTO analysis.tmp_rfm_monetary_value (user_id, monetary_value)
-- Собираем данные количества успешных заказов для каждого пользователя
WITH sum_success_orders AS (
    SELECT
        user_id,
        sum(payment) AS orders_count
    FROM
        analysis.orders
    WHERE
        -- В витрине нужны данные с начала 2022 года
        DATE_TRUNC('year', order_ts) >= '2022-01-01' AND
        -- Успешный заказ: status = 4 ("Closed")
        status = 4
    GROUP BY user_id
)

-- Формируем данные для добавления в analysis.tmp_rfm_monetary_value
SELECT
    users.id AS user_id,
    -- Ранжируем по 5 группам, заменив NULL на 0
    NTILE(5) OVER(ORDER BY COALESCE(orders.orders_count, 0)) AS monetary_value
FROM
    analysis.users AS users
	LEFT JOIN sum_success_orders AS orders ON orders.user_id = users.id
    -- Если пользователь не имеет успешного заказа
    -- (users.id отсутствует в sum_success_orders.user_id):
    -- orders_count -> NULL
