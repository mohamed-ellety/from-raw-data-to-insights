/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

DROP TABLE IF EXISTS bronze.crm_sales_visits;

CREATE TABLE bronze.crm_sales_visits(
	visit_id varchar(50),
	rep_id varchar(50),
	rep_name varchar(50),
	doctor_id varchar(50),
	doctor_name varchar(50),
	speciality varchar(50),
	product_promoted varchar(50),
	visit_date date,
	visit_duration_minutes varchar(50),
	visit_outcome varchar(50),
	notes varchar(50),
	territory_code varchar(50),
	created_at timestamp
);

DROP TABLE IF EXISTS bronze.doctors_master;

CREATE TABLE bronze.doctors_master (
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

DROP TABLE IF EXISTS bronze.inventory_snapshot;

CREATE TABLE bronze.inventory_snapshot (
	snapshot_date date,
	product_id varchar(50),
	warehouse_id varchar(50),
	available_qty integer,
	reserved_qty integer,
	expiry_date date,
	batch_number varchar(50)
);

DROP TABLE IF EXISTS bronze.market_data_external;

CREATE TABLE bronze.market_data_external (
	MONTH date,
	product_name varchar(50),
	market_sales_value integer,
	market_sales_units integer,
	competitor_name varchar(50),
	region varchar(50),
	data_source varchar(50)
);

DROP TABLE IF EXISTS bronze.pharmacies_master;

CREATE TABLE bronze.pharmacies_master (
	pharmacy_id varchar(50),
	pharmacy_name varchar(50),
	city varchar(50),
	region varchar(50),
	channel varchar(50),
	active_flag integer
);

DROP TABLE IF EXISTS bronze.products_master;

CREATE TABLE bronze.products_master (
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

DROP TABLE IF EXISTS bronze.promotional_spend;

CREATE TABLE bronze.promotional_spend (
	spend_id varchar(50),
	product_id varchar(50),
	campaign_name varchar(50),
	channel varchar(50),
	spend_amount integer,
	start_date date,
	end_date date,
	region varchar(50)
);

DROP TABLE IF EXISTS bronze.sales_transactions;

CREATE TABLE bronze.sales_transactions (
	transaction_id varchar(50),
	product_id varchar(50),
	product_name varchar(100),
	quantity integer,
	unit_price integer,
	total_value integer,
	pharmacy_id varchar(50),
	pharmacy_name varchar(50),
	city varchar(50),
	transaction_date date,
	distributor_id varchar(50)
);
