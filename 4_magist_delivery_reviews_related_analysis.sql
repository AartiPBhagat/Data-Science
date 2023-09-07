---------------------------------------------------------------------
-- Business questions in relation to the delivery time and reviews
---------------------------------------------------------------------
USE magist;
---------------------------------------------------------------------
# 1. What’s the average time between the order being placed and the product being delivered? 12.50 days

-- all product : 12 days

SELECT AVG(datediff(order_delivered_customer_date, order_purchase_timestamp)) AS delivery_time
FROM orders
WHERE order_status = 'delivered'
HAVING delivery_time IS NOT NULL;

---------------------------------------------------------------------
-- tech category : 13 days

SELECT AVG(datediff(order_delivered_customer_date, order_purchase_timestamp)) AS delivery_time
FROM orders
JOIN order_items USING (order_id)
JOIN products USING (product_id)
WHERE
	product_category_name='informatica_acessorios' AND
 	order_status = 'delivered'
HAVING delivery_time IS NOT NULL;

---------------------------------------------------------------------
# maximun days 209 minumun 0 day : all product

SELECT
	max(datediff(order_delivered_customer_date, order_purchase_timestamp)) AS max_delivery_time,
    min(datediff(order_delivered_customer_date, order_purchase_timestamp)) AS min_delivery_time
FROM orders
WHERE order_status = 'delivered'
HAVING max_delivery_time IS NOT NULL;

-----------------------------------------------------------------------
-- comparision between groups of actual delivery time range(days) 

WITH act_delivery_time AS (
		SELECT
			order_id, customer_id, 
			datediff(order_delivered_customer_date, order_purchase_timestamp) AS delivery_time
		FROM orders
		HAVING delivery_time IS NOT NULL )
        
SELECT
	CASE WHEN delivery_time <= 2 THEN '1__0-2 DAYS'
		 WHEN delivery_time <= 5 AND delivery_time > 2 THEN '2__3-5 DAYS'
         WHEN delivery_time <= 10 AND delivery_time > 5 THEN '3__6-10 DAYS'
         WHEN delivery_time <= 20 AND delivery_time > 10 THEN '4__11-20 DAYS'
         WHEN delivery_time <= 50 AND delivery_time > 20 THEN '5__21-50 DAYS'
         WHEN delivery_time <= 209 AND delivery_time > 50 THEN '6__51-209 DAYS'
		 END AS act_delivery_time_range,
	COUNT(order_id)
FROM act_delivery_time A
JOIN order_items USING (order_id)
JOIN products USING (product_id)
WHERE											# to filter tech products
	product_category_name = 'informatica_acessorios'
GROUP BY act_delivery_time_range;

-----------------------------------------------------------------------
-- comparision between groups of estimate delivery time range(days) 

WITH est_delivery_time AS (
		SELECT
			order_id, customer_id, 
			datediff(order_estimated_delivery_date, order_purchase_timestamp) AS delivery_time
		FROM orders
		HAVING delivery_time IS NOT NULL )
        
SELECT
	CASE WHEN delivery_time <= 2 THEN '1__0-2 DAYS'
		 WHEN delivery_time <= 5 AND delivery_time > 2 THEN '2__3-5 DAYS'
         WHEN delivery_time <= 10 AND delivery_time > 5 THEN '3__6-10 DAYS'
         WHEN delivery_time <= 20 AND delivery_time > 10 THEN '4__11-20 DAYS'
         WHEN delivery_time <= 50 AND delivery_time > 20 THEN '5__21-50 DAYS'
         WHEN delivery_time <= 209 AND delivery_time > 50 THEN '6__51-209 DAYS'
		 END AS delivery_time_range,
	COUNT(order_id)
FROM est_delivery_time A
JOIN order_items USING (order_id)
JOIN products USING (product_id)
WHERE											# to filter tech products
	product_category_name = 'informatica_acessorios'
GROUP BY delivery_time_range;
-----------------------------------------------------------------------------------------
-- comparision between groups of ontime_delay(days)
-- overall good at estimating delivery time as well as meeting delivery time commitment

SELECT
			order_id, customer_id, 
			datediff(order_delivered_customer_date, order_estimated_delivery_date) AS ontime_delay_time
		FROM orders
		HAVING ontime_delay_time IS NOT NULL
        order by ontime_delay_time;
        
----------------------------------------------
WITH ontime_delay AS (
		SELECT
			order_id, customer_id, 
			datediff(order_delivered_customer_date, order_estimated_delivery_date) AS ontime_delay_time
		FROM orders
		HAVING ontime_delay_time IS NOT NULL )
        
SELECT
	CASE 
		 
         WHEN ontime_delay_time <= 0 THEN '0__Early_Delivery'
         WHEN ontime_delay_time <= 2 AND ontime_delay_time > 0 THEN '1__1-2 DAYS'
		 WHEN ontime_delay_time <= 5 AND ontime_delay_time > 2 THEN '2__3-5 DAYS'
         WHEN ontime_delay_time <= 10 AND ontime_delay_time > 5 THEN '3__6-10 DAYS'
         WHEN ontime_delay_time <= 20 AND ontime_delay_time > 10 THEN '4__11-20 DAYS'
         WHEN ontime_delay_time <= 50 AND ontime_delay_time > 20 THEN '5__21-50 DAYS'
         WHEN ontime_delay_time <= 209 AND ontime_delay_time > 50 THEN '6__51-150 DAYS'
		 END AS ontime_delay_time_range,
	COUNT(order_id)
FROM ontime_delay A
JOIN order_items USING (order_id)
JOIN products USING (product_id)
WHERE											# to filter tech products
	product_category_name = 'informatica_acessorios'
GROUP BY ontime_delay_time_range
ORDER BY ontime_delay_time_range;

----------------------------------------------------------------------------------------------------------------------------------- 
# 2. How many orders are delivered on time vs orders delivered with a delay?

-- for all products

-- ontime or early
SELECT count(order_id)
FROM orders
WHERE order_delivered_customer_date <= order_estimated_delivery_date ; # 88649

----------------------------------------------------
-- delayed        
SELECT count(order_id)
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date ; # 7827        

----------------------------------------------------
SELECT (88649/99441)*100;   #89.14% ontime_early
SELECT (7827/99441)*100;	#7.87% delayed

---------------------------------------------------------------------
# alternative 2 : for tech products only 

SELECT
	COUNT(order_id) AS total_orders,
    SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1 ELSE 0 END) AS orders_delivered_on_time,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS orders_delivered_with_delay
FROM orders
JOIN order_items USING (order_id)
JOIN products USING (product_id)
WHERE											# to filter tech products
	product_category_name = 'informatica_acessorios' AND
 	order_status = 'delivered';

-----------------------------------------------------------------------------------------------------------------------------------
# 3. Is there any pattern for delayed orders, e.g. big products being delayed more often?
-- there is not any specific relation between big prodcuts and delays.

SELECT
	product_weight_g AS weight,
	(product_length_cm*product_height_cm*product_width_cm) AS volume,
    DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) AS delay
FROM orders o
JOIN order_items oi USING(order_id)
JOIN products USING (product_id)
WHERE											# to filter tech products
	product_category_name = 'informatica_acessorios' AND
 	order_status = 'delivered'
HAVING delay > 0
ORDER BY volume DESC;

-----------------------------------------------------------------------------------------------------------------------------------
# number of reviews for different score - all products:

SELECT review_score, COUNT(*) as count_of_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

---------------------------------------------------------------------
# number of reviews for different score - tech products:

SELECT review_score, COUNT(*) as count_of_reviews
FROM order_reviews AS r 
LEFT JOIN orders AS o
ON r.order_id = o.order_id
LEFT JOIN order_items AS i
ON o.order_id = i.order_id
LEFT JOIN products AS p
ON i.product_id = p.product_id
WHERE p.product_category_name = "informatica_acessorios"
GROUP BY review_score
ORDER BY review_score;

---------------------------------------------------------------------
# Reviews categories : good review > 4 : (5,4) | bad reviews < 4 : (3,2,1) (for tech products)
-- approx 75% of all reviews are good reviews

SELECT COUNT(review_id) AS review_count,
	CASE 
		WHEN review_score >= 4 THEN  "good reviews"
        ELSE "bad reviews"
	END AS review_cat
FROM order_reviews AS r 
LEFT JOIN orders AS o
ON r.order_id = o.order_id
LEFT JOIN order_items AS i
ON o.order_id = i.order_id
LEFT JOIN products AS p
ON i.product_id = p.product_id
WHERE p.product_category_name = "informatica_acessorios"
GROUP BY review_cat;

