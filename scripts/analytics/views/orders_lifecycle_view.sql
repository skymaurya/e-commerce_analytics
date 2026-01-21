

/*

Purpose:
    Tracks the complete lifecycle of each order from creation to delivery,
    including delivery duration and late delivery indicators.
    Used for operational and logistics performance analysis.
*/



CREATE OR ALTER VIEW analytics.vw_order_lifecycle AS

    WITH base AS(

        SELECT
            fo.order_id,
            fo.order_status,
            od.full_date                                        AS order_date,
            ad.full_date                                        AS approved_date,
            dd.full_date                                        AS delivered_date,

            CASE
                WHEN fo.delivered_date_sk = -1 THEN NULL
                WHEN fo.order_date_sk     = -1 THEN NULL
                WHEN dd.full_date < od.full_date THEN -1
                ELSE DATEDIFF(DAY, od.full_date, dd.full_date)
            END                                                 AS delivery_days,

            fo.late_delivery_flg,
            fo.shipped_not_delivered_flg,
            fo.canceled_flg
        FROM analytics.fact_orders fo

        LEFT JOIN analytics.dim_date od
            ON fo.order_date_sk = od.date_sk

        LEFT JOIN analytics.dim_date ad
            ON fo.approved_date_sk = ad.date_sk

        LEFT JOIN analytics.dim_date dd
            ON fo.delivered_date_sk = dd.date_sk
    )

        SELECT 
            *,
            CASE  
                WHEN order_status <> 'delivered' 
                    THEN 'Cancelled/Not_Delivered'

                WHEN delivery_days IS NULL 
                    THEN 'Delivered_Unknown_Days'

                WHEN delivery_days <= 3 
                    THEN 'Fast_Delivery'

                WHEN delivery_days BETWEEN 4 AND 7 
                    THEN 'On-Time_Delivery'

                WHEN delivery_days BETWEEN 8 AND 10 
                    THEN 'Delayed'

                ELSE 'Severely_Delayed'

            END                                                      AS Delivery_Performance

        FROM base;


