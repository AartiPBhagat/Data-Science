---------------------------------------------------------------------
-- Tables exploration from Magist database
---------------------------------------------------------------------
USE magist;
---------------------------------------------------------------------
# 1. How many orders are there in the dataset?
# (99441)

SELECT COUNT(order_id) AS total_orders
FROM orders;

------------------------------------------------------------------------------------------
# 2. Are orders actually delivered?
# (96478)

SELECT 
    order_status,
    COUNT(order_id) AS total_orders_per_status
FROM orders
GROUP BY order_status;

------------------------------------------------------------------------------------------
# 3. Is Magist having user growth?
# Yes, for given time span and in terms of order place on magist.
-- During last 2 months - drastically low no of orders : data error or incomplete data(may be)

SELECT
	COUNT(DISTINCT CONCAT(YEAR(order_purchase_timestamp),'/',MONTH(order_purchase_timestamp)))
FROM orders;  # 25 months of data between 2016 to 2018

SELECT
	CONCAT(YEAR(order_purchase_timestamp),'/',MONTH(order_purchase_timestamp)) AS year_month_,
    COUNT(order_id)
FROM orders
GROUP BY year_month_
ORDER BY year_month_ ;
---------------------------------------------------------------------
-- order growth trend

SELECT COUNT(order_id),
EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
EXTRACT(MONTH FROM order_purchase_timestamp) AS month
FROM orders
WHERE order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;


SELECT COUNT(order_id),
EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
EXTRACT(MONTH FROM order_purchase_timestamp) AS month
FROM orders
WHERE order_status = "canceled"
GROUP BY year, month
ORDER BY year, month;

---------------------------------------------------------------------
# the last order they approved was: 08.08.2018, big batch of orders. After that only one order approved in September.

SELECT YEAR(order_approved_at) AS year_,
	MONTH(order_approved_at) AS month_, 
	DAY(order_approved_at) AS day_,
    count(*) orders_approved
FROM orders
WHERE order_approved_at IS NOT NULL
GROUP BY year_ , month_ , day_
ORDER BY year_ desc , month_ desc , day_  desc;

---------------------------------------------------------------------    
/* no. of orders made for given timespan is same as no. of customers listed, which means no
customer repetation on magist marketplace in given time period. */

SELECT
	COUNT(*),						# 99441
    COUNT(DISTINCT order_id),		# 99441
    COUNT(DISTINCT customer_id)	# 99441
FROM orders;

SELECT 
    COUNT(*),						#99441
    COUNT(DISTINCT customer_id)		#99441
FROM
    customers;
    
------------------------------------------------------------------------------------------    
# 4. How many products are there in the products table?
# (32951)
SELECT COUNT(DISTINCT product_id) AS products_count
FROM products;

------------------------------------------------------------------------------------------
# 5. Which are the categories with most products?
# Bed_bath_table(3029), sports_leisure(2867), furniture_decor(2657)

SELECT b.product_category_name_english, product_category_name, COUNT(DISTINCT product_id) AS product_count
FROM products AS a
LEFT JOIN product_category_name_translation AS b
	USING (product_category_name)
GROUP BY product_category_name
ORDER BY product_count DESC;

------------------------------------------------------------------------------------------
# 6. How many of those products were present in actual transactions?
# 32951 - same as in product table - all products sold atleat once

SELECT COUNT(DISTINCT product_id) AS product_in_tranc
FROM order_items;

------------------------------------------------------------------------------------------
# 7. What’s the price for the most expensive and cheapest products?
# cheapest = 0.85 , most_expensive = 6735

SELECT MIN(price) AS cheapest, MAX(price) AS most_expensive
FROM order_items;

------------------------------------------------------------------------------------------
# 8. What are the highest and lowest payment values?
# lowest = 0 OR 0.01, highest = 13664.1

SELECT MIN(payment_value) AS lowest, MAX(payment_value) AS highest
FROM order_payments;

-- to check if there is actully any payment with 0 value.
SELECT *
FROM order_payments
WHERE payment_value = 0;

------------------------------------------------------------------------------------------
# TOP 5 states

-- TOP 5 states based on order growth : SP,RJ,MG,RS,PR
SELECT count(order_id) AS total_orders, state
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN geo g ON c.customer_zip_code_prefix=g.zip_code_prefix
GROUP BY state
ORDER BY total_orders desc
LIMIT 5;

-- top 5 states based on revenue : SP,PR,MG,RJ,SC
SELECT SUM(price) AS revenue, state
FROM order_items o
LEFT JOIN sellers s ON o.seller_id = s.seller_id
LEFT JOIN geo g ON s.seller_zip_code_prefix=g.zip_code_prefix
GROUP BY state
ORDER BY revenue desc
LIMIT 5;
