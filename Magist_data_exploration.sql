
### Exploring the Magist dataset ###

use magist;


-- DATA EXPLORATION QUESTIONS --

-- 1. How many orders are there in the dataset?
SELECT 
    COUNT(order_id)
FROM
    orders;
-- almost 100,000 orders (99,441)



-- 2. Are orders actually delivered?
SELECT 
    order_status, COUNT(order_status)
FROM
    orders
GROUP BY order_status;
-- out of the 99,441 orders, 97 % were delivered



-- 3. Is Magist having user growth?
SELECT 
    COUNT(order_id),
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
FROM
    orders
GROUP BY YEAR(order_purchase_timestamp) , MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp) , MONTH(order_purchase_timestamp);
-- Magist order numbers were increasing in 2017 and relatively stable throughout 2018.
-- In September/October 2018, numbers seem weird. Perhaps not updated yet.
-- Overall, order numbers seem stable currently. No red flag.



-- 4. How many products are there on the products table?
SELECT 
    COUNT(product_id)
FROM
    products;
-- There are 32,951 products.



-- 5. Which are the categories with the most products?
SELECT 
    COUNT(products.product_id),
    product_category_name_translation.product_category_name_english
FROM
    products
        JOIN
    product_category_name_translation ON products.product_category_name = product_category_name_translation.product_category_name
GROUP BY product_category_name_translation.product_category_name_english
ORDER BY COUNT(products.product_id) DESC;
/* Categories with the most products are (in decreasing order):
- bed table bath
- sports leisure
- furniture decor
- health beauty
- housewares
*/



-- 6. How many of those products were present in actual transactions?
SELECT 
    COUNT(DISTINCT product_id) AS ordered_products
FROM
    order_items;
-- From the 32,951 overall products, all 32,951 were already bought.



-- 7. What's the price for the most expensive and cheapest products?
SELECT
    avg(price),
    max(price),
    min(price)
FROM
    order_items;
-- The price range is 85 cents to 6,735.- € with an average price of 121.-€.



-- 8. What are the highest and lowest payment values?
SELECT
    max(payment_value),
    min(payment_value)
FROM order_payments;
SELECT * FROM order_items WHERE order_id = '03caa2c082116e1d31e67e9ae3700499';
SELECT * FROM products WHERE product_id = '5769ef0a239114ac3a854af00df129e4';
-- The highest payment amounted to 13,664.10 €.
-- That order contained eight times a product for 1680.-€ with the product ID '5769ef0a239114ac3a854af00df129e4'.

SELECT 
    *
FROM
    order_payments
ORDER BY payment_value desc
LIMIT 15;
-- The lowest payment value was 0.-€, using a voucher.



