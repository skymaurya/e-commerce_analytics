

/*
Purpose:
    Provides a daily order funnel showing how orders progress through
    creation, approval, delivery, and cancellation stages.
    Used to monitor operational conversion and drop-offs over time.
*/


CREATE OR ALTER VIEW analytics.vw_orders_funnel_daily AS

    WITH base_orders AS (
        SELECT
            fo.order_id,
            fo.order_status,
            fo.late_delivery_flg,

            CASE WHEN fo.order_date_sk     <> -1 THEN 1 ELSE 0 END              AS is_created,
            CASE WHEN fo.approved_date_sk  <> -1 THEN 1 ELSE 0 END              AS is_approved,
            CASE WHEN fo.delivered_date_sk <> -1 THEN 1 ELSE 0 END              AS is_delivered,
            CASE WHEN fo.order_status = 'canceled' THEN 1 ELSE 0 END            AS is_canceled,

            dd.full_date AS order_date
        FROM analytics.fact_orders fo
        JOIN analytics.dim_date dd
            ON fo.order_date_sk = dd.date_sk
    )

    SELECT
        order_date,

        COUNT(DISTINCT order_id)                                                AS total_orders_created,
        SUM(is_approved)                                                        AS total_orders_approved,
        SUM(is_delivered)                                                       AS total_orders_delivered,
        SUM(is_canceled)                                                        AS total_orders_canceled,
        SUM(late_delivery_flg)                                                  AS total_late_deliveries,

        ROUND(
            CAST(SUM(is_delivered) AS FLOAT) /
            NULLIF(COUNT(DISTINCT order_id), 0), 4
        )                                                                       AS delivery_conversion_rate
    FROM base_orders
    GROUP BY order_date;


