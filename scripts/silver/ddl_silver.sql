/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'Silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'Silver' Tables
===============================================================================
*/

DROP TABLE IF EXISTS silver.crm_sales_visits;

CREATE TABLE silver.crm_sales_visits(
	visit_id varchar(50),
	rep_id varchar(50),
	rep_name varchar(50),
	doctor_id varchar(50),
	doctor_name varchar(50),
	speciality varchar(50),
	product_promoted varchar(50),
	visit_date date,
	visit_duration_minutes integer,
	visit_outcome varchar(50),
	notes varchar(50),
	territory_code varchar(50),
	created_at date
);

DROP TABLE IF EXISTS silver.doctors_master;

CREATE TABLE silver.doctors_master (
	doctor_id varchar(50),
	doctor_name varchar(50),
	specialty varchar(50),
	clinic_name varchar(50),
	city varchar(50),
	region varchar(50),
	tier varchar(50),
	active_flag integer,
	last_updated date
);

DROP TABLE IF EXISTS silver.inventory_snapshot;

CREATE TABLE silver.inventory_snapshot (
	snapshot_date date,
	product_id varchar(50),
	warehouse_id varchar(50),
	available_qty integer,
	reserved_qty integer,
	expiry_date date,
	batch_number varchar(50)
);

DROP TABLE IF EXISTS silver.market_data_external;

CREATE TABLE silver.market_data_external (
	MONTH date,
	product_name varchar(50),
	market_sales_value decimal(12,5),
	market_sales_units integer,
	competitor_name varchar(50),
	region varchar(50),
	data_source varchar(50)
);

DROP TABLE IF EXISTS silver.pharmacies_master;

CREATE TABLE silver.pharmacies_master (
	pharmacy_id varchar(50),
	pharmacy_name varchar(50),
	city varchar(50),
	region varchar(50),
	channel varchar(50),
	active_flag integer
);

DROP TABLE IF EXISTS silver.products_master;

CREATE TABLE silver.products_master (
	product_id varchar(50),
	product_name varchar(50),
	brand_name varchar(50),
	molecule varchar(50),
	indication varchar(50),
	dosage_form varchar(50),
	strength varchar(50),
	launch_date date,
	status varchar(50)
);

DROP TABLE IF EXISTS silver.promotional_spend;

CREATE TABLE silver.promotional_spend (
	spend_id varchar(50),
	product_id varchar(50),
	campaign_name varchar(50),
	channel varchar(50),
	spend_amount decimal(12,5),
	start_date date,
	end_date date,
	region varchar(50)
);

DROP TABLE IF EXISTS silver.sales_transactions;

CREATE TABLE silver.sales_transactions (
	transaction_id varchar(50),
	product_id varchar(50),
	product_name varchar(50),
	quantity integer,
	unit_price decimal(12,5),
	total_value decimal(12,5),
	pharmacy_id varchar(50),
	pharmacy_name varchar(50),
	city varchar(50),
	transaction_date date,
	distributor_id varchar(50)
);
