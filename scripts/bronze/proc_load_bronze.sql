/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `copy` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	This stored function does not accept any parameters or return any values.

Usage Example:
    select bronze.load_bronze();
===============================================================================
*/

CREATE OR REPLACE FUNCTION bronze.load_bronze()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    batch_start_time TIMESTAMP;
    batch_end_time   TIMESTAMP;
    start_time       TIMESTAMP;
    end_time         TIMESTAMP;
	rows_loaded		 BIGINT;
BEGIN 
	batch_start_time := clock_timestamp();

	RAISE NOTICE '==========================================';
	RAISE NOTICE 'loading bronze layer';
	RAISE NOTICE '==========================================';
--========================================================================================
--========================================================================================

-- ============================
-- LOAD: crm_sales_visits
-- ============================
	start_time := clock_timestamp();
	RAISE NOTICE '>> truncating table: bronze.crm_sales_visits';
	TRUNCATE TABLE bronze.crm_sales_visits;
	
	RAISE NOTICE '>> inserting data into: bronze.crm_sales_visits';
	COPY bronze.crm_sales_visits
	FROM 'D:/pharma_project/crm_sales_visits.csv'
	WITH (format CSV, HEADER TRUE);
	
	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    RAISE NOTICE 'rows loaded: %', rows_loaded;
	end_time := clock_timestamp();
    RAISE NOTICE 'crm_sales_visits load duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

-- ============================
-- LOAD: doctors_master
-- ============================
	start_time := clock_timestamp();
	RAISE NOTICE '>> truncating table: bronze.doctors_master';
	TRUNCATE TABLE bronze.doctors_master;
	
	RAISE NOTICE '>> inserting data into: bronze.doctors_master';
	COPY bronze.doctors_master
	FROM 'D:/pharma_project/doctors_master.csv'
	WITH (format CSV, HEADER TRUE);

	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    RAISE NOTICE 'rows loaded: %', rows_loaded;
	end_time := clock_timestamp();
    RAISE NOTICE 'doctors_master load duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
	
-- ============================
-- LOAD: inventory_snapshot
-- ============================
	start_time := clock_timestamp();
	RAISE NOTICE '>> truncating table: bronze.inventory_snapshot';
	TRUNCATE TABLE bronze.inventory_snapshot;
	
	RAISE NOTICE '>> inserting data into: bronze.inventory_snapshot';
	COPY bronze.inventory_snapshot
	FROM 'D:/pharma_project/inventory_snapshot.csv'
	WITH (format CSV, HEADER TRUE);

	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    RAISE NOTICE 'rows loaded: %', rows_loaded;
	end_time := clock_timestamp();
    RAISE NOTICE 'inventory_snapshot load duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
	
-- ============================
-- LOAD: market_data_external
-- ============================
	start_time := clock_timestamp();
	RAISE NOTICE '>> truncating table: bronze.market_data_external';
	TRUNCATE TABLE bronze.market_data_external;
	
	RAISE NOTICE '>> inserting data into: bronze.market_data_external';
	COPY bronze.market_data_external
	FROM 'D:/pharma_project/market_data_external.csv'
	WITH (format CSV, HEADER TRUE);

	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    RAISE NOTICE 'rows loaded: %', rows_loaded;
	end_time := clock_timestamp();
    RAISE NOTICE 'market_data_external load duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
	
-- ============================
-- LOAD: phrmacies_master
-- ============================
	start_time := clock_timestamp();
	RAISE NOTICE '>> truncating table: bronze.pharmacies_master';
	TRUNCATE TABLE bronze.pharmacies_master;
	
	RAISE NOTICE '>> inserting data into: bronze.pharmacies_master';
	COPY bronze.pharmacies_master
	FROM 'D:/pharma_project/pharmacies_master.csv'
	WITH (format CSV, HEADER TRUE);

	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    RAISE NOTICE 'rows loaded: %', rows_loaded;
	end_time := clock_timestamp();
    RAISE NOTICE 'pharmacies_master load duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

-- ============================
-- LOAD: products_master
-- ============================	
	start_time := clock_timestamp();
	RAISE NOTICE '>> truncating table: bronze.products_master';
	TRUNCATE TABLE bronze.products_master;
	
	RAISE NOTICE '>> inserting data into: bronze.products_master';
	COPY bronze.products_master
	FROM 'D:/pharma_project/products_master.csv'
	WITH (format CSV, HEADER TRUE);

	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    RAISE NOTICE 'rows loaded: %', rows_loaded;
	end_time := clock_timestamp();
    RAISE NOTICE 'products_master load duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
	
-- ============================
-- LOAD: promotional_spend
-- ============================
	start_time := clock_timestamp();
	RAISE NOTICE '>> truncating table: bronze.promotional_spend';
	TRUNCATE TABLE bronze.promotional_spend;
	
	RAISE NOTICE '>> inserting data into: bronze.promotional_spend';
	COPY bronze.promotional_spend
	FROM 'D:/pharma_project/promotional_spend.csv'
	WITH (format CSV, HEADER TRUE);

	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    RAISE NOTICE 'rows loaded: %', rows_loaded;
	end_time := clock_timestamp();
    RAISE NOTICE 'promotional_spend load duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

-- ============================
-- LOAD: sales_transactions
-- ============================
	start_time := clock_timestamp();
	RAISE NOTICE '>> truncating table: bronze.sales_transactions';
	TRUNCATE TABLE bronze.sales_transactions;
	
	RAISE NOTICE '>> inserting data into: bronze.sales_transactions';
	COPY bronze.sales_transactions
	FROM 'D:/pharma_project/sales_transactions.csv'
	WITH (format CSV, HEADER TRUE);

	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    RAISE NOTICE 'rows loaded: %', rows_loaded;
	end_time := clock_timestamp();
    RAISE NOTICE 'sales_transactions load duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

--================================================================================
--================================================================================

	batch_end_time := clock_timestamp();

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer Completed';
    RAISE NOTICE 'Total duration: % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
    RAISE NOTICE '==========================================';


EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error during bronze load: %', SQLERRM;
END;
$$;
