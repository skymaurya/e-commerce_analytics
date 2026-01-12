/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'clean' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading clean Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/


-- ====================================================================
-- Checking 'clean.cust_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
    cust_id,
    COUNT(*) 
FROM clean.cust_info
GROUP BY cust_id
HAVING COUNT(*) > 1 OR cust_id IS NULL;



-- Check for Unwanted Spaces
-- Expectation: No Results

SELECT 
   *
FROM clean.cust_info
WHERE cust_unique_id != TRIM(cust_unique_id)
    OR cust_state != TRIM(cust_state)
    OR cust_city != TRIM(cust_city)
    OR cust_zip_code_prefix !=TRIM(cust_zip_code_prefix)


-- ====================================================================
-- Checking 'clean.cust_location'
-- ====================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results

SELECT 
    loc_zip_code 
FROM clean.cust_location
WHERE loc_zip_code != TRIM(loc_zip_code);

SELECT 
    loc_city 
FROM clean.cust_location
WHERE loc_city != TRIM(loc_city);

SELECT 
    loc_state 
FROM clean.cust_location
WHERE loc_state != TRIM(loc_state);

--checking for the valid logitude and latitude location values
---Expectation : For Latitude  range -90 to 90
              -- For Longitude range -180 to 180.
               -- NO Results
            
SELECT 
    loc_latitude ,
    loc_longitude
FROM clean.cust_location
WHERE (loc_latitude  NOT BETWEEN -90 AND 90) and (loc_longitude NOT BETWEEN -180 AND 180)





-- ====================================================================
-- Checking 'clean.orders'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
    order_id,
    COUNT(*)
FROM clean.orders
GROUP BY order_id
HAVING  order_id IS NULL AND COUNT(*)>1



-- Data Standardization & Consistency
SELECT DISTINCT 
    order_status 
FROM clean.orders;

--=========================================
-- DATES VALIDATION CHECK IN ORDERS TABLE
--=========================================


-- Check for Invalid Date  ( purchase Date > approved Date)
-- Expectation: No Results

SELECT 
*
FROM clean.orders
WHERE ord_purchase_date>ord_approved_date

-- Check for Invalid Date  ( purchase Date > delivery carrier  Date)
-- Expectation: No Results

SELECT 
*
FROM clean.orders
WHERE ord_purchase_date>ord_delivered_carrier_date

-- Check for Invalid Date  ( purchase Date > customer delivery  Date)
-- Expectation: No Results

SELECT 
*
FROM clean.orders
WHERE ord_purchase_date>ord_delivered_customers_date



-- Check for Invalid Date Orders ( approved Date > delivery carrier  Date)
-- Expectation: No Results

SELECT 
*
FROM clean.orders
WHERE ord_approved_date>ord_delivered_carrier_date

-- Check for Invalid Date Orders ( approved Date > customer delivery  Date)
-- Expectation: No Results

SELECT 
*
FROM clean.orders
WHERE ord_approved_date>ord_delivered_customers_date



-- Check for Invalid Date Orders ( delivery carrier Date > customer delivery  Date)
-- Expectation: No Results

SELECT 
*
FROM clean.orders
WHERE ord_delivered_carrier_date>ord_delivered_customers_date




-- ====================================================================
-- Checking 'clean.orders_items'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
    order_id,
    order_item_id,
    COUNT(*)
FROM clean.orders_items
GROUP BY order_id,order_item_id
HAVING  order_id IS NULL OR order_item_id IS NULL AND COUNT(*)>1


-- Check Data Consistency:
-- Expectation : No Results

SELECT 
*
FROM clean.orders_items
where price<=0 OR freight_value<0;



-- ====================================================================
-- Checking 'clean.orders_payment'
-- ====================================================================


-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
    order_id,
    payment_sequence,
    COUNT(*)
FROM clean.orders_payment
GROUP BY order_id,payment_sequence
HAVING  order_id IS NULL OR payment_sequence IS NULL AND COUNT(*)>1;

-- Data Standardization & Consistency

SELECT DISTINCT 
    payment_type 
FROM clean.orders_payment

-- Check Data Consistency:
-- Expectation : No Results

SELECT 
*
FROM clean.orders_payment
where payment_value IS NULL;


-- ====================================================================
-- Checking 'clean.orders_reviews'
-- ====================================================================



-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
    order_id,
    review_id,
    COUNT(*)
FROM clean.orders_reviews
GROUP BY order_id,review_id
HAVING  order_id IS NULL OR review_id IS NULL AND COUNT(*)>1;

-- Data Standardization & Consistency
-- Expectation: from 1 to 5

SELECT DISTINCT 
    review_score 
FROM clean.orders_reviews
ORDER BY review_score;

SELECT 
*
FROM clean.orders_reviews
WHERE review_title !=TRIM(review_title)

SELECT 
*
FROM clean.orders_reviews
WHERE review_message !=TRIM(review_message)



---date validation check   ( review_creation_dt> review_answer_dt)
--expectation: no result


SELECT 
*
FROM clean.orders_reviews
WHERE review_creation_dt>review_answer_dt


-- ====================================================================
-- Checking 'clean.product_category'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results



SELECT 
    * 
FROM clean.products_catg_trans
WHERE product_catg_name != TRIM(product_catg_name) 
    OR product_Eng_name != TRIM(product_Eng_name);


-- ====================================================================
-- Checking 'clean.products_info'
-- ====================================================================


-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
    prd_id, 
    COUNT(*)
FROM clean.products_info
GROUP BY prd_id
HAVING  prd_id IS NULL  AND COUNT(*)>1;


-- Check for Unwanted Spaces
-- Expectation: No Results

SELECT 
    * 
FROM clean.products_info
WHERE prd_catg_name != TRIM(prd_catg_name) ;
   

--Data consistency check
--Expectation : No Results

SELECT 
*
FROM clean.products_info
WHERE prd_weight_g<=0 
     OR prd_length_cm<=0
     OR prd_height_cm<=0
     OR prd_width_cm<=0;


-- ====================================================================
-- Checking 'clean.sellers_info'
-- ====================================================================


-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
    seller_id, 
    COUNT(*)
FROM clean.sellers_info
GROUP BY seller_id
HAVING  seller_id IS NULL  AND COUNT(*)>1;



-- Check for Unwanted Spaces
-- Expectation: No Results

SELECT 
    * 
FROM clean.sellers_info
WHERE seller_city != TRIM(seller_city) 
      OR seller_state !=TRIM(seller_state)
      OR seller_zip_code_prefix!=TRIM(seller_zip_code_prefix)




-- ============================================================
-- RELATIONSHIP (FK) VALIDATION CHECKS

-- checking clean layer internally consistent or Not
-- ============================================================



-- Orders must have valid customers

--Expectation : NO Results

SELECT o.order_id
FROM clean.orders o
LEFT JOIN clean.cust_info c
  ON o.cust_id = c.cust_id
WHERE c.cust_id IS NULL;


-- Order items must have a valid order
--Expectation : NO Results

SELECT oi.order_id, oi.order_item_id
FROM clean.orders_items oi
LEFT JOIN clean.orders o
  ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Payments must have a valid order
--Expectation : NO Results

SELECT p.order_id, p.payment_sequence
FROM clean.orders_payment p
LEFT JOIN clean.orders o
  ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Reviews must have a valid order
--Expectation : NO Results

SELECT r.review_id, r.order_id
FROM clean.orders_reviews r
LEFT JOIN clean.orders o
  ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


--===== its consitent throught all the table
