# Data Validation & Quality Checks

## Row Count Validation
- Ensures no data loss between layers

## Grain Validation
- fact_orders: 1 row per order
- fact_sales: 1 row per order × item

## Revenue Validation
- Payments in RAW = fact_order_payment = fact_orders

## Surrogate Key Integrity
- No NULL foreign keys
- All dimensions contain -1 default rows
