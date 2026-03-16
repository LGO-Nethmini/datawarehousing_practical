USE datawarehousing_practical;

-- ============================================================
-- PHASE 3 DEMO QUERIES
-- Run after 09_phase3_staging_and_datamart.sql
-- ============================================================

SELECT 'PHASE 3 - STAGING SUMMARY' AS section;
SELECT 'stg_customer' AS table_name, COUNT(*) AS row_count FROM stg_customer
UNION ALL
SELECT 'stg_product', COUNT(*) FROM stg_product
UNION ALL
SELECT 'stg_location', COUNT(*) FROM stg_location
UNION ALL
SELECT 'stg_sales', COUNT(*) FROM stg_sales;

SELECT 'PHASE 3 - DATAMART SUMMARY' AS section;
SELECT COUNT(*) AS rows_in_sales_datamart FROM sales_datamart_monthly;

SELECT 'QUERY 1 - SALES BY PRODUCT, LOCATION, MONTH' AS section;
SELECT
    year,
    month_name,
    product_name,
    city,
    total_units_sold,
    net_revenue
FROM sales_datamart_monthly
WHERE product_name = 'Laptop Pro 15'
ORDER BY year, month_number, city;

SELECT 'QUERY 2 - MAX SALES FOR PRODUCT IN GIVEN LOCATION' AS section;
SELECT
    year,
    month_name,
    product_name,
    city,
    max_units_single_sale,
    total_units_sold,
    net_revenue
FROM sales_datamart_monthly
WHERE product_name = 'Laptop Pro 15'
  AND city = 'New York'
ORDER BY year, month_number;

SELECT 'QUERY 3 - REVENUE BY REGION AND CATEGORY' AS section;
SELECT
    year,
    quarter,
    region,
    category,
    SUM(net_revenue) AS total_net_revenue,
    SUM(total_units_sold) AS total_units
FROM sales_datamart_monthly
GROUP BY year, quarter, region, category
ORDER BY year, quarter, region, category;
