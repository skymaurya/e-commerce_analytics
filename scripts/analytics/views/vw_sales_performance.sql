

/*

Purpose:
	Summarizes daily sales performance including order volume,
	revenue, average order value, and items sold.
	Used for trend analysis and revenue monitoring.

*/


CREATE OR ALTER VIEW analytics.vw_sales_performance_daily AS 

	WITH base AS (

		SELECT 
			dd.full_date							AS purchase_date,
			COUNT( DISTINCT fs.order_id)			AS total_orders,
			SUM(fs.payment_value)					AS total_revenue,
			ROUND(
				SUM(CAST(fs.payment_value AS FLOAT))/COUNT( DISTINCT fs.order_id)
				,2
			)										AS  avg_order_value,
			COUNT(*)								AS total_item_sold
		FROM analytics.fact_sales  AS fs
		LEFT JOIN  analytics.dim_date AS dd
		ON  fs.purchase_date_sk=dd.date_sk
		WHERE fs.purchase_date_sk <> -1
		GROUP BY full_date

	)
		SELECT 
		 CASE
			WHEN total_orders BETWEEN 50 AND 100 AND total_revenue BETWEEN 10000 AND 25000 THEN 'Medium Orders / Medium Revenue' 
			WHEN total_orders BETWEEN 101 AND 200 AND total_revenue BETWEEN 25000 AND 50000 THEN 'High Orders / High Revenue' 
			WHEN total_orders BETWEEN 101 AND 200 AND total_revenue BETWEEN 10000 AND 25000 THEN 'High Orders / Medium Revenue' 
			WHEN total_orders BETWEEN 201 AND 300 AND total_revenue BETWEEN 25000 AND 50000 THEN 'Very High Orders / High Revenue'  
			WHEN total_orders > 300 AND total_revenue > 50000 THEN 'Top Performing'  
			ELSE 'Low Orders / Low Revenue' 
		END												AS daily_performance,
		*	   
		FROM base;


