-- 3
-- В документе tmp_rfm_frequency.sql
-- напишите SQL-запрос для заполнения таблицы analysis.tmp_rfm_frequency
INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
-- Собираем данные количества успешных заказов для каждого пользователя
WITH count_success_orders AS (
    SELECT
        user_id,
        count(1) AS orders_count
    FROM
        analysis.orders
    WHERE
        -- В витрине нужны данные с начала 2022 года
        DATE_TRUNC('year', order_ts) >= '2022-01-01' AND
        -- Успешный заказ: status = 4 ("Closed")
        status = 4
    GROUP BY user_id
)

-- Формируем данные для добавления в analysis.tmp_rfm_frequency
SELECT
    users.id AS user_id,    
    -- Ранжируем по 5 группам, заменив NULL на 0
    NTILE(5) OVER(ORDER BY COALESCE(orders.orders_count, 0)) AS frequency
FROM
    analysis.users AS users
	LEFT JOIN count_success_orders AS orders ON orders.user_id = users.id
    -- Если пользователь не имеет успешного заказа
    -- (users.id отсутствует в count_success_orders.user_id):
    -- orders_count -> NULL
    