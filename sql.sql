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
 
 -- SQL 2
 
 SELECT SUM(aot.tax_value * aot.quantity) total_tax_value
   FROM atl_order_ticket aot
  WHERE aot.order_id IN (SELECT ao.id 
                            FROM atl_order ao
                           WHERE ao.event_id = 33)
    AND aot.price IS NOT NULL
    AND aot.order_id NOT IN (SELECT GROUP_CONCAT(aop.order_id)
    						   FROM atl_order_payment aop
    						  WHERE aop.event_id = 33
    						    AND aop.status NOT IN ('PAYMENT_OVERDUE', 'PAYMENT_DELETED', 'PENDING', 'PAYMENT_REFUNDED', 'PAYMENT_CHARGEBACK_REQUESTED', 'PAYMENT_CHARGEBACK_DISPUTE', 'PAYMENT_AWAITING_CHARGEBACK_REVERSAL')
    						    AND aop.pay_id IS NOT NULL)
						    
---------------------------------------------------------------
-- SQL 3

  SELECT CASE WHEN SUM(aop.amount) = 0 
  	      THEN 'PAYMENT_CONFIRMED' 
  	      ELSE 
  		CASE
  		     WHEN GROUP_CONCAT(DISTINCT aop.status) LIKE '%PAYMENT_CONFIRMED%' THEN 'PAYMENT_CONFIRMED'
  		     WHEN GROUP_CONCAT(DISTINCT aop.status) LIKE '%PAYMENT_RECEIVED%' THEN 'PAYMENT_CONFIRMED'
  		     WHEN GROUP_CONCAT(DISTINCT aop.status) LIKE '%PENDING%' THEN 'PENDING'
  		     ELSE GROUP_CONCAT(DISTINCT aop.status)
  		 END 
          END STAUS_PAYMENT,
  		SUM(aop.amount),
  		GROUP_CONCAT(DISTINCT aop.status) 
    FROM atl_order_payment aop
    WHERE aop.order_id IN (SELECT aut.order_id 
                             FROM atl_user_ticket aut)
  GROUP BY aop.order_id  

 
 
