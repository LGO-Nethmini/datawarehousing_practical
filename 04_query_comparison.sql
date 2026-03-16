-- ============================================================
-- STEP 4: QUERY COMPARISON
-- OLTP vs DWH (Star Schema)
-- With and Without Optimization
-- ============================================================

-- ┌─────────────────────────────────────────────────────────┐
-- │ QUERY 1: Sales for a given product by location over     │
-- │          a period of time                               │
-- └─────────────────────────────────────────────────────────┘

-- ─────────────────────────────────────────────────────────────
-- 1A) OLTP — WITHOUT OPTIMIZATION (no indexes, full table scan)
-- Problem: Joins 3 tables, scans all rows, slow on large data
-- ─────────────────────────────────────────────────────────────
EXPLAIN
SELECT
    p.product_name,
    l.city,
    l.store_name,
    SUM(s.quantity_sold)   AS total_units_sold,
    SUM(s.total_amount)    AS total_revenue
FROM SALES s
JOIN PRODUCT  p ON s.product_id  = p.product_id
JOIN LOCATION l ON s.location_id = l.location_id
WHERE p.product_name = 'Laptop Pro 15'
  AND s.sale_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, l.city, l.store_name;

-- ─────────────────────────────────────────────────────────────
-- 1B) OLTP — WITH OPTIMIZATION
-- Added: Composite index + filtered subquery to reduce join size
-- ─────────────────────────────────────────────────────────────

-- Step 1: Add composite index (run once)
CREATE INDEX IF NOT EXISTS idx_sales_prod_date_loc
    ON SALES(product_id, sale_date, location_id);

-- Step 2: Optimized query using filtered subquery
EXPLAIN
SELECT
    p.product_name,
    l.city,
    l.store_name,
    SUM(s.quantity_sold)   AS total_units_sold,
    SUM(s.total_amount)    AS total_revenue
FROM (
    SELECT product_id, location_id, quantity_sold, total_amount
    FROM SALES
    WHERE sale_date BETWEEN '2025-01-01' AND '2025-12-31'
      AND product_id = (SELECT product_id FROM PRODUCT WHERE product_name = 'Laptop Pro 15' LIMIT 1)
) s
JOIN PRODUCT  p ON s.product_id  = p.product_id
JOIN LOCATION l ON s.location_id = l.location_id
GROUP BY p.product_name, l.city, l.store_name;

-- ─────────────────────────────────────────────────────────────
-- 1C) DWH STAR SCHEMA — WITHOUT INDEX (baseline star query)
-- Already faster than OLTP because:
--   ✓ Pre-computed total_amount in FACT
--   ✓ No function calls on dates (date_key integer lookup)
--   ✓ Product/Location denormalized — fewer join levels
-- ─────────────────────────────────────────────────────────────
EXPLAIN
SELECT
    dp.product_name,
    dl.city,
    dl.store_name,
    dd.month_name,
    dd.year,
    SUM(fs.quantity_sold)  AS total_units_sold,
    SUM(fs.total_amount)   AS total_revenue,
    SUM(fs.net_revenue)    AS net_revenue
FROM FACT_SALES fs
JOIN DIM_PRODUCT  dp ON fs.product_key  = dp.product_key
JOIN DIM_LOCATION dl ON fs.location_key = dl.location_key
JOIN DIM_DATE     dd ON fs.date_key     = dd.date_key
WHERE dp.product_name = 'Laptop Pro 15'
  AND dd.year = 2025
GROUP BY dp.product_name, dl.city, dl.store_name, dd.month_name, dd.year
ORDER BY dd.year, dl.city;

-- ─────────────────────────────────────────────────────────────
-- 1D) DWH STAR SCHEMA — WITH OPTIMIZATION (composite index)
-- Composite index covers all FK columns used in WHERE/JOIN
-- Result: index-only scan, no full table scan
-- ─────────────────────────────────────────────────────────────

-- Composite covering index (run once)
CREATE INDEX IF NOT EXISTS idx_fact_covering
    ON FACT_SALES(product_key, location_key, date_key, quantity_sold, total_amount, net_revenue);

EXPLAIN
SELECT
    dp.product_name,
    dl.city,
    dl.store_name,
    dd.month_name,
    dd.year,
    SUM(fs.quantity_sold)  AS total_units_sold,
    SUM(fs.total_amount)   AS total_revenue,
    SUM(fs.net_revenue)    AS net_revenue
FROM FACT_SALES fs
JOIN DIM_PRODUCT  dp ON fs.product_key  = dp.product_key
JOIN DIM_LOCATION dl ON fs.location_key = dl.location_key
JOIN DIM_DATE     dd ON fs.date_key     = dd.date_key
WHERE dp.product_key  = 1          -- use key directly (avoids string lookup)
  AND dd.year         = 2025
GROUP BY dp.product_name, dl.city, dl.store_name, dd.month_name, dd.year
ORDER BY dd.year, dl.city;


-- ┌─────────────────────────────────────────────────────────┐
-- │ QUERY 2: Maximum sales for a given product over time    │
-- │          for a given location                           │
-- └─────────────────────────────────────────────────────────┘

-- ─────────────────────────────────────────────────────────────
-- 2A) OLTP — WITHOUT OPTIMIZATION
-- ─────────────────────────────────────────────────────────────
EXPLAIN
SELECT
    p.product_name,
    l.store_name,
    l.city,
    YEAR(s.sale_date)       AS sale_year,
    MONTH(s.sale_date)      AS sale_month,
    MAX(s.quantity_sold)    AS max_units_single_sale,
    SUM(s.quantity_sold)    AS total_units_sold,
    SUM(s.total_amount)     AS total_revenue
FROM SALES s
JOIN PRODUCT  p ON s.product_id  = p.product_id
JOIN LOCATION l ON s.location_id = l.location_id
WHERE p.product_name = 'Laptop Pro 15'
  AND l.city         = 'New York'
  AND s.sale_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, l.store_name, l.city, YEAR(s.sale_date), MONTH(s.sale_date)
ORDER BY sale_year, sale_month;

-- ─────────────────────────────────────────────────────────────
-- 2B) OLTP — WITH OPTIMIZATION
-- Use indexes + avoid functions on indexed columns
-- ─────────────────────────────────────────────────────────────

-- Add index on location city for fast lookup
CREATE INDEX IF NOT EXISTS idx_location_city ON LOCATION(city);
CREATE INDEX IF NOT EXISTS idx_product_name  ON PRODUCT(product_name);

EXPLAIN
SELECT
    p.product_name,
    l.store_name,
    l.city,
    DATE_FORMAT(s.sale_date, '%Y-%m')  AS sale_month,
    MAX(s.quantity_sold)               AS max_units_single_sale,
    SUM(s.quantity_sold)               AS total_units_sold,
    SUM(s.total_amount)                AS total_revenue
FROM SALES s
INNER JOIN PRODUCT  p ON s.product_id  = p.product_id  AND p.product_name = 'Laptop Pro 15'
INNER JOIN LOCATION l ON s.location_id = l.location_id AND l.city = 'New York'
WHERE s.sale_date >= '2025-01-01'
  AND s.sale_date <  '2026-01-01'   -- range avoids YEAR() function blocking index
GROUP BY p.product_name, l.store_name, l.city, DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY sale_month;

-- ─────────────────────────────────────────────────────────────
-- 2C) DWH — WITHOUT OPTIMIZATION
-- ─────────────────────────────────────────────────────────────
EXPLAIN
SELECT
    dp.product_name,
    dl.store_name,
    dl.city,
    dd.month_name,
    dd.quarter,
    dd.year,
    MAX(fs.quantity_sold)   AS max_units_single_sale,
    SUM(fs.quantity_sold)   AS total_units_sold,
    SUM(fs.total_amount)    AS total_revenue,
    SUM(fs.net_revenue)     AS net_revenue
FROM FACT_SALES fs
JOIN DIM_PRODUCT  dp ON fs.product_key  = dp.product_key
JOIN DIM_LOCATION dl ON fs.location_key = dl.location_key
JOIN DIM_DATE     dd ON fs.date_key     = dd.date_key
WHERE dp.product_name = 'Laptop Pro 15'
  AND dl.city         = 'New York'
  AND dd.year         = 2025
GROUP BY dp.product_name, dl.store_name, dl.city, dd.month_name, dd.quarter, dd.year
ORDER BY dd.year, dd.month_number;

-- ─────────────────────────────────────────────────────────────
-- 2D) DWH — WITH FULL OPTIMIZATION (best performance)
-- Uses surrogate keys (integers) instead of string lookups
-- Integer FK joins = dramatically faster than string comparisons
-- ─────────────────────────────────────────────────────────────
EXPLAIN
SELECT
    dp.product_name,
    dl.store_name,
    dl.city,
    dd.month_name,
    dd.quarter,
    dd.year,
    MAX(fs.quantity_sold)   AS max_units_single_sale,
    SUM(fs.quantity_sold)   AS total_units_sold,
    SUM(fs.net_revenue)     AS net_revenue
FROM FACT_SALES fs
JOIN DIM_PRODUCT  dp ON fs.product_key  = dp.product_key   -- integer join
JOIN DIM_LOCATION dl ON fs.location_key = dl.location_key  -- integer join
JOIN DIM_DATE     dd ON fs.date_key     = dd.date_key       -- integer join
WHERE fs.product_key  = 1     -- direct surrogate key (no string scan)
  AND fs.location_key = 1     -- direct surrogate key
  AND dd.year         = 2025
GROUP BY dp.product_name, dl.store_name, dl.city, dd.month_name, dd.quarter, dd.year
ORDER BY dd.year, dd.month_number;


-- ┌─────────────────────────────────────────────────────────┐
-- │ QUERY 3: BONUS — Sales by Quarter & Region (DWH only)   │
-- │ This query is IMPOSSIBLE to write cleanly in OLTP       │
-- └─────────────────────────────────────────────────────────┘
SELECT
    dd.year,
    dd.quarter,
    dl.region,
    dp.category,
    COUNT(fs.sale_key)      AS number_of_transactions,
    SUM(fs.quantity_sold)   AS total_units,
    SUM(fs.total_amount)    AS gross_revenue,
    SUM(fs.discount_amount) AS total_discounts,
    SUM(fs.net_revenue)     AS net_revenue,
    AVG(fs.net_revenue)     AS avg_revenue_per_sale
FROM FACT_SALES fs
JOIN DIM_DATE     dd ON fs.date_key     = dd.date_key
JOIN DIM_LOCATION dl ON fs.location_key = dl.location_key
JOIN DIM_PRODUCT  dp ON fs.product_key  = dp.product_key
WHERE dd.year = 2025
GROUP BY dd.year, dd.quarter, dl.region, dp.category
ORDER BY dd.year, dd.quarter, dl.region;
