/*
===============================================================================
Function: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This PL/pgSQL function performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables before inserting new data.
    - Inserts transformed and cleansed data from Bronze tables into corresponding Silver tables.
    - Normalizes nulls, string formatting, dates, and numeric types.
    - Calculates derived values where necessary (e.g., converting visit_duration to integer, standardizing product names).

Error Handling:
    - Each table load has individual error handling to ensure that a failure in one table 
      does not stop the processing of other tables.
    - Raises clear warnings if an error occurs, including the table name and the error message.

Logging / Monitoring:
    - Raises notices with execution time in seconds for each table loaded.
    - Provides clear feedback for successful table loads.

Parameters:
    None.
    This function does not accept any parameters or return any values.

Usage Example:
    SELECT silver.load_silver_layer();
===============================================================================
*/

CREATE OR REPLACE FUNCTION silver.load_silver_layer()
RETURNS void
LANGUAGE plpgsql
AS
$$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN

    -- ======================================================
    -- CRM Sales Visits
    -- ======================================================
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.crm_sales_visits;

        INSERT INTO silver.crm_sales_visits (
            visit_id, rep_id, rep_name, doctor_id, doctor_name, speciality,
            product_promoted, visit_date, visit_duration_minutes, visit_outcome,
            notes, territory_code, created_at
        )
        SELECT
            c.visit_id,
            c.rep_id,
            c.rep_name,
            CASE WHEN c.doctor_id IS NULL THEN 'n/a' ELSE c.doctor_id END,
            CASE
                WHEN c.doctor_id IS NOT NULL THEN d.doctor_name
                WHEN c.doctor_id IS NULL AND c.doctor_name IS NOT NULL THEN c.doctor_name
                ELSE 'n/a'
            END,
            CASE WHEN c.doctor_id IS NOT NULL THEN d.specialty ELSE c.speciality END,
            CASE
                WHEN c.product_promoted = 'Unknown' THEN 'n/a'
                WHEN c.product_promoted = 'Gastro Ease' THEN 'GastroEase'
                WHEN c.product_promoted = 'GastroEase' THEN 'GastroEase DSR'
                WHEN c.product_promoted = 'Cardiostat Plus' THEN 'Cardiostat'
                WHEN c.product_promoted = 'Cardiostat' THEN 'Cardiostat XR'
                ELSE c.product_promoted
            END,
            CASE
                WHEN c.visit_date ~ '^[0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{4}$' THEN
                    TO_DATE(
                        CASE
                            WHEN split_part(replace(c.visit_date,'/','-'), '-', 1)::int <= 12
                            THEN lpad(split_part(replace(c.visit_date,'/','-'), '-', 2),2,'0') || '-' ||
                                 lpad(split_part(replace(c.visit_date,'/','-'), '-', 1),2,'0') || '-' ||
                                 split_part(replace(c.visit_date,'/','-'), '-', 3)
                            ELSE lpad(split_part(replace(c.visit_date,'/','-'), '-', 1),2,'0') || '-' ||
                                 lpad(split_part(replace(c.visit_date,'/','-'), '-', 2),2,'0') || '-' ||
                                 split_part(replace(c.visit_date,'/','-'), '-', 3)
                        END, 'DD-MM-YYYY'
                    )
                WHEN c.visit_date ~ '^[0-9]{4}[-/][0-9]{1,2}[-/][0-9]{1,2}$' THEN
                    TO_DATE(
                        split_part(replace(c.visit_date,'/','-'), '-', 1) || '-' ||
                        lpad(split_part(replace(c.visit_date,'/','-'), '-', 2),2,'0') || '-' ||
                        lpad(split_part(replace(c.visit_date,'/','-'), '-', 3),2,'0'),
                        'YYYY-MM-DD'
                    )
                ELSE NULL
            END,
            CAST(REGEXP_REPLACE(c.visit_duration_minutes, '\s*min\s*', '', 'i') AS integer),
            COALESCE(c.visit_outcome, 'NA'),
            COALESCE(c.notes, 'n/a'),
            COALESCE(c.territory_code, 'n/a'),
            TO_DATE(split_part(c.created_at, ' ', 1), 'YYYY-MM-DD')
        FROM bronze.crm_sales_visits c
        LEFT JOIN bronze.doctors_master d ON c.doctor_id = d.doctor_id;

        end_time := clock_timestamp();
        RAISE NOTICE '>> Loaded silver.crm_sales_visits in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading silver.crm_sales_visits: %', SQLERRM;
    END;

    -- ======================================================
    -- Doctors Master
    -- ======================================================
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.doctors_master;

        INSERT INTO silver.doctors_master
        SELECT
            doctor_id,
            COALESCE(doctor_name, 'n/a'),
            COALESCE(specialty, 'n/a'),
            COALESCE(clinic_name, 'n/a'),
            COALESCE(city, 'n/a'),
            COALESCE(region, 'n/a'),
            tier,
            active_flag::integer,
            TO_DATE(last_updated, 'YYYY-MM-DD')
        FROM bronze.doctors_master;

        end_time := clock_timestamp();
        RAISE NOTICE '>> Loaded silver.doctors_master in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading silver.doctors_master: %', SQLERRM;
    END;

    -- ======================================================
    -- Inventory Snapshot
    -- ======================================================
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.inventory_snapshot;

        INSERT INTO silver.inventory_snapshot
        SELECT
            TO_DATE(snapshot_date, 'YYYY-MM-DD'),
            product_id,
            warehouse_id,
            available_qty::integer,
            reserved_qty::integer,
            TO_DATE(expiry_date, 'YYYY-MM-DD'),
            batch_number
        FROM bronze.inventory_snapshot;

        end_time := clock_timestamp();
        RAISE NOTICE '>> Loaded silver.inventory_snapshot in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading silver.inventory_snapshot: %', SQLERRM;
    END;

    -- ======================================================
    -- Market Data External
    -- ======================================================
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.market_data_external;

        INSERT INTO silver.market_data_external
        SELECT
            TO_DATE(month, 'YYYY-MM'),
            TRIM(product_name),
            market_sales_value::numeric,
            market_sales_units::integer,
            COALESCE(competitor_name, 'n/a'),
            COALESCE(region, 'n/a'),
            COALESCE(data_source, 'n/a')
        FROM bronze.market_data_external;

        end_time := clock_timestamp();
        RAISE NOTICE '>> Loaded silver.market_data_external in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading silver.market_data_external: %', SQLERRM;
    END;

    -- ======================================================
    -- Pharmacies Master
    -- ======================================================
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.pharmacies_master;

        INSERT INTO silver.pharmacies_master
        SELECT
            pharmacy_id,
            COALESCE(pharmacy_name, 'n/a'),
            city,
            region,
            channel,
            active_flag::integer
        FROM bronze.pharmacies_master;

        end_time := clock_timestamp();
        RAISE NOTICE '>> Loaded silver.pharmacies_master in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading silver.pharmacies_master: %', SQLERRM;
    END;

    -- ======================================================
    -- Products Master
    -- ======================================================
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.products_master;

        INSERT INTO silver.products_master
        SELECT
            product_id,
            product_name,
            brand_name,
            molecule,
            indication,
            dosage_form,
            strength,
            TO_DATE(launch_date, 'YYYY-MM-DD'),
            status
        FROM bronze.products_master;

        end_time := clock_timestamp();
        RAISE NOTICE '>> Loaded silver.products_master in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading silver.products_master: %', SQLERRM;
    END;

    -- ======================================================
    -- Promotional Spend
    -- ======================================================
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.promotional_spend;

        INSERT INTO silver.promotional_spend
        SELECT
            spend_id,
            product_id,
            COALESCE(campaign_name, 'n/a'),
            channel,
            spend_amount::numeric,
            TO_DATE(start_date, 'YYYY-MM-DD'),
            TO_DATE(end_date, 'YYYY-MM-DD'),
            region
        FROM bronze.promotional_spend;

        end_time := clock_timestamp();
        RAISE NOTICE '>> Loaded silver.promotional_spend in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading silver.promotional_spend: %', SQLERRM;
    END;

    -- ======================================================
    -- Sales Transactions
    -- ======================================================
    BEGIN
        start_time := clock_timestamp();
        TRUNCATE TABLE silver.sales_transactions;

        INSERT INTO silver.sales_transactions
        SELECT
            transaction_id,
            product_id,
            TRIM(product_name),
            quantity::integer,
            unit_price::numeric,
            total_value::numeric,
            pharmacy_id,
            COALESCE(pharmacy_name, 'n/a'),
            city,
            TO_DATE(transaction_date, 'YYYY-MM-DD'),
            distributor_id
        FROM bronze.sales_transactions;

        end_time := clock_timestamp();
        RAISE NOTICE '>> Loaded silver.sales_transactions in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error loading silver.sales_transactions: %', SQLERRM;
    END;

END;
$$;
