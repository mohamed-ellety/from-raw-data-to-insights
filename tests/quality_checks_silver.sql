/*
===============================================================================
Silver Layer – Data Quality Checks
===============================================================================
Purpose:
    This script performs comprehensive data quality checks on the Silver layer
    to ensure data integrity, consistency, and readiness for analytics.

    The checks focus on:
    - Primary key integrity (NULLs & duplicates)
    - Text standardization (trimming, formatting)
    - Domain and reference validation
    - Business logic validation
    - Cross-table consistency
    - Date and numeric validation

Usage Notes:
    - Run after Silver layer load is completed.
    - All queries are expected to return ZERO rows unless otherwise noted.
    - Any returned rows indicate data quality issues that should be investigated.
===============================================================================
*/


-- ============================================================================
-- CRM SALES VISITS
-- ============================================================================
-- Primary Key Integrity
-- Expectation: no rows
SELECT
    visit_id,
    COUNT(*) AS cnt
FROM silver.crm_sales_visits
GROUP BY visit_id
HAVING visit_id IS NULL
    OR COUNT(*) > 1;


-- Text Hygiene & ID Validation 
-- Expectation: no rows
SELECT *
FROM silver.crm_sales_visits
WHERE
    rep_id NOT LIKE 'R%'  
    OR rep_name <> TRIM(rep_name)
    OR doctor_name <> TRIM(doctor_name)
    OR speciality <> TRIM(speciality)
    OR product_promoted <> TRIM(product_promoted)
    OR visit_outcome <> TRIM(visit_outcome)
    OR notes <> TRIM(notes);



-- Domain Consistency Checks
SELECT DISTINCT speciality
FROM silver.crm_sales_visits;

SELECT DISTINCT visit_outcome
FROM silver.crm_sales_visits;

-- Missing Representative Data
SELECT *
FROM silver.crm_sales_visits
WHERE rep_id IS NULL
   OR rep_name IS NULL;


-- Missing Doctor Data
SELECT *
FROM silver.crm_sales_visits
WHERE doctor_id IS NULL
   OR doctor_name IS NULL;


-- Numeric Logic Validation
-- Expectation: no rows
SELECT visit_duration_minutes
FROM silver.crm_sales_visits
WHERE
    REGEXP_REPLACE(visit_duration_minutes::text, '\s*min\s*', '', 'i')
        !~ '^[0-9]+$';


-- Date Validation
-- Expectation: no rows
SELECT *
FROM silver.crm_sales_visits
WHERE
    NOT (
        visit_date::text ~ '^[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}$'
        OR visit_date::text ~ '^[0-9]{4}[-/][0-9]{2}[-/][0-9]{2}$'
    );

SELECT *
FROM silver.crm_sales_visits
WHERE
    TO_DATE(SPLIT_PART(created_at::text, ' ', 1), 'YYYY-MM-DD') IS NULL;



-- ============================================================================
-- DOCTORS MASTER
-- ============================================================================
-- Primary Key Integrity
-- Expectation: no rows
SELECT
    doctor_id,
    COUNT(*) AS cnt
FROM silver.doctors_master
GROUP BY doctor_id
HAVING doctor_id IS NULL
    OR COUNT(*) > 1;


-- Text Hygiene
-- Expectation: no rows
SELECT *
FROM silver.doctors_master
WHERE
    doctor_name <> TRIM(doctor_name) OR
    clinic_name <> TRIM(clinic_name) OR
    specialty <> TRIM(specialty) OR
    city <> TRIM(city) OR
    region <> TRIM(region);


-- Domain Values Review
SELECT DISTINCT tier FROM silver.doctors_master;
SELECT DISTINCT active_flag FROM silver.doctors_master;


-- Date Validation
-- Expectation: no rows
SELECT *
FROM silver.doctors_master
WHERE TO_DATE(last_updated::text, 'YYYY-MM-DD') IS NULL;



-- ============================================================================
-- INVENTORY SNAPSHOT
-- ============================================================================
-- ID Validation
-- Expectation: no rows
SELECT *
FROM silver.inventory_snapshot
WHERE
    product_id NOT LIKE 'P%' OR
    warehouse_id NOT LIKE 'WH-%' OR
    batch_number NOT LIKE 'B%';


-- Numeric Logic
-- Expectation: no rows
SELECT *
FROM silver.inventory_snapshot
WHERE
    available_qty::text !~ '^[0-9]+$'
    OR reserved_qty::text !~ '^[0-9]+$';


-- Date Validation
-- Expectation: no rows
SELECT *
FROM silver.inventory_snapshot
WHERE
    TO_DATE(snapshot_date::text, 'YYYY-MM-DD') IS NULL
    OR TO_DATE(expiry_date::text, 'YYYY-MM-DD') IS NULL;



-- ============================================================================
-- MARKET DATA EXTERNAL
-- ============================================================================
-- Text Hygiene
-- Expectation: no rows
SELECT *
FROM silver.market_data_external
WHERE
    product_name <> TRIM(product_name) OR
    competitor_name <> TRIM(competitor_name) OR
    region <> TRIM(region) OR
    data_source <> TRIM(data_source);


-- Numeric Logic
-- Expectation: no rows
SELECT *
FROM silver.market_data_external
WHERE
    market_sales_value::text !~ '^[0-9]+(\.[0-9]+)?$'
    OR market_sales_units::text !~ '^[0-9]+$';



-- ============================================================================
-- PHARMACIES MASTER
-- ============================================================================
-- Primary Key Integrity
-- Expectation: no rows
SELECT
    pharmacy_id,
    COUNT(*) AS cnt
FROM silver.pharmacies_master
GROUP BY pharmacy_id
HAVING pharmacy_id IS NULL
    OR COUNT(*) > 1;


-- Text Hygiene
-- Expectation: no rows
SELECT *
FROM silver.pharmacies_master
WHERE pharmacy_name <> TRIM(pharmacy_name);


-- Domain Values Review
SELECT DISTINCT city FROM silver.pharmacies_master;
SELECT DISTINCT region FROM silver.pharmacies_master;
SELECT DISTINCT channel FROM silver.pharmacies_master;
SELECT DISTINCT active_flag FROM silver.pharmacies_master;



-- ============================================================================
-- PRODUCTS MASTER
-- ============================================================================
-- Primary Key Integrity
-- Expectation: no rows
SELECT
    product_id,
    COUNT(*) AS cnt
FROM silver.products_master
GROUP BY product_id
HAVING product_id IS NULL
    OR COUNT(*) > 1;


-- Text Hygiene
-- Expectation: no rows
SELECT *
FROM silver.products_master
WHERE
    product_name <> TRIM(product_name) OR
    brand_name <> TRIM(brand_name) OR
    molecule <> TRIM(molecule) OR
    indication <> TRIM(indication) OR
    dosage_form <> TRIM(dosage_form) OR
    strength <> TRIM(strength) OR
    status <> TRIM(status);


-- Date Validation
-- Expectation: no rows
SELECT *
FROM silver.products_master
WHERE TO_DATE(launch_date::text, 'YYYY-MM-DD') IS NULL;



-- ============================================================================
-- PROMOTIONAL SPEND
-- ============================================================================
-- Primary Key Integrity
-- Expectation: no rows
SELECT
    spend_id,
    COUNT(*) AS cnt
FROM silver.promotional_spend
GROUP BY spend_id
HAVING spend_id IS NULL
    OR COUNT(*) > 1;


-- Text Hygiene & ID Validation
-- Expectation: no rows
SELECT *
FROM silver.promotional_spend
WHERE
    product_id NOT LIKE 'P%'
    OR campaign_name <> TRIM(campaign_name);


-- Domain Review
SELECT DISTINCT channel FROM silver.promotional_spend;
SELECT DISTINCT region FROM silver.promotional_spend;


-- Date Logic
-- Expectation: no rows
SELECT *
FROM silver.promotional_spend
WHERE
    TO_DATE(start_date::text, 'YYYY-MM-DD')
        > TO_DATE(end_date::text, 'YYYY-MM-DD');



-- ============================================================================
-- SALES TRANSACTIONS
-- ============================================================================
-- Primary Key Integrity
-- Expectation: no rows
SELECT
    transaction_id,
    COUNT(*) AS cnt
FROM silver.sales_transactions
GROUP BY transaction_id
HAVING transaction_id IS NULL
    OR COUNT(*) > 1;


-- Text Hygiene & ID Validation
-- Expectation: no rows
SELECT *
FROM silver.sales_transactions
WHERE
    product_id NOT LIKE 'P%' OR
    product_name <> TRIM(product_name) OR
    pharmacy_id NOT LIKE 'PH%' OR
    pharmacy_name <> TRIM(pharmacy_name) OR
    city <> TRIM(city) OR
    distributor_id NOT LIKE 'D%';
