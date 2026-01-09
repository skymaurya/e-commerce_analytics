/*
===============================================================================
DDL Script: Create raws Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'raws' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'raws' Tables
===============================================================================
*/




------------ customer info tabble   DONE

IF OBJECT_ID('raws.customers_info', 'U') IS NOT NULL
    DROP TABLE raws.customers_info;
GO
CREATE TABLE raws.customers_info(
    cust_id                 NVARCHAR(100),
    cust_unique_id          NVARCHAR(80),
    cust_zip_code_prefix    INT,
    cust_city               NVARCHAR(50),
    cust_state              NVARCHAR(50)


);
GO


----------- customers location table


IF OBJECT_ID('raws.cust_location', 'U') IS NOT NULL
    DROP TABLE raws.cust_location;
GO

CREATE TABLE raws.cust_location(
    loc_zip_code    NVARCHAR(20),
    loc_latitude    NVARCHAR(50),
    loc_longitude   NVARCHAR(50),
    loc_city        NVARCHAR(50),
    loc_state       NVARCHAR(20)
);
GO

-------------  ORDERS_items  TABLE


IF OBJECT_ID('raws.orders_items', 'U') IS NOT NULL
    DROP TABLE raws.orders_items;
GO

CREATE TABLE raws.orders_items(
    order_id                NVARCHAR(100),
    order_item_id           INT,
    product_id              NVARCHAR(100),
    seller_id               NVARCHAR(100),
    shipping_limit_date     DATETIME2,
    price                   DECIMAL(10,2),
    freight_value           DECIMAL(10,2)

);

GO


----------- orders payment  Table

IF OBJECT_ID('raws.order_payment', 'U') IS NOT NULL
    DROP TABLE raws.order_payment;
GO

CREATE TABLE  raws.order_payment(
    order_id                NVARCHAR(100),
    payment_sequence        INT,
    payment_type            NVARCHAR(20),
    payment_installments    INT,
    payment_value           DECIMAL(10,2)

);

GO


--------- ------orders reviews  table


IF OBJECT_ID('raws.orders_reviews', 'U') IS NOT NULL
    DROP TABLE raws.orders_reviews;
GO

CREATE TABLE raws.orders_reviews(

    review_id         NVARCHAR(100),
    order_id          NVARCHAR(100),
    review_score      INT,
    review_title      NVARCHAR(255),
    review_message    NVARCHAR(MAX),
    review_creation   DATETIME2,
    review_answer     DATETIME2


);
GO


--------------  ORDERS  TABLE

IF OBJECT_ID('raws.orders', 'U') IS NOT NULL
    DROP TABLE raws.orders;
GO

CREATE TABLE raws.orders(
    order_id                        NVARCHAR(100),
    cust_id                         NVARCHAR(100),
    order_status                    NVARCHAR(15),
    ord_purchase_date               DATETIME2,
    ord_approved_date               DATETIME2,
    ord_delivered_carrier_date      DATETIME2,
    ord_delivered_customers_date    DATETIME2,
    ord_estimated_delivery_date     DATETIME2

);

GO

------------products info  table

IF OBJECT_ID('raws.products_info', 'U') IS NOT NULL
DROP TABLE raws.products_info;
GO
CREATE TABLE raws.products_info(
    prd_id                  NVARCHAR(60),
    prd_catg_name           NVARCHAR(100),
    prd_name_len            INT,
    prd_description_len     INT,
    prd_photo_qty           INT,
    prd_weight_g            FLOAT,
    prd_length_cm           FLOAT,
    prd_height_cm           FLOAT,
    prd_width_cm            FLOAT

);

GO


 -------------SELLERS INFO TABLE

IF OBJECT_ID('raws.sellers_info', 'U') IS NOT NULL
    DROP TABLE raws.sellers_info;
GO
CREATE TABLE raws.sellers_info(

    seller_id               NVARCHAR(60),
    seller_zip_code_prefix  INT,
    seller_city             NVARCHAR(50),
    seller_state            NVARCHAR(20)
);

GO



----------product catg_name_ translation


IF OBJECT_ID('raws.prd_catg_trans', 'U') IS NOT NULL
    DROP TABLE raws.prd_catg_trans;
GO

CREATE TABLE raws.prd_catg_trans(
    product_catg_name       NVARCHAR(50),
    product_Eng_name        NVARCHAR(50)

);

GO


