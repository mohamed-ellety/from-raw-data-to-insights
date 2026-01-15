/*
=============================================================
Create Database and Schemas
=============================================================
Purpose:
    - Drop database if exists
    - Create "pharma" database
    - Create bronze, silver, gold schemas
WARNING:
    This will permanently delete the database.
*/

-- Drop database if exists
DROP DATABASE IF EXISTS "pharma";

-- Create database
CREATE DATABASE "pharma";

-- Create schemas after switching to the new database
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
