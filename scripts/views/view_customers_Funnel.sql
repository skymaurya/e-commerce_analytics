

/*
Purpose:
    Represents the customer funnel by analyzing purchase frequency, lifespan,
    and repeat behavior to classify customers into lifecycle stages.
    Used to understand customer progression and retention.
*/


CREATE OR ALTER VIEW analytics.vw_customers_funnel AS


WITH customer_orders AS (
    SELECT
        dc.cust_unique_id,
        fo.order_id,
        dd.full_date AS order_date,
        fo.total_payment_value
    FROM analytics.fact_orders fo
    JOIN analytics.dim_customer dc
        ON fo.customer_sk = dc.customer_sk
    JOIN analytics.dim_date dd
        ON fo.order_date_sk = dd.date_sk
),




customer_agg AS (
    SELECT
        cust_unique_id,
        COUNT(DISTINCT order_id)              AS total_orders,
        SUM(total_payment_value)              AS total_spending,
        MIN(order_date)                       AS first_order_date,
        MAX(order_date)                       AS last_order_date,
        DATEDIFF(DAY,
            MIN(order_date),
            MAX(order_date)
        )                                     AS customer_lifespan_days
    FROM customer_orders
    GROUP BY cust_unique_id
)



SELECT
    cust_unique_id                            AS customer_id,
    total_orders,
    total_spending,
    first_order_date,
    last_order_date,
    customer_lifespan_days,

    CASE
        WHEN total_spending >= 500 AND total_orders >= 3 THEN 'VIP'
        WHEN total_spending >= 300 AND total_orders >= 2 THEN 'High_Value'
        WHEN total_spending >= 100 THEN 'Average_Value'
        WHEN total_orders >= 2 THEN 'Repeat'
        ELSE 'New'
    END                                         AS customer_funnel_stage

FROM customer_agg;

