

/*
Purpose:
	Analyzes payment behavior by payment method and installment count,
	including revenue contribution and average order value.
	Used to understand customer payment preferences and monetization.
*/


CREATE OR ALTER VIEW  analytics.vw_payment_analysis AS 

	SELECT 
		dp.payment_type,
		dp.payment_installments,
		COUNT( DISTINCT fop.order_id)					AS  total_orders,
		SUM(fop.payment_value)							AS total_revenue,
		ROUND(
			  SUM(CAST(fop.payment_value AS FLOAT)) 
			  / NULLIF(COUNT(DISTINCT fop.order_id),0),
			2)											AS  avg_order_value

	FROM analytics.dim_payment AS dp
	LEFT JOIN analytics.fact_order_payment AS fop
	ON dp.payment_sk=fop.payment_sk
	GROUP BY dp.payment_type,dp.payment_installments;

