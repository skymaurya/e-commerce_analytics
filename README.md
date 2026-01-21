# 📊 E-Commerce Analytics Project (Data Analyst Portfolio)

This project demonstrates a **business-focused analytics solution** built on top of an end-to-end SQL data warehouse.  
The goal of this repository is **not data engineering tooling**, but **data analysis readiness**: clean data, reliable metrics, and business-answering views.

---

## 🎯 Project Objective

Design an analytics layer that enables stakeholders to answer key **business questions** related to:
- Customer behavior & retention
- Seller performance & quality
- Product performance
- Order lifecycle & funnel analysis
- Payment method effectiveness

This project mirrors a **real-world analytics workflow** used by data analysts.

---

## 🏗️ Architecture Overview

The warehouse follows a classic **3-layer architecture**:

### 1️⃣ RAW Layer
- Source system ingestion (no transformations)
- Mirrors operational data structure

### 2️⃣ CLEAN Layer
- Data cleansing & standardization
- Business rule enforcement (invalid dates, flags)
- One-to-one mapping with source entities

### 3️⃣ ANALYTICS Layer
- Star-schema dimensional model
- Fact & dimension tables
- Business-ready analytics views

---

## 🧱 Data Model (Analytics Layer)

**Dimensions**
- `dim_customer`
- `dim_product`
- `dim_seller`
- `dim_location`
- `dim_date`
- `dim_payment`

**Facts**
- `fact_orders`
- `fact_sales`
- `fact_reviews`
- `fact_order_payment`

All fact tables:
- Use **surrogate keys**
- Enforce consistent grain
- Handle missing data via `-1 (UNKNOWN)` members

---

## 📊 Business Analytics Views

These views are the **primary deliverables for a Data Analyst**.

### 🔹 Customer Analytics
- `vw_customers_report` – 360° customer profile & segmentation
- `vw_customers_funnel` – Customer lifecycle & retention funnel

### 🔹 Seller Analytics
- `vw_sellers_report` – Sales, ratings, delivery quality

### 🔹 Product Analytics
- `vw_products_report` – Sales performance & delivery issues

### 🔹 Order & Operations
- `vw_order_lifecycle` – End-to-end order timeline
- `vw_orders_funnel_daily` – Daily operational funnel

### 🔹 Financial & Sales
- `vw_payment_analysis` – Payment method performance
- `vw_sales_performance_daily` – Daily revenue trends

Each view:
- Has a **defined grain**
- Answers **specific business questions**
- Is ready for dashboards or ad-hoc analysis

---

## ✅ Data Quality & Validation

Validation scripts ensure:
- No broken surrogate key joins
- Correct fact table grain
- Revenue reconciliation between facts
- Proper handling of missing dates

These checks mimic **real analytics QA processes**.

---

## 🧪 Validation Coverage

- Order count reconciliation
- Item-level vs order-level revenue checks
- Surrogate key integrity
- Funnel consistency checks

---

## 📂 Repository Structure

```
/scripts
  ├── clean        # CLEAN layer DDL & load procedures
  ├── analytics    # Analytics DDL, load procedures & views
/tests
  ├── clean        # Clean layer validation
  ├── analytics    # Analytics layer validation
/docs
  ├── diagrams     # Data model & ETL diagrams
```

---

## 💡 Skills Demonstrated

- SQL-based data analysis
- Dimensional modeling (Star Schema)
- Business metric design
- Funnel & cohort analysis
- Data quality validation
- Documentation for stakeholders

---

## 📌 Who This Project Is For

✔ Data Analyst roles  
✔ Analytics Engineer roles  
✔ Business Intelligence roles  

This repository focuses on **how data is analyzed**, not just how it is moved.

---

