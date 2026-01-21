

/*

Purpose:
	Analyzes product-level performance by combining sales, revenue,
	customer reviews, and delivery issues.
	Used to identify top-performing and problematic products.
*/


CREATE OR ALTER VIEW analytics.vw_products_report AS

	WITH base_tbl AS (

	SELECT 
		dp.product_sk,
		dp.prd_id											AS product_id,
		dp.prd_catg_name									AS product_name,
		dp.prd_catg_eng										AS product_english_name,
		ROUND(CAST(dp.prd_weight_g AS FLOAT),2)				AS product_weight_gram,
		ROUND(CAST(dp.prd_length_cm AS FLOAT),2)			AS product_length_cm,
		ROUND(CAST(dp.prd_height_cm AS FLOAT),2)			AS product_height_cm,
		ROUND(CAST(dp.prd_width_cm AS FLOAT),2)				AS product_width_cm
	FROM analytics.dim_product AS dp

	),

	prd_perform AS (

	SELECT 
		FS.product_sk,
		COUNT(product_sk)									AS total_quantity_sold,
		SUM(FS.payment_value)								AS total_sales_value,
		ROUND(AVG(CAST (FS.price AS FLOAT)),2)				AS avg_selling_price,
		MAX(FS.price)										AS max_single_ord_value,
		COUNT(DISTINCT fs.order_id)							AS total_orders,
		SUM(
		CASE 
			WHEN FS.approved_not_shipped_flg=1 OR FS.shipped_not_delivered_flg=1 THEN 1 
			ELSE 0 
		END)												AS  undelivered_count,

		SUM(
		CASE 
			WHEN FS.late_delivery_flg=1  THEN 1 
			ELSE 0 
		END)												AS late_delivery_count,
		ROUND(
			CAST(SUM(CASE WHEN late_delivery_flg = 1 THEN 1 ELSE 0 END) AS FLOAT)
			/ NULLIF(COUNT(*), 0),
		2
		)													AS late_delivery_rate

	FROM analytics.fact_sales FS

	GROUP BY product_sk
	),

	cust_review AS (

	SELECT  
		fs.product_sk,
		ROUND(AVG(CAST(fr.review_score AS FLOAT)),2)		AS avg_customer_score,
		COUNT(fr.review_score)								AS  review_count  
	FROM analytics.fact_sales AS fs
	JOIN analytics.fact_reviews AS fr
	ON fs.order_id=fr.order_id
	GROUP BY product_sk
	)


	SELECT  
		bt.product_id,
		bt.product_name,
		bt.product_english_name,
		bt.product_weight_gram,
		bt.product_length_cm,
		bt.product_width_cm,
		bt.product_height_cm,
		pp.total_quantity_sold,
		pp.total_sales_value,
		pp.avg_selling_price,
		pp.max_single_ord_value,
		pp.total_orders,
		pp.late_delivery_count,
		pp.undelivered_count,
		cr.avg_customer_score,
		cr.review_count,

		---product  segmentation

		CASE
			WHEN total_sales_value >= 15000 AND total_quantity_sold >= 100 AND avg_customer_score >= 4.0 THEN 'Top_Product'
			WHEN total_sales_value >= 7000 AND total_quantity_sold >= 50 THEN 'High_Performer'
			WHEN total_quantity_sold >= 20  THEN 'Growing_Product'
			WHEN total_quantity_sold >= 5  THEN 'Low_Volume'
			ELSE 'Inactive'
		END														AS product_segment,

		CASE
			WHEN late_delivery_rate > 0.25
				 OR undelivered_count > 10
				 THEN 'Operational_Risk'
			ELSE 'Healthy'
		END														AS product_health_flag

	FROM base_tbl AS bt
	LEFT JOIN  prd_perform AS pp
	ON bt.product_sk=pp.product_sk
	LEFT JOIN cust_review AS cr
	ON bt.product_sk=cr.product_sk;


