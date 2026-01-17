# Analytics Data Model

## Dimensions
- dim_customer
- dim_product
- dim_seller
- dim_location
- dim_date
- dim_payment

## Fact Tables
- fact_orders (order-level grain)
- fact_sales (order-item grain)
- fact_order_payment (payment transaction grain)
- fact_reviews (order-level feedback)

## Design Decisions
- Separate fact_order_payment to avoid duplicated revenue
- Use surrogate keys for all dimensions
- Use -1 rows for unknown or missing dimension references
