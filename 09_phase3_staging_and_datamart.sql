USE datawarehousing_practical;

-- ============================================================
-- PHASE 3: STAGING AREA + STAR SCHEMA + SALES DATA MART
-- ============================================================

-- -----------------------------
-- 1. STAGING TABLES
-- -----------------------------
DROP TABLE IF EXISTS stg_sales;
DROP TABLE IF EXISTS stg_customer;
DROP TABLE IF EXISTS stg_product;
DROP TABLE IF EXISTS stg_location;

CREATE TABLE stg_customer AS
SELECT * FROM customer WHERE 1 = 0;

CREATE TABLE stg_product AS
SELECT * FROM product WHERE 1 = 0;

CREATE TABLE stg_location AS
SELECT * FROM location WHERE 1 = 0;

CREATE TABLE stg_sales AS
SELECT sale_id, customer_id, product_id, location_id, sale_date, quantity_sold, unit_price, total_amount, payment_method
FROM sales WHERE 1 = 0;

-- -----------------------------
-- 2. LOAD STAGING AREA
-- -----------------------------
INSERT INTO stg_customer SELECT * FROM customer;
INSERT INTO stg_product  SELECT * FROM product;
INSERT INTO stg_location SELECT * FROM location;
INSERT INTO stg_sales    SELECT sale_id, customer_id, product_id, location_id, sale_date, quantity_sold, unit_price, total_amount, payment_method FROM sales;

-- -----------------------------
-- 3. SALES DATA MART
-- Aggregated business-friendly layer for reporting
-- -----------------------------
DROP TABLE IF EXISTS sales_datamart_monthly;

CREATE TABLE sales_datamart_monthly AS
SELECT
    dd.year,
    dd.quarter,
    dd.month_number,
    dd.month_name,
    dp.product_name,
    dp.category,
    dl.region,
    dl.city,
    COUNT(fs.sale_id) AS number_of_transactions,
    SUM(fs.quantity_sold) AS total_units_sold,
    SUM(fs.total_amount) AS gross_revenue,
    SUM(fs.discount_amount) AS total_discount,
    SUM(fs.net_revenue) AS net_revenue,
    AVG(fs.net_revenue) AS avg_revenue_per_transaction,
    MAX(fs.quantity_sold) AS max_units_single_sale
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
JOIN dim_product dp ON fs.product_key = dp.product_key
JOIN dim_location dl ON fs.location_key = dl.location_key
GROUP BY
    dd.year,
    dd.quarter,
    dd.month_number,
    dd.month_name,
    dp.product_name,
    dp.category,
    dl.region,
    dl.city;

CREATE INDEX idx_sales_mart_main
ON sales_datamart_monthly(year, month_number, product_name, city);

-- -----------------------------
-- 4. OPTIONAL SALES DATA MART VIEW
-- -----------------------------
DROP VIEW IF EXISTS vw_sales_datamart;

CREATE VIEW vw_sales_datamart AS
SELECT * FROM sales_datamart_monthly;

-- -----------------------------
-- 5. VALIDATION
-- -----------------------------
SELECT 'STAGING_COUNTS' AS section;
SELECT 'stg_customer' AS table_name, COUNT(*) AS row_count FROM stg_customer
UNION ALL
SELECT 'stg_product', COUNT(*) FROM stg_product
UNION ALL
SELECT 'stg_location', COUNT(*) FROM stg_location
UNION ALL
SELECT 'stg_sales', COUNT(*) FROM stg_sales;

SELECT 'DATAMART_COUNTS' AS section;
SELECT COUNT(*) AS monthly_datamart_rows FROM sales_datamart_monthly;
