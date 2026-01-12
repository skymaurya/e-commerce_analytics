/*
===============================================================================
Stored Procedure: Load CLEAN Layer (RAWS -> CLEAN)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'clean' schema tables from the 'raws' schema.
	Actions Performed:
		- Truncates clean tables.
		- Inserts transformed and cleansed data from raws into clean tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC clean.load_clean;
===============================================================================
*/


CREATE OR ALTER PROCEDURE clean.load_clean AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading clean Layer';
        PRINT '================================================';


		--====== cust_info table =========================
		PRINT '------------------------------------------------';
		PRINT 'Loading cust_info Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: clean.cust_info';
		TRUNCATE TABLE clean.cust_info;
		PRINT '>> Inserting Data Into: clean.cust_info';
		INSERT INTO clean.cust_info(

			cust_id ,          
			cust_unique_id ,      
			cust_zip_code_prefix ,
			cust_city ,       
			cust_state
		)
		SELECT 
			TRIM(cust_id),
			TRIM(cust_unique_id),
			(cust_zip_code_prefix),
			LOWER(TRIM(cust_city)),
			UPPER(TRIM(cust_state))
		FROM raws.customers_info
		WHERE cust_id is not null;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		---============cust location table=================

		PRINT '------------------------------------------------';
		PRINT 'Loading cust_location Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: clean.cust_location';
		TRUNCATE TABLE clean.cust_location;
		PRINT '>> Inserting Data Into: clean.cust_location';

		INSERT INTO clean.cust_location(
			loc_zip_code,
			loc_latitude,
			loc_longitude,
			loc_city,
			loc_state
		)
		SELECT 
			TRIM(loc_zip_code),
			loc_latitude,
			loc_longitude,
			LOWER(TRIM(loc_city)),
			UPPER(TRIM(loc_state))
		FROM raws.cust_location

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';



		------=================orders table===================

		PRINT '------------------------------------------------';
		PRINT 'Loading orders Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: clean.orders';
		TRUNCATE TABLE clean.orders;

		PRINT '>> Inserting Data Into: clean.orders';

		INSERT INTO clean.orders(
			order_id,
			cust_id,
			order_status,
			ord_purchase_date,
			ord_approved_date,
			ord_delivered_carrier_date,
			ord_delivered_customers_date,
			ord_estimated_delivery_date,
			late_delivery_flg,
			delivered_missing_dt_flg,
			canceled_delivered_flg,
			approved_not_shipped_flg,
			shipped_not_delivered_flg

		)

		SELECT  
			TRIM(order_id),
			TRIM(cust_id),
			LOWER(TRIM(order_status)),
			CASE
				WHEN ord_purchase_date>ord_delivered_carrier_date  OR ord_purchase_date>ord_approved_date THEN  NULL
				ELSE ord_purchase_date
			END AS ord_purchase_date,

			CASE
				WHEN ord_approved_date>ord_delivered_carrier_date THEN NULL
				ELSE ord_approved_date
			END AS ord_approved_date,

			CASE 
				WHEN ord_delivered_carrier_date>ord_delivered_customers_date THEN NULL
				ELSE ord_delivered_carrier_date
			END AS ord_delivered_carrier_date,
			ord_delivered_customers_date,
			ord_estimated_delivery_date,

			----FLAGS 

			CASE
				WHEN  ord_delivered_customers_date>ord_estimated_delivery_date THEN 1
				ELSE 0
			END AS late_delivery_flg,

			CASE 
				WHEN order_status='delivered'
				AND (
					ord_approved_date IS NULL
					OR ord_delivered_carrier_date IS NULL
					OR ord_delivered_customers_date IS NULL
				)
				THEN 1 ELSE 0
			END AS delivered_missing_dt_flg,

			CASE 
				WHEN order_status='canceled' and ord_delivered_customers_date IS NOT NULL THEN 1
				ELSE 0
			END AS  canceled_delivered_flg,

			CASE 
				WHEN order_status IN ('approved','invoiced','processing')  AND ord_delivered_carrier_date IS NULL  THEN 1 
				ELSE 0
			END AS approved_not_shipped_flg,

			CASE
				WHEN order_status='shipped' and ord_delivered_customers_date IS NULL THEN 1
				ELSE 0
			END AS shipped_not_delivered_flg

		FROM raws.orders
		WHERE order_id IS NOT NULL

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-----=====================order_payment table===============================

		PRINT '------------------------------------------------';
		PRINT 'Loading orders_payment Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: clean.orders_payment';
		TRUNCATE TABLE clean.orders_payment;
		PRINT '>> Inserting Data Into: clean.orders_payment';

		INSERT INTO clean.orders_payment(	
			order_id,
			payment_sequence,
			payment_type,
			payment_installments,
			payment_value
		)

		SELECT 
			TRIM(order_id),
			payment_sequence,
			LOWER(TRIM(payment_type)),
			payment_installments,
			payment_value
		FROM raws.order_payment
		WHERE order_id IS NOT NULL AND payment_sequence IS NOT NULL;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';



		
		

		---=====================OREDER_ITEMS table=========================

		PRINT '------------------------------------------------';
		PRINT 'Loading orders_items Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: clean.orders_items';
		TRUNCATE TABLE clean.orders_items;
		PRINT '>> Inserting Data Into: clean.orders_items';

		INSERT INTO clean.orders_items(
			order_id,
			order_item_id,
			product_id,
			seller_id,
			shipping_limit_date,
			price,
			freight_value
		)

		SELECT 
			TRIM(order_id),
			order_item_id,
			TRIM(product_id),
			TRIM(seller_id),
			shipping_limit_date,
			price,
			freight_value
			FROM raws.orders_items
			WHERE order_id IS NOT NULL AND order_item_id IS NOT NULL;

			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';


			---=============ORDER_REVIEW table=========================
		PRINT '------------------------------------------------';
		PRINT 'Loading orders_reviews Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: clean.orders_reviews';
		TRUNCATE TABLE clean.orders_reviews;
		PRINT '>> Inserting Data Into: clean.orders_reviews';

		INSERT INTO clean.orders_reviews(
			review_id,
			order_id,
			review_score,
			review_title,
			review_message,
			review_creation_dt,
			review_answer_dt
		)

		SELECT 
			TRIM(review_id),
			TRIM(order_id),
			review_score,
			TRIM(review_comment_title),
			TRIM(review_comment_message),
			review_creation_date,
			review_answer_timestamp
		FROM  raws.orders_reviews
		WHERE review_id IS NOT NULL AND order_id IS NOT NULL;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';



		----===========PRODUCT TRANS TABLE==================

		PRINT '------------------------------------------------';
		PRINT 'Loading products_catg_trans Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: clean.products_catg_trans';
		TRUNCATE TABLE clean.products_catg_trans;

		PRINT '>> Inserting Data Into: clean.products_catg_trans';

		INSERT INTO  clean.products_catg_trans(
			product_catg_name,
			product_Eng_name
		)

		SELECT 
			LOWER(TRIM(product_catg_name)),
			LOWER(TRIM(product_Eng_name))

		FROM raws.prd_catg_trans
		WHERE product_catg_name IS NOT NULL;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		----============= product info table==================

		
		PRINT '------------------------------------------------';
		PRINT 'Loading products_info Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: clean.products_info';
		TRUNCATE TABLE clean.products_info;

		PRINT '>> Inserting Data Into: clean.products_info';
		

		INSERT INTO clean.products_info(
			prd_id,
			prd_catg_name,
			prd_name_len,
			prd_description_len,
			prd_photo_qty,
			prd_weight_g,
			prd_length_cm,
			prd_height_cm,
			prd_width_cm
		)
		SELECT  
			TRIM(prd_id),
			LOWER(TRIM(prd_catg_name)),
			prd_name_len,
			prd_description_len,
			prd_photo_qty,
			ROUND(CASE 
					WHEN prd_weight_g <= 0 THEN NULL
					ELSE prd_weight_g
				END,3) AS prd_weight_g,

			ROUND(CASE 
					WHEN prd_length_cm <= 0 THEN NULL 
					ELSE prd_length_cm 
				END,2) AS prd_length_cm,

			ROUND(CASE 
					WHEN prd_height_cm <= 0 THEN NULL 
					ELSE prd_height_cm 
				END,2) AS prd_height_cm,

			ROUND(CASE 
					WHEN prd_width_cm  <= 0 THEN NULL 
					ELSE prd_width_cm  
				END,2) AS prd_width_cm

		FROM raws.products_info
		WHERE prd_id IS NOT NULL;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		---===============SELLER INFO ============

		PRINT '------------------------------------------------';
		PRINT 'Loading sellers_info Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: clean.sellers_info';
		TRUNCATE TABLE clean.sellers_info;

		PRINT '>> Inserting Data Into: clean.sellers_info';

		INSERT INTO clean.sellers_info(

			seller_id,
			seller_zip_code_prefix,
			seller_city,
			seller_state
		)

		SELECT 
			TRIM(seller_id),
			seller_zip_code_prefix,
			LOWER(TRIM(seller_city)),
			UPPER(TRIM(seller_state))
		FROM raws.sellers_info
		WHERE seller_id IS NOT NULL;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
		

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading clean Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING clean LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '================================================='
	END CATCH
END

