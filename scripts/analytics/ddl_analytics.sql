/*
===============================================================================
DDL Script: Create analytics Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'analytics' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'analytics' Tables
===============================================================================
*/


----========dim_location ==============

IF OBJECT_ID('analytics.dim_location','U') IS NOT NULL
    DROP TABLE analytics.dim_location;
GO
CREATE TABLE analytics.dim_location (
    location_sk        INT IDENTITY(1,1) PRIMARY KEY,
    zip_code           NVARCHAR(8),
    city               NVARCHAR(45),
    state              CHAR(3),
    latitude           DECIMAL(8,6),
    longitude          DECIMAL(9,6),
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
);


GO

-----==========dim_customers===================

IF OBJECT_ID('analytics.dim_customer','U') IS NOT NULL
    DROP TABLE analytics.dim_customer;

GO

CREATE TABLE analytics.dim_customer (
    customer_sk       INT IDENTITY(1,1) PRIMARY KEY,
    cust_id           NVARCHAR(35),
    cust_unique_id    NVARCHAR(35),
    location_sk       INT,
    city              NVARCHAR(45),
    state             CHAR(3),
    dwh_create_date   DATETIME2 DEFAULT GETDATE()
);

GO

---==========dim_products============

IF OBJECT_ID('analytics.dim_product','U') IS NOT NULL
    DROP TABLE analytics.dim_product;

GO

CREATE TABLE analytics.dim_product(
    product_sk              INT IDENTITY(1,1) PRIMARY KEY,
    prd_id                  NVARCHAR(35),     
    prd_catg_name           NVARCHAR(80),    
    prd_catg_eng            NVARCHAR(50),     
    prd_name_len            TINYINT,
    prd_description_len     SMALLINT,
    prd_photo_qty           TINYINT,
    prd_weight_g            DECIMAL(10,3),
    prd_length_cm           DECIMAL(10,2),
    prd_height_cm           DECIMAL(10,2),
    prd_width_cm            DECIMAL(10,2),
    dwh_create_date         DATETIME2 DEFAULT GETDATE()
);

GO

---====== dim_sellers table  ======

IF OBJECT_ID('analytics.dim_seller','U') IS NOT NULL
    DROP TABLE analytics.dim_seller;

GO

CREATE TABLE analytics.dim_seller (
    seller_sk        INT IDENTITY(1,1) PRIMARY KEY,
    seller_id        NVARCHAR(35),
    zip_code         NVARCHAR(8),
    city             NVARCHAR(45),
    state            CHAR(3),
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);

GO

---============dim_dates================

IF OBJECT_ID('analytics.dim_date','U') IS NOT NULL
    DROP TABLE analytics.dim_date;

GO

CREATE TABLE analytics.dim_date(
    date_sk        INT PRIMARY KEY,       
    full_date      DATE,
    day_num        TINYINT,
    day_name       NVARCHAR(10),
    week_num       TINYINT,
    month_num      TINYINT,
    month_name     NVARCHAR(10),
    quarter_num    TINYINT,
    year_num       SMALLINT,
    is_weekend     BIT
);

GO

----==== dim_payment======

IF OBJECT_ID('analytics.dim_payment','U') IS NOT NULL
    DROP TABLE analytics.dim_payment;

GO

CREATE TABLE analytics.dim_payment (
    payment_sk              INT IDENTITY(1,1) PRIMARY KEY,
    payment_type            NVARCHAR(15),
    payment_installments    TINYINT,
    dwh_create_date         DATETIME2 DEFAULT GETDATE()
);


GO

----======fact_sales======


IF OBJECT_ID('analytics.fact_sales','U') IS NOT NULL
    DROP TABLE analytics.fact_sales;

GO

CREATE TABLE analytics.fact_sales (
    sales_sk                    BIGINT IDENTITY(1,1) PRIMARY KEY,

    -- Business keys
    order_id                    NVARCHAR(35),
    order_item_id               TINYINT,

    -- Dimension foreign keys
    customer_sk                 INT,
    product_sk                  INT,
    seller_sk                   INT,
    purchase_date_sk            INT,
    approved_date_sk            INT,
    carrier_delivery_date_sk    INT,
    customer_delivery_date_sk   INT,

    -- Measures
    price                       DECIMAL(10,2),
    freight_value               DECIMAL(10,2),
    payment_value               DECIMAL(10,2),

    -- Operational flags
    late_delivery_flg           BIT,
    delivered_missing_dt_flg    BIT,
    canceled_delivered_flg      BIT,
    approved_not_shipped_flg    BIT,
    shipped_not_delivered_flg   BIT,

    dwh_create_date             DATETIME2 DEFAULT GETDATE()
);

GO

---===== facts_reviews=========


IF OBJECT_ID('analytics.fact_reviews','U') IS NOT  NULL
    DROP TABLE analytics.fact_reviews;

GO

CREATE TABLE analytics.fact_reviews (
    review_sk                   BIGINT IDENTITY(1,1) PRIMARY KEY,

    -- Business keys
    review_id                   NVARCHAR(35),
    order_id                    NVARCHAR(35),

    -- Dimension foreign keys
    customer_sk                 INT,
    review_date_sk              INT,
    answer_date_sk              INT,

    -- Measures
    review_score                TINYINT,

    -- Flags
    review_answered_flg         TINYINT,

    dwh_create_date             DATETIME2 DEFAULT GETDATE()
);


GO

----=======fact_orders=========

IF OBJECT_ID('analytics.fact_orders','U') IS NOT NULL
    DROP TABLE analytics.fact_orders;

GO

CREATE TABLE analytics.fact_orders (
    order_sk                    BIGINT IDENTITY(1,1) PRIMARY KEY,

    order_id                    NVARCHAR(35),

    customer_sk                 INT,
    order_date_sk               INT,
    approved_date_sk            INT,
    delivered_date_sk           INT,
    order_status                NVARCHAR(15),

    total_payment_value         DECIMAL(12,2),

    late_delivery_flg           TINYINT,
    shipped_not_delivered_flg   TINYINT,
    canceled_flg                TINYINT,

    dwh_create_date             DATETIME2 DEFAULT GETDATE()
);

GO

----=======fact_order_payment=========


IF OBJECT_ID('analytics.fact_order_payment','U') IS NOT NULL
    DROP TABLE analytics.fact_order_payment;

GO

CREATE TABLE analytics.fact_order_payment (
    order_payment_sk     BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id             NVARCHAR(35),
    order_sk             BIGINT,
    payment_sk           INT,
    payment_value        DECIMAL(12,2),
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);

GO