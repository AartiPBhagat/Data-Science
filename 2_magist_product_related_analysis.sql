---------------------------------------------------------------------
-- Business questions related to product - Magist
---------------------------------------------------------------------
USE magist;
---------------------------------------------------------------------
# 1. What categories of tech products does Magist have?
-- consoles_games, electronics, computers_accessories, pc_gamer, computers
-- considering eniac's concern - computer accessories is relavant

SELECT * FROM product_category_name_translation;

SELECT
	*,
	CASE
		WHEN product_category_name_english IN ('consoles_games','electronics','computers_accessories','pc_gamer','computers') THEN 'tech_product'
        ELSE 'non_tech_product'
        END AS main_category
FROM product_category_name_translation;

---------------------------------------------------------------------
# number products for each tech categories and percentage:
-- computer accessories (informatica_acessorios)- 1639 - ~5%

SELECT COUNT(DISTINCT product_id) FROM products; #32951

SELECT product_category_name, COUNT(DISTINCT product_id) AS product_count,
		ROUND((COUNT(DISTINCT product_id)*100/(SELECT COUNT(DISTINCT product_id) FROM products)),2) AS perc_product_count
FROM products
WHERE product_category_name IN ('informatica_acessorios', 'eletronicos', 'consoles_games', 'pc_gamer', 'pcs')
GROUP BY product_category_name;


-------------------------------------------------------------------------------------------------------------------------------------------------------------
# 2. How many products of these tech categories have been sold (within the time window of the database snapshot)?
# What percentage does that represent from the overall number of products sold?


WITH TechProductSold AS (
		SELECT b.product_category_name, COUNT(product_id) AS n_products_sold
		FROM order_items a
		LEFT JOIN products b USING (product_id)
		WHERE b.product_category_name IN ('informatica_acessorios', 'eletronicos', 'consoles_games', 'pc_gamer', 'pcs')
		GROUP BY product_category_name
		ORDER BY n_products_sold DESC) ,
	 
     TotalProductSold AS (
		SELECT COUNT(product_id) AS toal_products_sold
        FROM order_items)
        
SELECT 
	product_category_name,
    n_products_sold,
    ROUND(( n_products_sold * 100.0 / toal_products_sold ),2) AS percentage_sold
FROM
	TechProductSold,
    TotalProductSold;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
# 3. What’s the average price of the products being sold? # 120.65

SELECT ROUND(AVG(price),2) AS avg_product_price
FROM order_items
WHERE price IS NOT NULL;

---------------------------------------------------------------------
-- the average price of tech product : # 116.51 informatica_acessorios

SELECT ROUND(AVG(price),2) AS avg_product_price
FROM order_items
LEFT JOIN products USING (product_id)
WHERE product_category_name IN ('informatica_acessorios') AND
		price IS NOT NULL;
        
---------------------------------------------------------------------
-- AVERAGE ORDER VALUE = 137.75

SELECT ROUND(AVG(order_value),2) AS avg_order_value
FROM 
	(SELECT SUM(price) AS order_value, order_id
     FROM order_items
     WHERE price IS NOT NULL
     GROUP BY order_id) AS price_order;
     
---------------------------------------------------------------------
-- avg order value for informatica_acessorios 136.34

SELECT ROUND(AVG(order_value),2) AS avg_order_value
FROM 
	(SELECT SUM(price) AS order_value, order_id
     FROM order_items
     LEFT JOIN products USING (product_id)
     WHERE product_category_name = 'informatica_acessorios' AND price IS NOT NULL
     GROUP BY order_id) AS price_order;

---------------------------------------------------------------------
-- AVERAGE PAYMENT VALUE 154.1 

SELECT ROUND(AVG(payment_value),2) # 154.1
FROM order_payments
WHERE payment_value IS NOT NULL;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
# 4. Are expensive tech products popular?

--  query for creating category based on price
SELECT product_id, product_category_name, price,
				CASE
					WHEN price >= 1499 THEN '1_expensive'
					WHEN price < 1499 AND price >= 499 THEN '2_moderate'
					WHEN price < 499 THEN '3_cheap'
					END AS 'price_range'
FROM order_items
LEFT JOIN products USING (product_id)
ORDER BY price_range, price desc;

---------------------------------------------------------------------
-- final query for all products
-- low dmenad for high end product

WITH product_price_range AS (
		SELECT product_id, price,
				CASE
					WHEN price >= 1199 THEN '1_expensive'
					WHEN price < 1199 AND price >= 499 THEN '2_moderate'
					WHEN price < 499 THEN '3_cheap'
					END AS 'price_range'
		FROM order_items
        WHERE product_id IN (product_id))
        
SELECT
	CASE WHEN price_range IS NULL THEN 'total' ELSE price_range END AS price_range,
    COUNT(product_id) AS n_product_sold
FROM product_price_range
GROUP BY price_range
WITH ROLLUP;

---------------------------------------------------------------------
-- only computer accessories - low demand for high end tech accessories

WITH tech_product_price_cat AS(
			SELECT
				product_id, product_category_name, price,
				CASE
					WHEN price >= 1199 THEN '1_expensive'
					WHEN price < 1199 AND price >= 499 THEN '2_moderate'
					WHEN price < 499 THEN '3_cheap'
					END AS 'price_range'
			FROM order_items
			LEFT JOIN products USING (product_id)
			WHERE product_category_name = 'informatica_acessorios')
SELECT
	CASE WHEN price_range IS NULL THEN 'total' ELSE price_range END AS price_range,
    COUNT(product_id) AS n_product_sold
FROM tech_product_price_cat
WHERE price IS NOT NULL
GROUP BY price_range
WITH ROLLUP;

---------------------------------------------------------------------
-- check for other possible tech products considered before:
-- low demand for high end tech products

WITH tech_product_price_cat AS(
			SELECT
				product_id, product_category_name, price,
				CASE
					WHEN price >= 1999 THEN '1_expensive'
					WHEN price < 1999 AND price >= 1499 THEN '2_moderate'
					WHEN price < 1499 AND price >=  999 THEN '4_economic1'
					WHEN price < 999 THEN '5_low'
					END AS 'price_range'
			FROM order_items
			LEFT JOIN products USING (product_id)
			WHERE product_category_name IN ('informatica_acessorios','eletronicos', 'consoles_games', 'pc_gamer', 'pcs'))
SELECT
	CASE WHEN price_range IS NULL THEN 'total' ELSE price_range END AS price_range,
    COUNT(product_id) AS n_product_sold
FROM tech_product_price_cat
GROUP BY price_range
WITH ROLLUP;

---------------------------------------------------------------------
-- How many expensive (above 499€) items are there? 84
-- number of moderate and expensive products are low, so clubed as expensive

SELECT COUNT(DISTINCT p.product_id)
FROM order_items AS o
LEFT JOIN products AS p
USING (product_id)
WHERE price >= 499 AND p.product_category_name = "informatica_acessorios";


-- How many items above Eniac's average item price (540€) are there? 74

SELECT COUNT(DISTINCT p.product_id)
FROM order_items AS o
LEFT JOIN products AS p
USING (product_id)
WHERE price >= 540 AND p.product_category_name = "informatica_acessorios";