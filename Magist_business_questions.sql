
### Answering business questions related to the Magist dataset ###


-- The schema of the Magist database is called 'magist'
use magist;


-- BUSINESS QUESTIONS --

/*

In relation to the products:

-- What categories of tech products does Magist have?
-- How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?
-- What’s the average price of the products being sold?
-- Are expensive tech products popular?


In relation to the sellers:

-- How many months of data are included in the magist database?
-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?


In relation to the delivery time:

-- What’s the average time between the order being placed and the product being delivered?
-- How many orders are delivered on time vs orders delivered with a delay?
-- Is there any pattern for delayed orders, e.g. big products being delayed more often?


Comparison between Eniac and Magist:

-- How does the average revenue of Magist tech sellers compare to the average revenue of Eniac?
-- Eniac's revenue was €14 M between April 2017 to March 2018 (1 year).

-- How does the average monthly revenue of Magist tech sellers compare to the average monthly revenue of Eniac?
-- Eniac's average monthly revenue was €1.17 M between April 2017 to March 2018 (1 year).

-- How do average order prices and average item prices of Magist tech sellers compare to the ones of of Eniac?
-- Eniac's average order and item prices are 710.-€ and 540, respectively (between April 2017 to March 2018).

*/





#########################################################################################################

###################################
### In relation to the products ###
###################################


###
-- What categories of tech products does Magist have?
-- We used ChatGPT and added a couple more, adding up to these 19 tech categories:
SELECT DISTINCT
    product_category_name_english
FROM
    product_category_name_translation
WHERE
    product_category_name_english IN (
		'audio',
        'auto',
        'cds_dvds_musicals',
        'air_conditioning',
        'consoles_games',
        'dvds_blu_ray',
        'home_appliances',
        'home_appliances_2',
        'electronics',
        'small_appliances',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'small_appliances_home_oven_and_coffee',
        'portable_kitchen_food_processors',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony');

-- Creating a temporary table tech_products:
CREATE TEMPORARY TABLE tech_products AS
SELECT 
	*
FROM 
	products
WHERE 
	product_category_name IN (SELECT
			product_category_name 
		FROM 
			product_category_name_translation 
		WHERE 
			product_category_name_english in (
		'audio',
        'auto',
        'cds_dvds_musicals',
        'air_conditioning',
        'consoles_games',
        'dvds_blu_ray',
        'home_appliances',
        'home_appliances_2',
        'electronics',
        'small_appliances',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'small_appliances_home_oven_and_coffee',
        'portable_kitchen_food_processors',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony'));

-- Checking if the table has the right size:
SELECT 
    count(*)
FROM
    tech_products;
-- 6721 products
SELECT 
    count(*)
FROM
    products
WHERE 
	product_category_name IN (SELECT
			product_category_name 
		FROM 
			product_category_name_translation 
		WHERE 
			product_category_name_english in (
		'audio',
        'auto',
        'cds_dvds_musicals',
        'air_conditioning',
        'consoles_games',
        'dvds_blu_ray',
        'home_appliances',
        'home_appliances_2',
        'electronics',
        'small_appliances',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'small_appliances_home_oven_and_coffee',
        'portable_kitchen_food_processors',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony'));
-- 6721 products as well

-- Checking if I can merge it with already existing tables:
SELECT 
    *
FROM
    tech_products tp
        JOIN
    products p ON tp.product_id = p.product_id;



###
-- How many products of these tech categories have been sold (within the time window of the database snapshot)?
-- What percentage does that represent from the overall number of products sold?
SELECT 
    COUNT(DISTINCT tp.product_id) tech_products_with_orderID
FROM
    tech_products tp
        JOIN
    order_items oi ON tp.product_id = oi.product_id;
-- All of the 6721 tech products have a corresponding order ID. Hence, all of them have been sold.

SELECT 
    COUNT(DISTINCT product_id)
FROM
    order_items;
-- From the 32,951 different products that were sold in total, tech products make up 20.4 %.





###
-- What’s the average price of the products being sold?
SELECT 
    AVG(price)
FROM
    order_items oi
        JOIN
    tech_products tp ON tp.product_id = oi.product_id;

SELECT 
    AVG(price)
FROM
    order_items;
-- Average price of all products is 120.65€, while it's 126.42€ for tech products.



###
-- Are expensive tech products popular?
-- Let's define 'expensive' products as products at > 1,000€.

-- Counting number of expensive tech products: 129
SELECT 
    COUNT(product_id)
FROM
    tech_products
WHERE
    product_id IN (SELECT 
            product_id
        FROM
            order_items
        WHERE
            price > 1000);

-- Giving out all the orders of expensive tech products: 352
SELECT 
    tp.product_id, price
FROM
    tech_products tp
        JOIN
    order_items oi ON oi.product_id = tp.product_id
HAVING price > 1000
ORDER BY price DESC;
-- There are 129 tech products at > 1,000€ to choose from.
-- There have been 352 orders of expensive tech products. 
SELECT DISTINCT
    COUNT(order_id)
FROM
    order_items;
-- Compared to the total number of ordered products (112,650), that's almost nothing.





#########################################################################################################

##################################
### In relation to the sellers ###
##################################

###
-- How many months of data are included in the magist database?
SELECT 
    YEAR(order_purchase_timestamp) AS `year`,
    MONTH(order_purchase_timestamp) AS `month`
FROM
    orders
GROUP BY `year` , `month`
ORDER BY `year` , `month`;
-- There are 25 months worth of data.


###
-- How many sellers are there? 
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers;
-- There are 3095 sellers.


###
-- How many Tech sellers are there? 
-- What percentage of overall sellers are Tech sellers?
SELECT 
    COUNT(DISTINCT seller_id) AS tech_sellers
FROM
    order_items
WHERE
    product_id IN (SELECT 
            product_id
        FROM
            tech_products);
-- Out of the 3095 overall sellers, there are 938 Tech sellers.
-- Hence, 30.3 % of all Magist sellers sell Tech.



###
-- What is the total amount earned by all sellers?
SELECT 
    ROUND(SUM(price)) AS total_earn_all_sellers
FROM
    order_items;
-- 13.6 million €

-- What is the total amount earned by all Tech sellers?
SELECT 
    round(SUM(price)) AS total_earn_all_tech_sellers
FROM
    order_items
WHERE
    product_id IN (SELECT 
            product_id
        FROM
            tech_products);
-- 3.0 million €

-- Tech sales (3.0 m €) make up 22.1 % of the total sales (13.6 m €) on Magist.



###
-- Can you work out the average monthly income of all sellers?
SELECT 
    ROUND(AVG(monthly_income)) AS average_monthly_income
FROM
    (SELECT 
        SUM(payment_value) AS monthly_income,
            YEAR(order_purchase_timestamp) AS `year`,
            MONTH(order_purchase_timestamp) AS `month`
    FROM
        order_payments op
    JOIN orders o ON op.order_id = o.order_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY `year` , `month`) AS all_monthly_incomes_subquery;
-- Average monthly income of all sellers: 846,172.-€

-- Can you work out the average monthly income of Tech sellers?
SELECT 
    ROUND(AVG(monthly_income_tech)) AS average_monthly_income_tech
FROM
    (SELECT 
        ROUND(SUM(payment_value), 2) AS monthly_income_tech,
            YEAR(order_purchase_timestamp) AS `year`,
            MONTH(order_purchase_timestamp) AS `month`
    FROM
        order_payments op
    JOIN orders o ON op.order_id = o.order_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE
        oi.product_id IN (SELECT 
                tp.product_id
            FROM
                tech_products tp)
    GROUP BY `year` , `month`) AS all_monthly_incomes_subquery;
-- Average monthly income of tech sellers: 209,480.-€





#########################################################################################################

########################################
### In relation to the delivery time ###
########################################


-- What’s the average time between the order being placed and the product being delivered?
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,
            order_purchase_timestamp)) average_time_between_order_and_delivery
FROM
    orders
WHERE
    order_status = 'delivered';
-- The average time between order and delivery is 12.5 days.



-- How many orders are delivered on time vs orders delivered with a delay?
SELECT 
    SUM(CASE
        WHEN delivery_delay > 0 THEN 1
        ELSE 0
    END) AS orders_without_delay,
    SUM(CASE
        WHEN delivery_delay < 0 THEN 1
        ELSE 0
    END) AS orders_with_delay
FROM
    (SELECT 
        order_estimated_delivery_date,
            order_delivered_customer_date,
            DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) AS delivery_delay
    FROM
        orders
    WHERE
        order_status = 'delivered'
            AND order_delivered_customer_date IS NOT NULL
    ORDER BY delivery_delay) AS delivery_delay_query;
-- Orders without delay: 88,471
-- Orders with delay: 	  6,665
-- 7.53 % of orders are delivered with a delay.



-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
WITH OrderDelays AS (
    SELECT 
        DATEDIFF(o.order_estimated_delivery_date,
                o.order_delivered_customer_date) as delivery_delay,
        p.product_weight_g,
		p.product_length_cm,
		p.product_height_cm,
		p.product_width_cm,
        CASE 
			WHEN product_weight_g > 1000 THEN 'heavy'
			ELSE 'light'
		END AS heavy_or_light,
        CASE 
			WHEN product_length_cm > 30 THEN 'big'
			ELSE 'small'
		END AS big_or_small
    FROM
        orders o
            JOIN
        order_items oi ON o.order_id = oi.order_id
            JOIN
        products p ON oi.product_id = p.product_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
)
SELECT *
FROM OrderDelays
WHERE delivery_delay < 0
ORDER BY delivery_delay ASC;
-- It seems that many delayed orders are heavy (> 1 kg).
-- But, honestly, answering this question requires plotting, not SQL queries.





#########################################################################################################

###########################################
### Comparison between Eniac and Magist ###
###########################################

-- Comparison between Eniac and Magist:

-- How does the average revenue of Magist tech sellers compare to the average revenue of Eniac?
-- Eniac's revenue was €14 M between April 2017 to March 2018 (1 year).


-- Therefore, let's first make a table that contains only the latest year of data.
CREATE TEMPORARY TABLE orders_2017_2018 AS
SELECT 
    *
FROM
    orders
WHERE
    (YEAR(order_purchase_timestamp) = 2017
        AND MONTH(order_purchase_timestamp) IN (9 , 10, 11, 12))
	OR (YEAR(order_purchase_timestamp) = 2018
        AND MONTH(order_purchase_timestamp) IN (1 , 2, 3, 4, 5, 6, 7, 8));

-- Calculate average monthly income of tech sellers using the most recent data:
SELECT 
    ROUND(AVG(monthly_income_tech)) AS average_monthly_income_tech
FROM
    (SELECT 
        ROUND(SUM(payment_value), 2) AS monthly_income_tech,
            YEAR(order_purchase_timestamp) AS `year`,
            MONTH(order_purchase_timestamp) AS `month`
    FROM
        order_payments op
    JOIN orders_2017_2018 o ON op.order_id = o.order_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE
        oi.product_id IN (SELECT 
                tp.product_id
            FROM
                tech_products tp)
    GROUP BY `year` , `month`) AS all_monthly_incomes_subquery;
-- Average monthly income of tech sellers: 297,349.-€

-- Calculate yearly income of tech sellers using the most recent data:
SELECT 
    ROUND(SUM(payment_value), 2) AS yearly_income_tech
FROM
    order_payments op
        JOIN
    orders_2017_2018 o ON op.order_id = o.order_id
        JOIN
    order_items oi ON oi.order_id = o.order_id
WHERE
    oi.product_id IN (SELECT 
            tp.product_id
        FROM
            tech_products tp);
-- Yearly income of tech sellers: €3,5 M

