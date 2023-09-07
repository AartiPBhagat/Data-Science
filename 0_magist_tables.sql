---------------------------------------------------------------------------
USE magist;
---------------------------------------------------------------------------
# how many rows and unique customer_id in customer table?

SELECT * FROM customers;

SELECT 
    COUNT(*),						#99441
    COUNT(DISTINCT customer_id)		#99441
FROM
    customers;
    
---------------------------------------------------------------------------
# how many rows and unique values in orders? -- (purchase approval delivery estimate date time)
-- number of orders placed for given timespan is same as number of customers listed in customer table.
-- which implies no customer repetation on magist marketplace for given timespan.

SELECT * FROM orders;

SELECT
	COUNT(*),						# 99441
    COUNT(DISTINCT order_id),		# 99441
    COUNT(DISTINCT customer_id),	# 99441
    COUNT(DISTINCT order_status)	# 8
FROM orders;

---------------------------------------------------------------------------
# how many rows and unique order_id, order_item_id, product_id, seller_id in order_items table?

SELECT * FROM order_items;

SELECT 
    COUNT(*),						# 112650
    COUNT(DISTINCT order_id),		# 98666
    COUNT(DISTINCT order_item_id),	# 21
    COUNT(DISTINCT product_id),		# 32951
    COUNT(DISTINCT seller_id)		# 3095
FROM
    order_items;

---------------------------------------------------------------------------    
# how many rows and unique values in order_payments table?

SELECT * FROM order_payments;

SELECT
	COUNT(*),								# 103886
    COUNT(DISTINCT order_id),				# 99440
    COUNT(DISTINCT payment_sequential),		# 29
    COUNT(DISTINCT payment_type),			# 5
    COUNT(DISTINCT payment_installments)	# 24
FROM order_payments;

---------------------------------------------------------------------------
# how many rows and unique values in order_reviews table? REVIEW - RESPNSE TIME FOR NON NULL VALUES

SELECT * FROM order_reviews;

SELECT
	COUNT(*),								# 98371
    COUNT(DISTINCT review_id),				# 98371
    COUNT(DISTINCT order_id),				# 98279
    COUNT(DISTINCT review_score),			# 5
    COUNT(DISTINCT review_comment_message)	# 35921
FROM order_reviews;

select distinct review_score from order_reviews;    
---------------------------------------------------------------------------
# how many rows and unique values in products table?

SELECT * FROM products;

SELECT
	COUNT(*),								# 32951
    COUNT(DISTINCT product_id),				# 32951
    COUNT(DISTINCT product_category_name)	# 74
FROM products;

---------------------------------------------------------------------------
# how many rows and unique values in product_category_name_translation? portugal name - english name

SELECT * FROM product_category_name_translation;

SELECT 
    COUNT(*)							#74
FROM
    product_category_name_translation;
    
---------------------------------------------------------------------------
# how many rows and unique values in sellers table?

SELECT * FROM sellers;

SELECT
	COUNT(*),								# 3095
    COUNT(DISTINCT seller_id),				# 3095
    COUNT(DISTINCT seller_zip_code_prefix)	# 2246
FROM sellers;

---------------------------------------------------------------------------
# how many rows and unique zip_code_prefix, city, state in geo table?

SELECT * FROM geo;

SELECT 
    COUNT(*),							# 19177
    COUNT(DISTINCT zip_code_prefix),	# 19177
    COUNT(DISTINCT city),				# 5806
    COUNT(DISTINCT state)				# 27
FROM
    geo;

---------------------------------------------------------------------------
-- make new column displaying tech or non tech product
    
SELECT
	*,
	CASE
		WHEN product_category_name_english IN ('audio','consoles_games','electronics','computers_accessories','pc_gamer','computers') THEN 'TECH'
        ELSE 'other'
        END AS 'main_category'
FROM product_category_name_translation;

---------------------------------------------------------------------------
