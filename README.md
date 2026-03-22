
🔗 Tableau Dashboard: [ Tableau Public Link  (https://public.tableau.com/app/profile/akash.maurya3794/viz/E-CommerceAnalyticsDashboards_17705097981670/Product)]

# 🛒 E-Commerce Analytics | SQL + Tableau | End-to-End Business Insights

This project analyzes e-commerce data to uncover key business insights related to **customer behavior, sales performance, and operational efficiency** using SQL and Tableau.

---

## 🎯 Project Objective :

Design an analytics layer that enables stakeholders to answer key **business questions** related to:
- Customer behavior & retention
- Seller performance & quality
- Product performance
- Order lifecycle & funnel analysis
- Payment method effectiveness

This project replicates a **real-world analytics workflow** used in modern data-driven organizations.

## 📌 Business Problem Statement :

The e-commerce platform needs visibility into:

- Revenue growth and decline patterns

- Customer retention and repeat purchase behavior

- Seller reliability and delivery performance

- Product performance and operational risk

- Order funnel efficiency

This project transforms raw transactional data into **decision-ready insights** for executives and operations teams.


---

## 🏗️ Architecture Overview :

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

## 🧱 Data Model (Analytics Layer) :

The following data model supports analytical reporting and dashboard creation:

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

## 📊 Business Analytics Views :

These views are the **primary deliverables for a Data Analyst**.
These views simulate **real-world data marts used by analysts for reporting and dashboards**.

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

## 📈 Executive Dashboards (Tableau)  :

The analytics views were used to build interactive executive dashboards in Tableau, transforming SQL outputs into stakeholder-ready insights.  

---

## 📊 Dashboard Modules 

### 1️⃣ Executive Overview  

- Revenue & order trend (2016–2018)  
- Geographic revenue distribution  
- Order funnel performance  
- Late delivery analysis  

---

### 2️⃣ Customer Analytics  

- Customer segmentation (New, Repeat, High Value, VIP)  
- Retention funnel  
- Customer lifespan & lifetime spending  
- At-risk customer identification  

---

### 3️⃣ Seller Performance  

- Revenue contribution by seller segment  
- Late delivery rate analysis  
- Seller concentration risk  
- Top-performing seller identification  

---

### 4️⃣ Product Performance  

- Category-level revenue analysis  
- Product quality vs revenue relationship  
- Late delivery by product segment  
- Undelivered product analysis  

---

## 📌 Business Impact of Dashboards  :

The dashboards were designed for:  

- Executive-level monitoring  
- Operational performance tracking  
- Retention strategy planning  
- Revenue growth decision support  

---

## 🛠 Tools Used  :

- SQL Server (Data Warehouse Design)  
- Tableau (Data Visualization & Dashboarding)  
- Dimensional Modeling (Star Schema)  
- Business KPI Design  


## ✅ Data Quality & Validation :

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

## 📂 Repository Structure :

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

## 💡 Skills Demonstrated :

- SQL-based data analysis
- Dimensional modeling (Star Schema)
- Business metric design
- Funnel & cohort analysis
- Data quality validation
- Documentation for stakeholders
- Executive dashboard storytelling


---

This repository demonstrates how data is **transformed into actionable business insights**.

---

## 📊 Executive Summary

- This project converts raw e-commerce transactional data into a structured analytics layer and interactive dashboards.
- The analysis reveals revenue growth patterns, customer retention risks, seller concentration dependency, and product-level operational issues, enabling data-driven business decisions.

## 📌 Key Business Insights  :

---

### 🔹 Revenue Trends  

-Revenue grew significantly in 2017 but slowed in 2018, indicating potential market saturation

---

### 🔹 Customer Retention Risk  

- 80% one-time buyers  
- 57% at-risk customers  
- Opportunity for loyalty programs  

---

### 🔹 Seller Concentration  

- 50% revenue from growing seller segment  
- Platform dependency risk identified  

---

### 🔹 Product Performance  

- 4★+ rated products dominate revenue  
- Inactive products linked to late deliveries  

---

### 🔹 Geographic Concentration  

- Revenue concentrated in South/Southeast  
- Expansion potential in emerging regions  


## 🎯 Strategic Recommendations :

Based on the analysis:

- Launch retention campaigns targeting 57% at-risk customers

- Diversify seller base to reduce revenue concentration risk

- Promote high-rated product categories (4★+)

- Optimize logistics to reduce late deliveries in low-performing product segments

- Expand marketing in emerging states with growing revenue contribution
