-- 4
-- Доработка представлений
-- Витрина готова. Вы сдали её заказчикам. 
-- Через некоторое время вам пишет менеджер и сообщает, что витрина больше не собирается.
-- Вы начинаете разбираться, в чём причина, и выясняете, что бэкенд-разработчики приложения
-- обновили структуру данных в схеме production: в таблице Orders больше нет поля status.
-- А это поле необходимо, потому что для анализа нужно выбрать только успешно выполненные заказы со статусом closed. 
-- Вместо поля с одним статусом разработчики добавили таблицу для журналирования всех
-- изменений статусов заказов — production.OrderStatusLog.

-- Структура таблицы production.OrderStatusLog: 
-- id — синтетический автогенерируемый идентификатор записи,
-- order_id — идентификатор заказа, внешний ключ на таблицу production.Orders,
-- status_id — идентификатор статуса, внешний ключ на таблицу статусов заказов production.OrderStatuses,
-- dttm — дата и время получения заказом этого статуса.

-- Чтобы ваш скрипт по расчёту витрины продолжил работать, вам необходимо внести изменения в то,
-- как формируется представление analysis.Orders: вернуть в него поле status.
-- Значение в этом поле должно соответствовать последнему по времени статусу из таблицы production.OrderStatusLog.
-- Для проверки предоставьте код на языке SQL, который обновляет представление analysis.Orders.

-- Создайте документ orders_view.sql и сохраните в нём написанный запрос.

CREATE OR REPLACE view analysis.orders AS
-- Собираем данные последннего изменения для каждого заказа
WITH last_order_status as (
	SELECT
		status_log.order_id as order_id,
		status_log.status_id as status_id,
		status_log.dttm as dttm
	FROM (
		SELECT
			order_id,
			MAX(dttm) AS dttm
		FROM production.orderstatuslog
		GROUP BY order_id
	) AS last_update
	INNER JOIN production.orderstatuslog AS status_log
		ON status_log.order_id = last_update.order_id AND
		status_log.dttm = last_update.dttm
)
-- Формируем данные для создания view analysis.orders
SELECT
    orders.order_id, 
	order_status.dttm AS order_ts, 
	orders.user_id, 
	orders.payment, 
	order_status.status_id as status
FROM
    production.orders AS orders
    LEFT JOIN last_order_status as order_status
        ON
        order_status.order_id = orders.order_id
