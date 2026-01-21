
/*
Purpose:
    Provides a 360° customer summary combining orders, spending, reviews, geography,
    and behavioral segmentation at the customer (cust_unique_id) level.
    Used for customer profiling, retention, and value-based analysis.
*/



CREATE OR ALTER VIEW analytics.vw_customers_report AS

    WITH base_orders AS (
        SELECT
            dc.cust_unique_id,
            fo.order_id,
            fo.total_payment_value,
            dd.full_date                                                                            AS order_date
        FROM analytics.fact_orders fo
        RIGHT JOIN analytics.dim_customer dc
            ON fo.customer_sk = dc.customer_sk
        JOIN analytics.dim_date dd
            ON fo.order_date_sk = dd.date_sk
    ),
    order_stats AS (
        SELECT
            cust_unique_id,
            COUNT(DISTINCT order_id)                                                                AS total_orders,
            MIN(order_date)                                                                         AS first_order_date,
            MAX(order_date)                                                                         AS last_order_date,
            DATEDIFF( DAY,MIN(order_date),MAX(order_date))                                          AS customer_lifespan_days,
            SUM(total_payment_value)                                                                AS total_spending,
            ROUND(SUM(CAST(total_payment_value AS FLOAT))/COUNT( DISTINCT order_id),2)              AS avg_order_value
        FROM base_orders
        GROUP BY cust_unique_id
    ),
    item_stats AS (
        SELECT
            dc.cust_unique_id,
            COUNT(*)                                                                                AS total_items_purchased
        FROM analytics.fact_sales fs
        JOIN analytics.dim_customer dc
            ON fs.customer_sk = dc.customer_sk
        GROUP BY dc.cust_unique_id
    ),
    review_stats AS (
        SELECT
            dc.cust_unique_id,
            ROUND(AVG(CAST(fr.review_score as float)),2)                                            AS avg_review_score
        FROM analytics.fact_reviews fr
        JOIN analytics.dim_customer dc
            ON fr.customer_sk = dc.customer_sk
        GROUP BY dc.cust_unique_id
    ),

    payment_methods AS (
        SELECT
        t.cust_unique_id,
        STRING_AGG(t.payment_type, ', ')                                                            AS payment_methods
    FROM (
        SELECT DISTINCT
            dc.cust_unique_id,
            dp.payment_type
        FROM analytics.fact_order_payment fop
        JOIN analytics.fact_orders fo
            ON fop.order_sk = fo.order_sk
        JOIN analytics.dim_customer dc
            ON fo.customer_sk = dc.customer_sk
        JOIN analytics.dim_payment dp
            ON fop.payment_sk = dp.payment_sk
        ) t
        GROUP BY cust_unique_id
    )

    SELECT
        dc.cust_unique_id                                                                           As customer_id,
        MIN(dc.city)                                                                                AS city,
        MIN(dc.state)                                                                               AS state,
        dl.latitude,
        dl.longitude,
        os.first_order_date,
        os.last_order_date,
        os.customer_lifespan_days,
        os.total_orders,
        isx.total_items_purchased,
        os.total_spending,
        os.avg_order_value,
        rs.avg_review_score,
        pm.payment_methods,

        -- Customer Segmentation
    CASE
        WHEN total_spending >= 500
             AND total_orders >= 3  THEN  'VIP'
        WHEN total_spending >= 300
             AND total_orders >= 2  THEN  'High_Value'
        WHEN total_spending >= 100 
            AND total_orders>=1     THEN  'Average_Value'
        WHEN total_orders >= 2      THEN   'Repeat'
        ELSE        'New'

    END AS customer_segment

    FROM analytics.dim_customer dc
    LEFT JOIN order_stats os
        ON dc.cust_unique_id = os.cust_unique_id
    LEFT JOIN item_stats isx
        ON dc.cust_unique_id = isx.cust_unique_id
    LEFT JOIN review_stats rs
        ON dc.cust_unique_id = rs.cust_unique_id
    LEFT JOIN payment_methods pm
        ON dc.cust_unique_id = pm.cust_unique_id
    LEFT JOIN analytics.dim_location as dl
    on dc.location_sk=dl.location_sk
    GROUP BY
        dc.cust_unique_id,
        dl.latitude,
        dl.longitude,
        os.first_order_date,
        os.last_order_date,
        os.customer_lifespan_days,
        os.total_orders,
        isx.total_items_purchased,
        os.total_spending,
        os.avg_order_value,
        rs.avg_review_score,
        pm.payment_methods;



