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
  
  --------------------------------------------
  -- SQL 4
  
  SELECT /*aot.price, aot.fee, aot.total, aot.quantity, aot.tax_type, aot.tax_value, sum(orders.total_value) as total_value,*/
	   sum(CASE 
	   		WHEN aot.fee = 0 
	   			THEN (aot.total - (aot.tax_value - aot.quantity)) - IFNULL(o.discount, 0) 
	   			ELSE aot.total - (aot.fee * aot.quantity) - IFNULL(o.discount, 0)
	   		END) valueToReceive
  FROM atl_order_ticket aot
  JOIN (SELECT ao.id,
  			   ao.discount
  		  FROM atl_order ao
 		 WHERE ao.event_id = 250
   		   AND ao.is_deleted = 0
   		   AND ao.status_id IN (4, 5)) o ON o.id = aot.order_id 
  LEFT JOIN (SELECT aop2.order_id, aop2.pay_id, aop2.amount total_value
  			   FROM  atl_order_payment aop2
 			  WHERE aop2.order_id IN (SELECT ao.id 
  										FROM atl_order ao
 									   WHERE ao.event_id = 250
   										 AND  ao.is_deleted = 0
   										 AND ao.status_id IN (4, 5))
   				AND aop2.pay_id IS NOT NULL 
   				AND aop2.pay_id  <> ''
   				AND aop2.pay_id NOT IN ('PAYMENT_OVERDUE', 'PAYMENT_DELETED', 'PENDING', 'PAYMENT_REFUNDED')
		   GROUP BY aop2.pay_id, aop2.amount, aop2.order_id) orders ON orders.order_id = aot.order_id
WHERE aot.order_id IN (SELECT ao.id 
  						 FROM atl_order ao
 						WHERE ao.event_id = 250
   						  AND   ao.is_deleted = 0
   						  AND ao.status_id IN (4, 5))
  AND aot.price IS NOT NULL
  /*GROUP BY aot.id, 
           aot.fee,
           aot.total,
		   aot.quantity, 
		   aot.tax_type, 
		   aot.tax_value, 
		   orders.order_id*/

 
 
