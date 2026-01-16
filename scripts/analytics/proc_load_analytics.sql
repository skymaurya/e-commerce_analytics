/*
===============================================================================
Stored Procedure: Load analytics Layer (CLEAN -> ANALYTICS)
===============================================================================
Script Purpose:
      This stored procedure loads the ANALYTICS layer from the CLEAN layer.
    It builds the dimensional model (Star Schema) used for reporting, dashboards,
    and advanced analytics.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage:
    EXEC analytics.load_analytics;
===============================================================================
*/




CREATE OR ALTER PROCEDURE analytics.load_analytics AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading analytics Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading dim_location Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.dim_location';

		TRUNCATE TABLE analytics.dim_location;

		PRINT '>> Inserting Data Into: analytics.dim_location';

        -- one UNKNOWN location row exists
        SET IDENTITY_INSERT analytics.dim_location ON;

        INSERT INTO analytics.dim_location (location_sk, zip_code, city, state,latitude,
    longitude)
        VALUES (-1, 'UNKNOWN', 'UNKNOWN', 'UNK',NULL,NULL);

        SET IDENTITY_INSERT analytics.dim_location  OFF;

        INSERT INTO analytics.dim_location (
            zip_code,
            city,
            state,
            latitude,
            longitude
        )
        SELECT
            loc_zip_code,
            MAX(loc_city)    AS city,
            MAX(loc_state)   AS state,
            MIN(loc_latitude)  AS latitude,
            MIN(loc_longitude) AS longitude
        FROM clean.cust_location
        WHERE loc_zip_code IN (
            SELECT DISTINCT cust_zip_code_prefix
            FROM clean.cust_info
        )
        GROUP BY loc_zip_code;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';




        ----===========dim_customer=========


        PRINT '------------------------------------------------';
		PRINT 'Loading dim_customer Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.dim_customer';

		TRUNCATE TABLE analytics.dim_customer;

		PRINT '>> Inserting Data Into: analytics.dim_customer';

        INSERT INTO analytics.dim_customer (
            cust_id,
            cust_unique_id,
            location_sk,
            city,
            state
        )
        SELECT
            c.cust_id,
            c.cust_unique_id,
           COALESCE(l.location_sk, -1)          AS location_sk,
           COALESCE(l.city,  'UNKNOWN')         AS city,
           COALESCE(l.state, 'UNK')             AS state
        FROM clean.cust_info c
        LEFT JOIN analytics.dim_location l
            ON c.cust_zip_code_prefix = l.zip_code;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        ---==========dim_product===============

        PRINT '------------------------------------------------';
		PRINT 'Loading dim_product Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.dim_product';

		TRUNCATE TABLE analytics.dim_product;

		PRINT '>> Inserting Data Into: analytics.dim_product';


        INSERT INTO analytics.dim_product (
            prd_id,
            prd_catg_name,
            prd_catg_eng,
            prd_name_len,
            prd_description_len,
            prd_photo_qty,
            prd_weight_g,
            prd_length_cm,
            prd_height_cm,
            prd_width_cm
        )
        SELECT
            p.prd_id,
            p.prd_catg_name,
            COALESCE(t.product_Eng_name, 'UNMAPPED') AS prd_catg_eng,
            COALESCE(p.prd_name_len,0) AS prd_name_len,
            COALESCE(p.prd_description_len,0) AS prd_description_len,
            COALESCE(p.prd_photo_qty,0) AS prd_photo_qty,
            p.prd_weight_g,
            p.prd_length_cm,
            p.prd_height_cm,
            p.prd_width_cm
        FROM clean.products_info p
        LEFT JOIN clean.products_catg_trans t
            ON p.prd_catg_name = t.product_catg_name;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

            ----=== sellers table   ==============

        
        PRINT '------------------------------------------------';
		PRINT 'Loading dim_seller Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.dim_seller';

		TRUNCATE TABLE analytics.dim_seller;

		PRINT '>> Inserting Data Into: analytics.dim_seller';

        INSERT INTO analytics.dim_seller (
            seller_id,
            zip_code,
            city,
            state
        )
        SELECT
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state
        FROM clean.sellers_info;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';



        ---========dim_date===============

        PRINT '------------------------------------------------';
		PRINT 'Loading dim_date Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.dim_date';

		TRUNCATE TABLE analytics.dim_date;

		PRINT '>> Inserting Data Into: analytics.dim_date';

        DECLARE @start_date DATE, @end_date DATE;

        SELECT
            @start_date = MIN(CAST(ord_purchase_date AS DATE)),
               @end_date   = MAX(
                     CAST(
                         COALESCE(
                             ord_delivered_customers_date,
                             ord_approved_date,
                             ord_purchase_date
                         ) AS DATE
                     )
                 )
        FROM clean.orders;
        IF @start_date IS NULL SET @start_date = '2010-01-01';
        IF @end_date IS NULL SET @end_date = GETDATE();

        WITH date_series AS (
            SELECT @start_date AS d
            UNION ALL
            SELECT DATEADD(DAY, 1, d)
            FROM date_series
            WHERE d < @end_date
        )
        INSERT INTO analytics.dim_date
        SELECT
            CAST(FORMAT(d, 'yyyyMMdd') AS INT) AS date_sk,
            d AS full_date,
            DAY(d) AS day_num,
            DATENAME(WEEKDAY, d) AS day_name,
            DATEPART(WEEK, d) AS week_num,
            MONTH(d) AS month_num,
            DATENAME(MONTH, d) AS month_name,
            DATEPART(QUARTER, d) AS quarter_num,
            YEAR(d) AS year_num,
            CASE 
                WHEN DATENAME(WEEKDAY, d) IN ('Saturday','Sunday') THEN 1
                ELSE 0
            END AS is_weekend
        FROM date_series
        OPTION (MAXRECURSION 0);

        INSERT INTO analytics.dim_date (
                date_sk, full_date, day_num, day_name, week_num, month_num, month_name, quarter_num, year_num, is_weekend
        )
        VALUES (
                -1, '1900-01-01', 0, 'Unknown', 0, 0, 'Unknown', 0, 0, 0
        );



        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        ---=====dim_payment=======


        PRINT '------------------------------------------------';
		PRINT 'Loading dim_payment Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.dim_payment';

		TRUNCATE TABLE analytics.dim_payment;

		PRINT '>> Inserting Data Into: analytics.dim_payment';


        -- Allow explicit -1 insert
        SET IDENTITY_INSERT analytics.dim_payment ON;

        INSERT INTO analytics.dim_payment (payment_sk, payment_type, payment_installments)
        VALUES (-1, 'UNKNOWN', 0);

        SET IDENTITY_INSERT analytics.dim_payment OFF;

        INSERT INTO analytics.dim_payment (payment_type, payment_installments)
        SELECT DISTINCT
            payment_type,
            payment_installments
        FROM clean.orders_payment
        WHERE payment_type IS NOT NULL;


        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        ----=============facts_sales=============


        PRINT '------------------------------------------------';
		PRINT 'Loading fact_sales Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.fact_sales';

		TRUNCATE TABLE analytics.fact_sales;

		PRINT '>> Inserting Data Into: analytics.fact_sales';

        WITH order_payment AS (
            SELECT
                order_id,
                SUM(payment_value) AS total_payment_value
            FROM clean.orders_payment
            GROUP BY order_id
        ),
        order_item_counts AS (
            SELECT
                order_id,
                COUNT(*) AS item_count
            FROM clean.orders_items
            GROUP BY order_id
        )
        INSERT INTO analytics.fact_sales (
            order_id,
            order_item_id,
            customer_sk,
            product_sk,
            seller_sk,
            purchase_date_sk,
            approved_date_sk,
            carrier_delivery_date_sk,
            customer_delivery_date_sk,
            price,
            freight_value,
            payment_value,
            late_delivery_flg,
            delivered_missing_dt_flg,
            canceled_delivered_flg,
            approved_not_shipped_flg,
            shipped_not_delivered_flg
        )
        SELECT
            oi.order_id,
            oi.order_item_id,
            dc.customer_sk,
            dp.product_sk,
            ds.seller_sk,
            CASE WHEN o.ord_purchase_date IS NULL THEN -1 ELSE CAST(FORMAT(o.ord_purchase_date,'yyyyMMdd') AS INT) END,
            CASE WHEN o.ord_approved_date IS NULL THEN -1 ELSE CAST(FORMAT(o.ord_approved_date,'yyyyMMdd') AS INT) END,
            CASE WHEN o.ord_delivered_carrier_date IS NULL THEN -1 ELSE CAST(FORMAT(o.ord_delivered_carrier_date,'yyyyMMdd') AS INT) END,
            CASE WHEN o.ord_delivered_customers_date IS NULL THEN -1 ELSE CAST(FORMAT(o.ord_delivered_customers_date,'yyyyMMdd') AS INT) END,
            oi.price,
            oi.freight_value,
            op.total_payment_value / ic.item_count,
            o.late_delivery_flg,
            o.delivered_missing_dt_flg,
            o.canceled_delivered_flg,
            o.approved_not_shipped_flg,
            o.shipped_not_delivered_flg
        FROM clean.orders_items oi
        JOIN clean.orders o
            ON oi.order_id = o.order_id
        JOIN order_payment op
            ON oi.order_id = op.order_id
        JOIN order_item_counts ic
            ON oi.order_id = ic.order_id
        JOIN analytics.dim_customer dc
            ON o.cust_id = dc.cust_id
        JOIN analytics.dim_product dp
            ON oi.product_id = dp.prd_id
        JOIN analytics.dim_seller ds
            ON oi.seller_id = ds.seller_id;


        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


            ---=========== fact_reviews=====
        
        PRINT '------------------------------------------------';
		PRINT 'Loading fact_reviews Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.fact_reviews';

		TRUNCATE TABLE analytics.fact_reviews;

		PRINT '>> Inserting Data Into: analytics.fact_reviews';

        INSERT INTO analytics.fact_reviews (
            review_id,
            order_id,
            customer_sk,
            review_date_sk,
            answer_date_sk,
            review_score,
            review_answered_flg
        )
        SELECT
            r.review_id,
            r.order_id,
            dc.customer_sk,
           CASE WHEN r.review_creation_dt IS NULL THEN -1 ELSE CAST(FORMAT(r.review_creation_dt,'yyyyMMdd') AS INT) END,
           CASE WHEN r.review_answer_dt IS NULL THEN -1 ELSE CAST(FORMAT(r.review_answer_dt,'yyyyMMdd') AS INT) END,
            r.review_score,
            CASE WHEN r.review_answer_dt IS NOT NULL THEN 1 ELSE 0 END
        FROM clean.orders_reviews r
        JOIN clean.orders o
            ON r.order_id = o.order_id
        JOIN analytics.dim_customer dc
            ON o.cust_id = dc.cust_id;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


            ---=======  fact_orders======

        PRINT '------------------------------------------------';
		PRINT 'Loading fact_orders Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.fact_orders';

		TRUNCATE TABLE analytics.fact_orders;

		PRINT '>> Inserting Data Into: analytics.fact_orders';

        WITH order_payment AS (
            SELECT
                order_id,
                SUM(payment_value) AS total_payment_value
            FROM clean.orders_payment
            GROUP BY order_id
        )
        INSERT INTO analytics.fact_orders (
            order_id,
            customer_sk,
            order_date_sk,
            approved_date_sk,
            delivered_date_sk,
            order_status,
            total_payment_value,
            late_delivery_flg,
            shipped_not_delivered_flg,
            canceled_flg
        )
        SELECT
            o.order_id,
            dc.customer_sk,
            
            CASE WHEN o.ord_purchase_date IS NULL THEN -1 ELSE CAST(FORMAT(o.ord_purchase_date,'yyyyMMdd') AS INT) END,
            CASE WHEN o.ord_approved_date IS NULL THEN -1 ELSE CAST(FORMAT(o.ord_approved_date,'yyyyMMdd') AS INT) END,
            CASE WHEN o.ord_delivered_customers_date IS NULL THEN -1 ELSE CAST(FORMAT(o.ord_delivered_customers_date,'yyyyMMdd') AS INT) END,
            o.order_status,
            op.total_payment_value,
            o.late_delivery_flg,
            o.shipped_not_delivered_flg,
            CASE WHEN o.order_status='canceled' THEN 1 ELSE 0 END
        FROM clean.orders o
        JOIN analytics.dim_customer dc ON o.cust_id = dc.cust_id
        LEFT JOIN order_payment op ON o.order_id = op.order_id;


        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';




        -----==========fact_order_payment

        PRINT '------------------------------------------------';
		PRINT 'Loading fact_order_payment Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: analytics.fact_order_payment';

		TRUNCATE TABLE analytics.fact_order_payment;

		PRINT '>> Inserting Data Into: analytics.fact_order_payment';

        INSERT INTO analytics.fact_order_payment (
            order_id,
            order_sk,
            payment_sk,
            payment_value
        )
        SELECT
            op.order_id,
            fo.order_sk,
            dp.payment_sk,
            op.payment_value
        FROM clean.orders_payment op
        JOIN analytics.fact_orders fo
            ON op.order_id = fo.order_id
        JOIN analytics.dim_payment dp
            ON op.payment_type = dp.payment_type
           AND op.payment_installments = dp.payment_installments;


        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading analytics Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING analytics LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '================================================='
	END CATCH
END;


