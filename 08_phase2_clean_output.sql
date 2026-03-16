USE datawarehousing_practical;

-- ============================================================
-- CLEAN PHASE 2 OUTPUT
-- Run this file to get simple, easy-to-read results
-- ============================================================

SELECT 'PHASE 2 - DATA SUMMARY' AS section;

SELECT 'CUSTOMER' AS table_name, COUNT(*) AS row_count FROM customer
UNION ALL
SELECT 'PRODUCT', COUNT(*) FROM product
UNION ALL
SELECT 'LOCATION', COUNT(*) FROM location
UNION ALL
SELECT 'SALES', COUNT(*) FROM sales
UNION ALL
SELECT 'DIM_DATE', COUNT(*) FROM dim_date
UNION ALL
SELECT 'DIM_CUSTOMER', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'DIM_PRODUCT', COUNT(*) FROM dim_product
UNION ALL
SELECT 'DIM_LOCATION', COUNT(*) FROM dim_location
UNION ALL
SELECT 'FACT_SALES', COUNT(*) FROM fact_sales;

-- ============================================================
-- QUERY 1 RESULTS
-- Sales for a given product by location over a period of time
-- ============================================================

SELECT 'QUERY 1 - OLTP RESULT' AS section;

SELECT
    p.product_name,
    l.city,
    DATE_FORMAT(s.sale_date, '%Y-%m-%d') AS period,
    SUM(s.quantity_sold) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN location l ON s.location_id = l.location_id
WHERE p.product_name = 'Laptop Pro 15'
  AND s.sale_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, l.city, s.sale_date
ORDER BY s.sale_date;

SELECT 'QUERY 1 - STAR SCHEMA RESULT' AS section;

SELECT
    dp.product_name,
    dl.city,
    dd.month_name,
    dd.year,
    SUM(fs.quantity_sold) AS total_units_sold,
    SUM(fs.net_revenue) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_key = dp.product_key
JOIN dim_location dl ON fs.location_key = dl.location_key
JOIN dim_date dd ON fs.date_key = dd.date_key
WHERE dp.product_name = 'Laptop Pro 15'
  AND dd.year = 2025
GROUP BY dp.product_name, dl.city, dd.month_name, dd.year, dd.month_number
ORDER BY dd.month_number, dl.city;

-- ============================================================
-- QUERY 2 RESULTS
-- Maximum number of sales for a given product over time for a given location
-- ============================================================

SELECT 'QUERY 2 - OLTP RESULT' AS section;

SELECT
    p.product_name,
    l.city,
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sale_month,
    MAX(s.quantity_sold) AS max_units_single_sale,
    SUM(s.quantity_sold) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN location l ON s.location_id = l.location_id
WHERE p.product_name = 'Laptop Pro 15'
  AND l.city = 'New York'
  AND s.sale_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, l.city, DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY sale_month;

SELECT 'QUERY 2 - STAR SCHEMA RESULT' AS section;

SELECT
    dp.product_name,
    dl.city,
    CONCAT(dd.year, '-', LPAD(dd.month_number, 2, '0')) AS sale_month,
    MAX(fs.quantity_sold) AS max_units_single_sale,
    SUM(fs.quantity_sold) AS total_units_sold,
    SUM(fs.net_revenue) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_key = dp.product_key
JOIN dim_location dl ON fs.location_key = dl.location_key
JOIN dim_date dd ON fs.date_key = dd.date_key
WHERE dp.product_name = 'Laptop Pro 15'
  AND dl.city = 'New York'
  AND dd.year = 2025
GROUP BY dp.product_name, dl.city, dd.year, dd.month_number
ORDER BY dd.year, dd.month_number;

-- ============================================================
-- SIMPLE PERFORMANCE NOTE
-- ============================================================

SELECT 'PERFORMANCE NOTE' AS section;
SELECT 'OLTP queries are transaction-oriented and analytical queries are more complex.' AS note
UNION ALL
SELECT 'Star schema queries are easier to write and better for reporting.'
UNION ALL
SELECT 'Use EXPLAIN from 07_phase2_performance_comparison.sql for execution plan comparison.';
