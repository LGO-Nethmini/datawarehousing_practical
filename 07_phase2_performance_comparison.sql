USE datawarehousing_practical;

-- ============================================================
-- PHASE 2: FACT & DIMENSION INTRODUCTION + PERFORMANCE COMPARISON
-- Goal:
--   Compare the same analytical requirement in:
--   1) OLTP schema (without dimension/fact tables)
--   2) Star schema (with dimension/fact tables)
-- ============================================================

-- ============================================================
-- PART A: QUERY 1
-- Sales for a given product by location over a period of time
-- ============================================================

-- -----------------------------
-- A1. OLTP VERSION (Phase 1)
-- -----------------------------
EXPLAIN
SELECT
    p.product_name,
    l.city,
    s.sale_date,
    SUM(s.quantity_sold) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN location l ON s.location_id = l.location_id
WHERE p.product_name = 'Laptop Pro 15'
  AND s.sale_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, l.city, s.sale_date
ORDER BY s.sale_date;

SELECT
    p.product_name,
    l.city,
    s.sale_date,
    SUM(s.quantity_sold) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN location l ON s.location_id = l.location_id
WHERE p.product_name = 'Laptop Pro 15'
  AND s.sale_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, l.city, s.sale_date
ORDER BY s.sale_date;

-- -----------------------------
-- A2. STAR SCHEMA VERSION (Phase 2)
-- -----------------------------
EXPLAIN
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
GROUP BY dp.product_name, dl.city, dd.month_name, dd.year
ORDER BY dd.year, dd.month_number;

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
GROUP BY dp.product_name, dl.city, dd.month_name, dd.year
ORDER BY dd.year, dd.month_number;

-- ============================================================
-- PART B: QUERY 2
-- Maximum sales for a given product over time for a given location
-- ============================================================

-- -----------------------------
-- B1. OLTP VERSION (Phase 1)
-- -----------------------------
EXPLAIN
SELECT
    p.product_name,
    l.city,
    YEAR(s.sale_date) AS sale_year,
    MONTH(s.sale_date) AS sale_month,
    MAX(s.quantity_sold) AS max_units_single_sale,
    SUM(s.quantity_sold) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN location l ON s.location_id = l.location_id
WHERE p.product_name = 'Laptop Pro 15'
  AND l.city = 'New York'
  AND s.sale_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, l.city, YEAR(s.sale_date), MONTH(s.sale_date)
ORDER BY sale_year, sale_month;

SELECT
    p.product_name,
    l.city,
    YEAR(s.sale_date) AS sale_year,
    MONTH(s.sale_date) AS sale_month,
    MAX(s.quantity_sold) AS max_units_single_sale,
    SUM(s.quantity_sold) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN location l ON s.location_id = l.location_id
WHERE p.product_name = 'Laptop Pro 15'
  AND l.city = 'New York'
  AND s.sale_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, l.city, YEAR(s.sale_date), MONTH(s.sale_date)
ORDER BY sale_year, sale_month;

-- -----------------------------
-- B2. STAR SCHEMA VERSION (Phase 2)
-- -----------------------------
EXPLAIN
SELECT
    dp.product_name,
    dl.city,
    dd.month_name,
    dd.year,
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
GROUP BY dp.product_name, dl.city, dd.month_name, dd.year
ORDER BY dd.year, dd.month_number;

SELECT
    dp.product_name,
    dl.city,
    dd.month_name,
    dd.year,
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
GROUP BY dp.product_name, dl.city, dd.month_name, dd.year
ORDER BY dd.year, dd.month_number;

-- ============================================================
-- PART C: COMPARISON NOTES
-- Use EXPLAIN output to compare:
-- 1. rows scanned
-- 2. index usage
-- 3. temporary/filesort usage
-- 4. join complexity
-- ============================================================

-- Expected conclusion:
-- OLTP:
--   - More dependence on transactional tables
--   - More runtime date processing
--   - Less readable analytical queries
--   - Higher query cost for reporting workloads
--
-- Star Schema:
--   - Uses DIM_DATE, DIM_PRODUCT, DIM_LOCATION
--   - Fact table stores measures centrally
--   - Simpler GROUP BY for analytics
--   - Better performance and easier reporting
