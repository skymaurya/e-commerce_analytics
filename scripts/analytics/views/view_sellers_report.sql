/*
Purpose:
	Aggregates seller performance metrics including sales volume, revenue,
	customer ratings, and delivery reliability.
	Used to evaluate seller quality and operational effectiveness.
*/


CREATE OR ALTER VIEW analytics.vw_sellers_report AS

	WITH base_sellers AS (
	SELECT 
			ds.seller_id,
			ds.seller_sk,
			ds.city,
			ds.state,
			dm.latitude,
			dm.longitude
	FROM analytics.dim_seller ds
	LEFT JOIN  analytics.dim_location AS dm
	ON ds.zip_code=dm.zip_code

	),

	late as (

		SELECT
		seller_sk,
		ROUND( SUM(cast (is_late as float)) / COUNT(DISTINCT order_id),2) AS late_delivery_rate
	FROM 
	(
	 SELECT
			seller_sk,
			order_id,
			MAX(cast (late_delivery_flg AS int)) AS is_late
		FROM analytics.fact_sales
		GROUP BY seller_sk, order_id)t
	GROUP BY seller_sk

	),

	 sales_perform AS (
	SELECT 
		fs.seller_sk,
		COUNT(DISTINCT fs.order_id)							AS	total_orders,
		COUNT(*)											AS total_items_sold,
		SUM(fs.payment_value)								AS total_sales_value,
		COUNT(DISTINCT fs.product_sk)						AS	distinct_product_sold,
		ROUND(CAST(SUM(fs.price )AS FLOAT)/COUNT (*),2)		AS	avg_item_price
	FROM analytics.fact_sales  AS fs
	GROUP BY fs.seller_sk
	),

	seller_qualty AS (
	SELECT 
		fs.seller_sk,
		AVG(fr.review_score)								 AS avg_review_score,
		SUM(CASE WHEN fs.canceled_delivered_flg=1 THEN 1
		ELSE 0 END)											 AS cancel_order_count

	FROM analytics.fact_reviews AS fr
	LEFT JOIN  analytics.fact_sales AS fs 
	ON fr.order_id=fs.order_id
	GROUP BY fs.seller_sk

	)


	SELECT 
		bs.seller_id,
		bs.city,
		bs.state,
		bs.latitude,
		bs.longitude,
		sp.total_orders,
		sp.distinct_product_sold,
		sp.total_items_sold,
		sp.total_sales_value,
		sp.avg_item_price ,
		q.avg_review_score ,
		b.late_delivery_rate,
		q.cancel_order_count,
		CASE
			WHEN total_sales_value >= 50000 AND total_orders >= 100 AND avg_review_score >= 4.0 AND late_delivery_rate <= 0.10 THEN 'Top_Seller'

			WHEN total_sales_value >= 20000 AND total_orders >= 50 AND avg_review_score >= 3.8  THEN 'High_Performer'

			WHEN total_sales_value >= 5000  AND total_orders >= 10 THEN 'Growing_Seller'

			WHEN total_orders >= 3 THEN 'Occasional_Seller'

			ELSE 'New/Inactive_Seller'

		END														  AS seller_segment

	FROM base_sellers AS bs
	LEFT JOIN sales_perform AS sp
	ON bs.seller_sk=sp.seller_sk
	LEFT JOIN seller_qualty AS q
	ON bs.seller_sk=q.seller_sk
	LEFT JOIN late AS b
	on b.seller_sk=bs.seller_sk;
