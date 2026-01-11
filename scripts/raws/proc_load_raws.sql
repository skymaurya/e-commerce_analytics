---MAKING THE STORE PROCEDURE FOR THE 'raws' LAYER
/*
===============================================================================
Stored Procedure: Load raws Layer (Source -> raws)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'raws' schema from external CSV files. 
    It performs the following actions:
    - Truncates the raws tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to raws tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC raws.load_raws;

WARNING: Comment the orders_reviews table load method before running this procedure beacuse it was loaded by using  
          IMPORT  method  on csv file, as data was  to much messsy to use bulk insert method.
==============================================================================================================
*/

CREATE OR ALTER PROCEDURE raws.load_raws AS 

BEGIN
     DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading raws Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading customer_info Table';
		PRINT '------------------------------------------------';


        SET @start_time=GETDATE();

        TRUNCATE TABLE raws.customers_info;

        BULK INSERT raws.customers_info
        FROM 'D:\SQL Project\E-Commerce\datasets\olist_customers_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',   
            DATAFILETYPE = 'char',   
            CODEPAGE = '65001',
            MAXERRORS = 100
            );

        SET @end_time=GETDATE();

        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'


        PRINT '------------------------------------------------';
		PRINT 'Loading cust_location Table';
		PRINT '------------------------------------------------';

        SET @start_time=GETDATE();

        TRUNCATE TABLE raws.cust_location;

        BULK INSERT raws.cust_location
        FROM 'D:\SQL Project\E-Commerce\datasets\olist_geolocation_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',  
            DATAFILETYPE = 'char',    
            MAXERRORS = 100
                );
         SET @end_time=GETDATE();

        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'


        PRINT '------------------------------------------------';
		PRINT 'Loading orders_reviews Table';
		PRINT '------------------------------------------------';

        ----------orders reviews

        SET @start_time=GETDATE();

        ---using IMPORT  method for orders_reviews as file was to much messsy to use bulk method

        TRUNCATE TABLE raws.order_reviews;

        BULK INSERT raws.order_reviews
        FROM 'D:\SQL Project\E-Commerce\datasets\olist_order_reviews_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',   
            DATAFILETYPE = 'char',    
            CODEPAGE = '65001',
            MAXERRORS = 100
            );
            
        SET @end_time=GETDATE();

        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'
      

        PRINT '------------------------------------------------';
		PRINT 'Loading orders_reviews Table';
		PRINT '------------------------------------------------';


        SET @start_time=GETDATE();

        TRUNCATE TABLE raws.order_payment;

        BULK INSERT raws.order_payment
        FROM 'D:\SQL Project\E-Commerce\datasets\olist_order_payments_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',   
            DATAFILETYPE = 'char',   
            CODEPAGE = '65001',
            MAXERRORS = 100
            );
         SET @end_time=GETDATE();

        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'


        PRINT '------------------------------------------------';
        PRINT 'Loading orders  Table';
        PRINT '------------------------------------------------';

        SET @start_time=GETDATE();

        TRUNCATE TABLE raws.orders;

        BULK INSERT raws.orders
        FROM 'D:\SQL Project\E-Commerce\datasets\olist_orders_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',  
            DATAFILETYPE = 'char',   
            CODEPAGE = '65001',
            MAXERRORS = 100
                );
        SET @end_time=GETDATE();

        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'


        PRINT '------------------------------------------------';
        PRINT 'Loading orders_items Table';
        PRINT '------------------------------------------------';

        SET @start_time=GETDATE();

        TRUNCATE TABLE raws.orders_items;

        BULK INSERT raws.orders_items
        FROM 'D:\SQL Project\E-Commerce\datasets\olist_order_items_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',  
            DATAFILETYPE = 'char',    
            CODEPAGE = '65001',
            MAXERRORS = 100
            );

        SET @end_time=GETDATE();

        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'


        PRINT '------------------------------------------------';
        PRINT 'Loading prd_catg_trans Table';
        PRINT '------------------------------------------------';
    
        SET @start_time=GETDATE();
        TRUNCATE TABLE raws.prd_catg_trans;

        BULK INSERT raws.prd_catg_trans
        FROM 'D:\SQL Project\E-Commerce\datasets\product_category_name_translation.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',  
            DATAFILETYPE = 'char',    
            CODEPAGE = '65001',
            MAXERRORS = 100
            );

         SET @end_time=GETDATE();

        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'


        PRINT '------------------------------------------------';
        PRINT 'Loading product_info Table';
        PRINT '------------------------------------------------';
       

        SET @start_time=GETDATE();

        TRUNCATE TABLE raws.products_info;

        BULK INSERT raws.products_info
        FROM 'D:\SQL Project\E-Commerce\datasets\olist_products_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',   
            DATAFILETYPE = 'char',    
            CODEPAGE = '65001',
            MAXERRORS = 100
            );
        SET @end_time=GETDATE();

        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'



        PRINT '------------------------------------------------';
        PRINT 'Loading sellers_info Table';
        PRINT '------------------------------------------------';
   

        SET @start_time=GETDATE();

        TRUNCATE TABLE raws.sellers_info;

        BULK INSERT raws.sellers_info
        FROM 'D:\SQL Project\E-Commerce\datasets\olist_sellers_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',
            FIRSTROW = 2,
            ROWTERMINATOR = '0x0A',   
            DATAFILETYPE = 'char',    
            CODEPAGE = '65001',
            MAXERRORS = 100
            );

        SET @end_time=GETDATE();
        PRINT'LOAD TIME -->> :' + CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------->'

        
		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading raws Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='

            END TRY
    BEGIN CATCH
        PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING raws LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='

    END CATCH

END


