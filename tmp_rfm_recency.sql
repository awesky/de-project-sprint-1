-- 3
-- создайте документ tmp_rfm_recency.sql.
-- В нём напишите SQL-запрос для заполнения таблицы analysis.tmp_rfm_recency

INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
-- Собираем данные последнего успешного заказа для каждого пользователя
WITH last_success_orders AS (
    SELECT
        user_id,
        MAX(order_ts) AS last_order_date
    FROM
        analysis.orders
    WHERE
        -- В витрине нужны данные с начала 2022 года
        DATE_TRUNC('year', order_ts) >= '2022-01-01' AND
        -- Успешный заказ: status = 4 ("Closed")
        status = 4
    GROUP BY user_id
)

-- Формируем данные для добавления в analysis.tmp_rfm_recency
SELECT
    users.id AS user_id,
    -- Ранжируем по 5 группам
    NTILE(5) OVER(ORDER BY orders.last_order_date) AS recency
FROM
    analysis.users AS users
	LEFT JOIN last_success_orders AS orders ON orders.user_id = users.id
    -- Если пользователь не имеет успешного заказа
    -- (users.id отсутствует в last_success_orders.user_id):
    -- last_order_date -> NULL
    