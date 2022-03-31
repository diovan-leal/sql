-- SQL 1
SELECT 
	IFNULL(SUM(amount), 0) - IFNULL(SUM(discount), 0) totalSale,
	SUM(CASE WHEN aop.status IN ('PENDING', 'PAYMENT_CREATED') THEN IFNULL(aop.amount, 0) - IFNULL(aop.discount, 0)  ELSE 0 END) pending_sale,
    SUM(CASE WHEN aop.status IN ('PAYMENT_OVERDUE', 'PAYMENT_DELETED', 'PAYMENT_REFUNDED', 'PAYMENT_CHARGEBACK_REQUESTED', 'PAYMENT_CHARGEBACK_DISPUTE', 'PAYMENT_AWAITING_CHARGEBACK_REVERSAL') THEN IFNULL(aop.amount, 0) - IFNULL(aop.discount, 0)  ELSE 0 END) canceled_sale,
    GROUP_CONCAT(aot.price),
    GROUP_CONCAT(aot.order_id)
  FROM atl_order_payment aop
  LEFT JOIN atl_order_ticket aot ON aot.order_id = aop.order_id
 WHERE aop.event_id = 33
 
 ---------------------------------------------------------------
 
 
