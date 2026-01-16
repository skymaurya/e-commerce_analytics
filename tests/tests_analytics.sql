/*
===============================================================================
ANALYTICS LAYER – FINAL DATA QUALITY & VALIDATION CHECKS
===============================================================================

Purpose:
    This script validates the integrity, correctness, and consistency of the
    ANALYTICS layer after ETL completion.

    These checks ensure:
      - No data loss between CLEAN → ANALYTICS
      - Correct grain for all fact tables
      - Valid surrogate key relationships
      - Correct date handling strategy (-1 for unknown)
      - Revenue reconciliation across all payment-related facts
      - No orphan dimension references

Execution:
    Run AFTER executing analytics.load_analytics

Interpretation:
    - Queries marked "Expectation: no records" must return ZERO rows
    - Aggregation checks must MATCH source totals exactly (± rounding tolerance)

===============================================================================
*/


/*==============================================================================
1. ROW-COUNT SANITY CHECKS (FLOW INTEGRITY)
==============================================================================*/

-- Orders flow: CLEAN → fact_orders
-- Expectation: counts must match
SELECT
    (SELECT COUNT(DISTINCT order_id) FROM clean.orders)          AS clean_orders,
    (SELECT COUNT(DISTINCT order_id) FROM analytics.fact_orders) AS fact_orders;


-- Order-items flow: CLEAN → fact_sales
-- Expectation: counts should match (minor known differences must be explainable)
SELECT
    (SELECT COUNT(*) FROM clean.orders_items)   AS clean_items,
    (SELECT COUNT(*) FROM analytics.fact_sales) AS fact_sales;



/*==============================================================================
2. PRIMARY GRAIN VALIDATION
==============================================================================*/

-- fact_sales grain = (order_id × order_item_id)
-- Expectation: no duplicate grain

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS cnt
FROM analytics.fact_sales
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- fact_orders grain = order_id
-- Expectation: exactly one row per order

SELECT
    order_id,
    COUNT(*) AS cnt
FROM analytics.fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;



/*==============================================================================
3. SURROGATE KEY INTEGRITY (NO BROKEN JOINS)
==============================================================================*/

-- fact_sales → dimensions
-- Expectation: no NULL surrogate keys

SELECT *
FROM analytics.fact_sales
WHERE customer_sk IS NULL
   OR product_sk  IS NULL
   OR seller_sk   IS NULL;


-- fact_orders → dim_customer
-- Expectation: no NULL customer_sk
SELECT *
FROM analytics.fact_orders
WHERE customer_sk IS NULL;



/*==============================================================================
4. DATE HANDLING CORRECTNESS
==============================================================================*/

-- Date surrogate keys must never be NULL
-- Missing / invalid dates must be mapped to -1
-- Expectation: no records

SELECT *
FROM analytics.fact_orders
WHERE order_date_sk     IS NULL
   OR approved_date_sk  IS NULL
   OR delivered_date_sk IS NULL;


-- Unknown date member must exist
-- Expectation: exactly one record

SELECT *
FROM analytics.dim_date
WHERE date_sk = -1;



/*==============================================================================
5. REVENUE CORRECTNESS (SOURCE OF TRUTH VALIDATION)
==============================================================================*/

-- Source revenue (CLEAN layer)

SELECT SUM(payment_value) AS clean_total_revenue
FROM clean.orders_payment;


-- fact_order_payment revenue
-- Expectation: must match CLEAN revenue

SELECT SUM(payment_value) AS fact_order_payment_revenue
FROM analytics.fact_order_payment;


-- fact_orders revenue
-- Expectation: must match CLEAN revenue

SELECT SUM(total_payment_value) AS fact_orders_revenue
FROM analytics.fact_orders;



/*==============================================================================
6. PAYMENT ALLOCATION CORRECTNESS
==============================================================================*/

-- Payments per order must never be negative
-- Expectation: no records

SELECT
    order_id,
    SUM(payment_value) AS payment_sum
FROM analytics.fact_order_payment
GROUP BY order_id
HAVING SUM(payment_value) < 0;



/*==============================================================================
7. FACT_SALES PAYMENT DISTRIBUTION VALIDATION
==============================================================================*/

-- Rule:
--   Sum of item-level payments = order-level payment
-- Small rounding differences (≤ 0.01) are acceptable
-- Expectation: no records

SELECT
    fs.order_id,
    SUM(fs.payment_value) AS item_sum,
    fo.total_payment_value
FROM analytics.fact_sales fs
JOIN analytics.fact_orders fo
    ON fs.order_id = fo.order_id
GROUP BY fs.order_id, fo.total_payment_value
HAVING ABS(SUM(fs.payment_value) - fo.total_payment_value) > 0.01;



/*==============================================================================
8. DIMENSIONAL COMPLETENESS (UNKNOWN MEMBERS)
==============================================================================*/

-- Unknown payment member
-- Expectation: exactly one record

SELECT *
FROM analytics.dim_payment
WHERE payment_sk = -1;


-- Unknown date member
-- Expectation: exactly one record

SELECT *
FROM analytics.dim_date
WHERE date_sk = -1;



/*==============================================================================
9. ORPHAN FACT CHECKS
==============================================================================*/

-- fact_sales → dim_customer orphan check
-- Expectation: no records

SELECT DISTINCT
    fs.customer_sk
FROM analytics.fact_sales fs
LEFT JOIN analytics.dim_customer dc
    ON fs.customer_sk = dc.customer_sk
WHERE dc.customer_sk IS NULL;

------------------------------------------------------------
-- 10. All date keys exist in dim_date
------------------------------------------------------------


-- Expectation: No rows
SELECT DISTINCT purchase_date_sk
FROM analytics.fact_sales
WHERE purchase_date_sk NOT IN (SELECT date_sk FROM analytics.dim_date);

SELECT DISTINCT approved_date_sk
FROM analytics.fact_sales
WHERE approved_date_sk NOT IN (SELECT date_sk FROM analytics.dim_date);

SELECT DISTINCT customer_delivery_date_sk
FROM analytics.fact_sales
WHERE customer_delivery_date_sk NOT IN (SELECT date_sk FROM analytics.dim_date);