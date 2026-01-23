/*
===============================================================================
Quality Checks – Gold Layer
===============================================================================
Script Purpose:
    This script performs data quality and model integrity checks on the
    Gold layer to ensure the dataset is reliable and analytics-ready.

    The checks focus on:
    - Surrogate key uniqueness in dimension-like structures.
    - Referential integrity between fact and dimension views.
    - Detection of broken joins caused by bad source data or modeling issues.

Usage Notes:
    - All queries are expected to return ZERO rows.
    - Any returned rows indicate data quality issues that must be investigated.
===============================================================================
*/

-- =============================================================================
-- Checking 'gold.fact_sales_visits' – Rep Surrogate Key
-- =============================================================================
-- Check uniqueness of rep_key generated via DENSE_RANK
-- Expectation: No duplicate rep_key values per rep_name
SELECT
    rep_key,
    COUNT(DISTINCT rep_name) AS rep_name_count
FROM gold.fact_sales_visits
GROUP BY rep_key
HAVING COUNT(DISTINCT rep_name) > 1;

-- =============================================================================
-- Checking 'gold.fact_sales_transactions' – Product Join
-- =============================================================================
-- Ensure every product_id in transactions exists in dim_products
-- Expectation: No results
SELECT
    t.transaction_id,
    t.product_id
FROM gold.fact_sales_transactions t
LEFT JOIN gold.dim_products p
    ON p.product_id = t.product_id
WHERE p.product_id IS NULL;

-- =============================================================================
-- Checking 'gold.fact_sales_transactions' – Pharmacy Join
-- =============================================================================
-- Validate pharmacy_id linkage to dim_pharmacies
-- Expectation: No results
SELECT
    t.transaction_id,
    t.pharmacy_id
FROM gold.fact_sales_transactions t
LEFT JOIN gold.dim_pharmacies ph
    ON ph.pharmacy_id = t.pharmacy_id
WHERE ph.pharmacy_id IS NULL;

-- =============================================================================
-- Data Quality Check: Sales Value Consistency
-- =============================================================================
-- Identify records where total_value does not equal quantity * unit_price
-- Expectation:
-- Results MAY exist and should be discussed with business stakeholders
SELECT
    transaction_id,
    quantity,
    unit_price,
    total_value,
    (quantity * unit_price) AS recalculated_value
FROM gold.fact_sales_transactions
WHERE total_value <> quantity * unit_price;
