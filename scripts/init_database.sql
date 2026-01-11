/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'ecommerce_analytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'raws', 'clean', and 'analytics'.
	
WARNING:
    Running this script will drop the entire 'ecommerce_analytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/


USE master;

GO

-- Drop and recreate the 'ecommerce_analytics' database

IF EXISTS (SELECT 1 FROM sys.databases WHERE name ='ecommerce_analytics')
BEGIN
    ALTER DATABASE ecommerce_analytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ecommerce_analytics;
END;
GO


--- Create the 'ecommerce_analytics' database
CREATE DATABASE ecommerce_analytics;

GO

--- Create Schemas

CREATE SCHEMA raws;
GO

CREATE SCHEMA clean;
GO

CREATE SCHEMA analytics;
GO
