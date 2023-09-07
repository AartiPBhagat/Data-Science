---------------------------------------------------------------------
-- Business questions related to magist sellers
---------------------------------------------------------------------
USE magist;
---------------------------------------------------------------------
# 1. How many months of data are included in the magist database? # 25 MONTHS

SELECT timestampdiff(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) AS no_of_months
FROM orders;


-------------------------------------------------------------------------------------------------------------------------------------------------------------
# 2. How many sellers are there?
-- total sellers : 3095
SELECT
    COUNT(DISTINCT seller_id) AS n_sellers
FROM sellers;

---------------------------------------------------------------------
-- How many Tech sellers are there?
# NUMBER OF  TECH SELLERS : 287 = 9.27%

SELECT
	b.main_category,
	COUNT(DISTINCT a.seller_id)
FROM order_items a
LEFT JOIN (SELECT
				product_id, product_category_name,
				CASE
					WHEN product_category_name = 'informatica_acessorios' THEN 'tech_accessories'
					ELSE 'non_tech_products'
					END AS 'main_category'
			FROM products) AS b USING (product_id)
GROUP BY b.main_category;

-- PERCENTAGE OF TOTAL
SELECT (3009/(3095))*100,
		(287/(3095))*100;
        
---------------------------------------------------------------------
--  What percentage of overall sellers are Tech sellers?
 
 SELECT
    b.main_category,  # the category
    COUNT(DISTINCT a.seller_id), # distinct sellers
    ROUND(COUNT(DISTINCT a.seller_id) * 100.0 / (SELECT COUNT(DISTINCT seller_id) FROM order_items WHERE seller_id IS NOT NULL), 2) AS percentage_total 
FROM order_items a
LEFT JOIN (SELECT
				product_id, product_category_name,
				CASE
					WHEN product_category_name = 'informatica_acessorios' THEN 'tech_accessories'
					ELSE 'non_tech_products'
					END AS 'main_category'
			FROM products) AS b USING (product_id)
WHERE a.seller_id IS NOT NULL
GROUP BY b.main_category;

-- (difference in percentage total and number total is due to reason : there are sellers that sell both tech and non tech items)

-----------------------------------------------------------------------------------------------------------------------------------
# 3. What is the total amount earned by all sellers?

-- all sellers

SELECT SUM(payment_value)        # from payment value (paid by customers)
FROM order_payments;   #16008872.13

SELECT ROUND(SUM(price),2)      # from price (invoice amount)
FROM order_items;  #15843553.24 fright --- 13591643.70 ohne FREIGHT

---------------------------------------------------------------------
-- What is the total amount earned by all Tech sellers?
-- informatica_acessorios

SELECT ROUND(SUM(a.price),2) AS amount_earned
FROM order_items a
JOIN products b
USING (product_id)
WHERE product_category_name = 'informatica_acessorios';

---------------------------------------------------------------------
-- ALTERNATIVE : tech AND non_tech 

SELECT b.main_category, ROUND(SUM(a.price),2) AS amount_earned
FROM order_items a
LEFT JOIN (SELECT
				product_id, product_category_name,
				CASE
					WHEN product_category_name = 'informatica_acessorios' THEN 'tech_accessories'
					ELSE 'non_tech_products'
					END AS 'main_category'
			FROM products) AS b USING (product_id)
WHERE a.seller_id IS NOT NULL
GROUP BY b.main_category;

-----------------------------------------------------------------------------------------------------------------------------------
# 4. the average monthly income of all sellers & the average monthly income of Tech sellers
-- tech sellers : 36.4K    non_tech sellers : 507.2K

SELECT b.main_category, ROUND(SUM(a.price)/25,2) AS amount_earned
FROM order_items a
LEFT JOIN (SELECT
				product_id, product_category_name,
				CASE
					WHEN product_category_name = 'informatica_acessorios' THEN 'tech_accessories'
					ELSE 'non_tech_products'
					END AS 'main_category'
			FROM products) AS b USING (product_id)
WHERE a.seller_id IS NOT NULL
GROUP BY b.main_category;