/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Purpose:
    This script creates Gold layer views representing the final Fact and
    Dimension tables used for analytics and reporting.

    The Gold layer is opinionated, business-ready, and optimized for
    consumption (BI tools, dashboards, ad-hoc analysis).

Notes:
    - All joins and business rules are intentionally centralized here
      to avoid duplicated logic at the analytics layer.
===============================================================================
*/

-- =============================================================================
-- Fact: gold.fact_sales_visits
-- =============================================================================
-- This view represents CRM sales visits enriched with representative,
-- doctor, and product attributes.
--
-- Important:
-- The original rep_id is unreliable (many-to-many with rep_name).
-- A new surrogate key is recreated based on rep_name.
-- In real-world scenarios, this issue should be resolved upstream
-- with the source system owners or technical stakeholders.
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_sales_visits;

CREATE VIEW gold.fact_sales_visits AS
WITH dim_rep AS (
    SELECT
        rep_name,
        DENSE_RANK() OVER (ORDER BY rep_name) AS rep_key
    FROM silver.crm_sales_visits
    GROUP BY rep_name
)
SELECT
    v.visit_id,
    r.rep_key                         AS rep_key,
    v.rep_name,
    v.doctor_id,
    v.doctor_name,
    v.speciality,
    d.region,
    d.tier,
    v.product_promoted,
    p.indication,
    p.dosage_form,
    v.visit_duration_minutes,
    v.visit_outcome,
    v.notes,
    v.territory_code,
    v.visit_date,
    v.created_at
FROM silver.crm_sales_visits v
LEFT JOIN dim_rep r
    ON r.rep_name = v.rep_name
LEFT JOIN silver.doctors_master d
    ON d.doctor_id = v.doctor_id
LEFT JOIN silver.products_master p
    ON p.product_name = v.product_promoted;


-- =============================================================================
-- Fact: gold.fact_sales_transactions
-- =============================================================================
-- This view represents sales transactions enriched with product and
-- pharmacy attributes.
--
-- Data Quality Note:
-- There is an inconsistency in some records where:
--     quantity * unit_price != total_value
-- This requires alignment with the technical or business owners to
-- define the authoritative calculation.
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_sales_transactions;

CREATE VIEW gold.fact_sales_transactions AS
SELECT
    s.transaction_id,
    s.product_id,
    s.product_name,
    p.indication,
    p.dosage_form,
    s.quantity,
    s.unit_price,
    s.total_value,
    s.pharmacy_id,
    s.pharmacy_name,
    ph.channel,
    s.city,
    s.transaction_date,
    s.distributor_id
FROM silver.sales_transactions s
LEFT JOIN silver.products_master p
    ON p.product_id = s.product_id
LEFT JOIN silver.pharmacies_master ph
    ON ph.pharmacy_id = s.pharmacy_id;


-- =============================================================================
-- Fact: gold.fact_promotional_spend
-- =============================================================================
-- Direct pass-through view.
-- Business logic and aggregations are expected to be applied at the
-- analytics layer.
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_promotional_spend;

CREATE VIEW gold.fact_promotional_spend AS
SELECT
    *
FROM silver.promotional_spend;


-- =============================================================================
-- Fact: gold.fact_inventory_snapshot
-- =============================================================================
-- Snapshot-style fact table representing inventory levels at a point in time.
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_inventory_snapshot;

CREATE VIEW gold.fact_inventory_snapshot AS
SELECT
    *
FROM silver.inventory_snapshot;


-- =============================================================================
-- Dimension: gold.market_context
-- =============================================================================
-- External market data used for contextual analysis (macro factors,
-- competition, seasonality, etc.).
-- =============================================================================

DROP VIEW IF EXISTS gold.market_context;

CREATE VIEW gold.market_context AS
SELECT
    *
FROM silver.market_data_external;


-- =============================================================================
-- Dimension: gold.dim_doctors
-- =============================================================================
-- Canonical doctor dimension.
-- Acts as the source of truth for doctor attributes.
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_doctors;

CREATE VIEW gold.dim_doctors AS
SELECT
    *
FROM silver.doctors_master;



-- =============================================================================
-- Dimension: gold.dim_products
-- =============================================================================
-- Canonical product dimension.
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_products;

CREATE VIEW gold.dim_products AS
SELECT
    *
FROM silver.products_master;


-- =============================================================================
-- Dimension: gold.dim_pharmacies
-- =============================================================================
-- Canonical pharmacy dimension.
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_pharmacies;

CREATE VIEW gold.dim_pharmacies AS
SELECT
    *
FROM silver.pharmacies_master;
