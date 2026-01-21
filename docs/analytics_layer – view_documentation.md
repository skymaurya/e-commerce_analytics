
### ⚠️ Important Note on Grain  
- Each view is designed with a specific grain.  
- Views should NOT be joined together unless the grain is respected, to avoid double counting.


    # 📊 Analytics Layer – View Documentation

This document describes all **business-facing analytics views** created in the `analytics` schema.  
These views are designed to support **reporting, dashboards, and ad-hoc business analysis**.

---

## 1. analytics.vw_customers_report

### 📌 Purpose
Provides a **360° view of customers**, aggregating purchasing behavior, spending, reviews, geography, and segmentation.

### 🧱 Grain
- One row per customer (`cust_unique_id`)

### 🔑 Key Columns

| Column                  | Description                                                   |
|------------------------|---------------------------------------------------------------|
| cust_unique_id         | Unique business identifier for a customer                     |
| city, state            | Customer location                                             |
| total_orders           | Total number of orders placed                                 |
| total_spending         | Lifetime spend                                                |
| avg_review_score       | Average review score given by the customer                    |
| customer_lifespan_days | Days between first and last purchase                          |
| customer_segment       | Business segmentation (New, Repeat, Average, High Value, VIP) |

### 📈 Business Questions Answered
- Who are our most valuable customers?
- How many repeat vs new customers do we have?
- What is the customer lifetime value proxy?
- How does geography affect spending?

---

## 2. analytics.vw_customers_funnel

### 📌 Purpose
Represents the **customer funnel**, tracking progression from first purchase to repeat and high-value behavior.

### 🧱 Grain
- One row per customer (`cust_unique_id`)

### 🔑 Key Columns

| Column                  | Description                                   |
|------------------------|-----------------------------------------------|
| total_orders           | Number of orders placed                       |
| total_spending         | Total revenue generated                       |
| first_order_date       | First purchase date                           |
| last_order_date        | Most recent purchase date                     |
| customer_lifespan_days | Active lifespan                               |
| is_repeat_customer     | Indicator for repeat behavior                 |
| customer_stage         | Funnel stage (New, Repeat, Loyal, High Value) |

### 📈 Business Questions Answered
- How many customers convert from first-time to repeat?
- What percentage of customers become loyal or high value?
- Where do customers drop off in the funnel?

---

## 3. analytics.vw_sellers_report

### 📌 Purpose
Analyzes **seller performance, quality, and reliability**.

### 🧱 Grain
- One row per seller

### 🔑 Key Columns

| Column                | Description                   |
|----------------------|-------------------------------|
| seller_id            | Seller identifier             |
| total_orders         | Orders fulfilled              |
| distinct_product_sold| Number of products sold       |
| total_sales_value    | Revenue generated             |
| avg_review_score     | Average customer rating       |
| late_delivery_rate   | Percentage of late deliveries |
| cancel_order_count   | Number of canceled orders     |

### 📈 Business Questions Answered
- Who are the top-performing sellers?
- Which sellers have quality or delivery issues?
- Should certain sellers be promoted or reviewed?

---

## 4. analytics.vw_products_report

### 📌 Purpose
Evaluates **product-level performance**, customer satisfaction, and delivery issues.

### 🧱 Grain
- One row per product

### 🔑 Key Columns

| Column               | Description                  |
|---------------------|------------------------------|
| product_id          | Product identifier           |
| total_quantity_sold | Units sold                   |
| total_sales_value   | Total revenue                |
| avg_selling_price   | Average selling price        |
| avg_customer_score  | Average review score         |
| product_segment     | Product performance segment  |
| undelivered_count   | Orders not delivered         |
| late_delivery_count | Late deliveries              |

### 📈 Business Questions Answered
- Which products drive the most revenue?
- Which products cause logistics issues?
- Are high-selling products also highly rated?

---

## 5. analytics.vw_order_lifecycle

### 📌 Purpose
Tracks the **end-to-end lifecycle of orders**, from purchase to delivery.

### 🧱 Grain
- One row per order

### 🔑 Key Columns

| Column             | Description             |
|-------------------|-------------------------|
| order_id          | Order identifier        |
| ordered_date      | Purchase date           |
| approved_date     | Approval date           |
| delivered_date    | Delivery date           |
| delivery_days     | Days taken to deliver   |
| late_delivery_flg | Late delivery indicator |

### 📈 Business Questions Answered
- How long does order fulfillment take?
- Where do delivery delays occur?
- What percentage of orders are late?

---

## 6. analytics.vw_orders_funnel_daily

### 📌 Purpose
Tracks the **daily progression of orders** through key lifecycle stages, forming a true order funnel.

### This view helps understand:
- Order drop-offs
- Approval efficiency
- Delivery success
- Late delivery impact

### 🧱 Grain
- One row per order creation date

### 🔑 Key Columns

| Column                    | Description                     |
|--------------------------|---------------------------------|
| order_date               | Date when orders were created   |
| total_orders_created     | Orders placed on that date      |
| total_orders_approved    | Orders approved                 |
| total_orders_delivered   | Orders successfully delivered  |
| total_orders_canceled    | Orders canceled                 |
| total_late_deliveries    | Delivered orders that were late|
| delivery_conversion_rate | Delivered ÷ Created orders      |

### 📈 Business Questions Answered
- How many orders drop off before delivery?
- What is the approval → delivery conversion rate?
- Are delivery issues increasing over time?
- Which days show operational bottlenecks?

---

## 7. analytics.vw_payment_analysis

### 📌 Purpose
Analyzes **payment method usage and performance**.

### 🧱 Grain
- One row per payment method & installment combination

### 🔑 Key Columns

| Column                | Description           |
|----------------------|-----------------------|
| payment_type         | Payment method        |
| payment_installments | Installment count     |
| total_orders         | Orders paid           |
| total_revenue        | Revenue generated     |
| avg_order_value      | Average payment value |

### 📈 Business Questions Answered
- Which payment methods are most popular?
- Do installments increase order value?
- Which payment types generate most revenue?

---

## 8. analytics.vw_sales_performance_daily

### 📌 Purpose
Tracks **daily sales performance** at an aggregate level.

### 🧱 Grain
- One row per day

### 🔑 Key Columns

| Column           | Description         |
|-----------------|---------------------|
| full_date       | Date                |
| total_orders    | Orders              |
| total_revenue   | Revenue             |
| avg_order_value | Average order value |
| total_item_sold | Items sold          |

### 📈 Business Questions Answered
- What are daily revenue trends?
- How does demand fluctuate?
- Are promotions or seasons visible in sales?

---

## ✅ Summary

This analytics layer:
- Covers **customers, sellers, products, orders, and payments**
- Supports **operational, financial, and strategic analysis**
- Follows **correct dimensional modeling and grain consistency**
- Is **production-ready and portfolio-quality**
