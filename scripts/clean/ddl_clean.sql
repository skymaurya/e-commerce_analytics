/*
===============================================================================
DDL Script: Create clean Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'clean' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'clean' Tables
===============================================================================
*/

------------ customer info table 

IF OBJECT_ID('clean.cust_info', 'U') IS NOT NULL
    DROP TABLE clean.cust_info;
GO
CREATE TABLE clean.cust_info(
    cust_id                 NVARCHAR(35),
    cust_unique_id          NVARCHAR(35),
    cust_zip_code_prefix    NVARCHAR(8),
    cust_city               NVARCHAR(45),
    cust_state              CHAR(3),
    dwh_create_date         DATETIME2 DEFAULT GETDATE()

    CONSTRAINT pk_cust_info PRIMARY KEY (cust_id)
);

GO

----Customers location table

IF OBJECT_ID('clean.cust_location', 'U') IS  NOT  NULL
    DROP TABLE clean.cust_location;
GO

CREATE TABLE clean.cust_location(
    loc_zip_code        NVARCHAR(8),
    loc_latitude        DECIMAL(8,6),
    loc_longitude       DECIMAL(9,6),
    loc_city            NVARCHAR(45),
    loc_state           CHAR(3),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()

    
);

GO

        -----orders_items table

IF OBJECT_ID('clean.orders_items', 'U') IS NOT NULL
    DROP TABLE clean.orders_items;

GO

CREATE TABLE clean.orders_items(
    order_id                NVARCHAR(35),
    order_item_id           TINYINT,
    product_id              NVARCHAR(35),
    seller_id               NVARCHAR(35),
    shipping_limit_date     DATETIME2,
    price                   DECIMAL(10,2),
    freight_value           DECIMAL(10,2),
    dwh_create_date         DATETIME2 DEFAULT GETDATE()

    CONSTRAINT pk_ord_item PRIMARY KEY (order_id,order_item_id)
);

GO


----------- orders payment  Table

IF OBJECT_ID('clean.orders_payment', 'U') IS NOT NULL
    DROP TABLE clean.orders_payment;
GO

CREATE TABLE  clean.orders_payment(
    order_id                NVARCHAR(35),
    payment_sequence        TINYINT,
    payment_type            NVARCHAR(15),
    payment_installments    TINYINT,
    payment_value           DECIMAL(10,2),
    dwh_create_date         DATETIME2 DEFAULT GETDATE()

    CONSTRAINT pk_ord_payment PRIMARY KEY (order_id,payment_sequence)
);

GO

--------- ------orders reviews  table


IF OBJECT_ID('clean.orders_reviews', 'U') IS  not NULL
    DROP TABLE clean.orders_reviews;

GO

CREATE TABLE clean.orders_reviews(

    review_id         NVARCHAR(35),
    order_id          NVARCHAR(35),
    review_score      TINYINT,
    review_title      NVARCHAR(50),
    review_message    NVARCHAR(500),
    review_creation_dt   DATETIME2,
    review_answer_dt    DATETIME2,

    dwh_create_date   DATETIME2 DEFAULT GETDATE()

    CONSTRAINT pk_ord_review PRIMARY KEY (order_id,review_id)

);
GO

--------------  ORDERS  TABLE

IF OBJECT_ID('clean.orders', 'U') IS   NOT NULL
    DROP TABLE clean.orders;

GO

CREATE TABLE clean.orders(
    order_id                        NVARCHAR(35),
    cust_id                         NVARCHAR(35),
    order_status                    NVARCHAR(15),
    ord_purchase_date               DATETIME2,
    ord_approved_date               DATETIME2,
    ord_delivered_carrier_date      DATETIME2,
    ord_delivered_customers_date    DATETIME2,
    ord_estimated_delivery_date     DATETIME2,
    late_delivery_flg               TINYINT,
    delivered_missing_dt_flg        TINYINT,
    canceled_delivered_flg          TINYINT,
    approved_not_shipped_flg        TINYINT,
    shipped_not_delivered_flg       TINYINT,
    dwh_create_date                 DATETIME2 DEFAULT GETDATE()

    CONSTRAINT pk_ord PRIMARY KEY (order_id)

);

GO

----------product info table

IF OBJECT_ID('clean.products_info', 'U') IS NOT NULL
DROP TABLE clean.products_info;

GO
CREATE TABLE clean.products_info(
    prd_id                  NVARCHAR(35),
    prd_catg_name           NVARCHAR(80),
    prd_name_len            TINYINT,
    prd_description_len     SMALLINT,
    prd_photo_qty           TINYINT,
    prd_weight_g            DECIMAL(10,3),
    prd_length_cm           DECIMAL(10,2),
    prd_height_cm           DECIMAL(10,2),
    prd_width_cm            DECIMAL(10,2),
    dwh_create_date         DATETIME2 DEFAULT GETDATE()

    CONSTRAINT pk_prd_info PRIMARY KEY (prd_id)
);

GO

----------product catg_name_ translation


IF OBJECT_ID('clean.products_catg_trans', 'U') IS NOT NULL
    DROP TABLE clean.products_catg_trans;

GO

CREATE TABLE clean.products_catg_trans(
    product_catg_name       NVARCHAR(60),
    product_Eng_name        NVARCHAR(50),
    dwh_create_date         DATETIME2 DEFAULT GETDATE()

    CONSTRAINT pk_prd_catg PRIMARY KEY (product_catg_name)
);

GO

 -------------SELLERS INFO TABLE

IF OBJECT_ID('clean.sellers_info', 'U') IS NOT NULL
    DROP TABLE clean.sellers_info;

GO

CREATE TABLE clean.sellers_info(

    seller_id               NVARCHAR(35),
    seller_zip_code_prefix  NVARCHAR(8),
    seller_city             NVARCHAR(45),
    seller_state            CHAR(3),
    dwh_create_date         DATETIME2 DEFAULT GETDATE()

    CONSTRAINT pk_seller_info  PRIMARY KEY (seller_id)
);

GO
