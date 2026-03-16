-- ============================================================
-- PERFORMANCE COMPARISON SUMMARY
-- OLTP vs DWH | With vs Without Optimization
-- ============================================================

/*
╔══════════════════════════════════════════════════════════════════════════════╗
║              DIMENSION vs FACT TABLE — ROLE COMPARISON                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  DIMENSION TABLE              │  FACT TABLE                                 ║
║ ─────────────────────────     │  ──────────────────────────                 ║
║  Descriptive attributes       │  Measurable numeric values                  ║
║  WHO / WHAT / WHERE / WHEN    │  HOW MUCH / HOW MANY                        ║
║  Slow-changing data           │  Append-only (grows fast)                   ║
║  Smaller in size              │  Very large (millions of rows)              ║
║  Example: DIM_PRODUCT         │  Example: FACT_SALES                        ║
║    - product_name (text)      │    - quantity_sold (int)                    ║
║    - category (text)          │    - total_amount (decimal)                 ║
║    - brand (text)             │    - net_revenue (decimal)                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════════════════════════════╗
║           QUERY PERFORMANCE COMPARISON TABLE                                ║
╠════════════════╦══════════════╦══════════════╦════════════════════════════  ║
║ Scenario       ║ Schema       ║ Index Used   ║ Performance                  ║
╠════════════════╬══════════════╬══════════════╬════════════════════════════  ║
║ Q1 — No opt    ║ OLTP         ║ No           ║ FULL TABLE SCAN (slowest)    ║
║ Q2 — With opt  ║ OLTP         ║ Composite    ║ Index Range Scan (better)    ║
║ Q3 — No opt    ║ DWH/Star     ║ No           ║ Integer FK Joins (fast)      ║
║ Q4 — With opt  ║ DWH/Star     ║ Covering     ║ Index-Only Scan (fastest)    ║
╚════════════════╩══════════════╩══════════════╩════════════════════════════  ║

WHY DWH IS FASTER THAN OLTP FOR ANALYTICS:
────────────────────────────────────────────
1. PRE-COMPUTED VALUES
   OLTP: quantity_sold * unit_price  → computed at query time
   DWH:  total_amount stored in FACT  → read directly

2. DATE DIMENSION ELIMINATES FUNCTIONS
   OLTP: WHERE YEAR(sale_date) = 2025   ← blocks index, forces full scan
   DWH:  WHERE dd.year = 2025           ← integer comparison, uses index

3. INTEGER SURROGATE KEY JOINS
   OLTP: JOIN ON product_name (VARCHAR) ← byte-by-byte string comparison
   DWH:  JOIN ON product_key (INT)      ← single integer comparison

4. DENORMALIZATION IN DIMENSIONS
   OLTP: 3+ tables to join for product + category + brand
   DWH:  All in DIM_PRODUCT → 1 join

5. COVERING INDEXES
   OLTP: Indexes on individual columns
   DWH:  Composite covering index on (product_key, location_key, date_key)
         → entire query answered from index, no table access

OPTIMIZATION TECHNIQUES APPLIED:
────────────────────────────────────────────
┌──────────────────────────────────────────────────────────┐
│ TECHNIQUE           │ OLTP            │ DWH               │
├──────────────────────────────────────────────────────────┤
│ Composite Index     │ Yes (3 cols)    │ Yes (covering)    │
│ Surrogate Keys      │ No              │ Yes (INT PKs)     │
│ Subquery Filter     │ Yes             │ Not needed        │
│ Avoid fn on cols    │ Use range >/<   │ Use integer keys  │
│ Pre-stored metrics  │ No              │ Yes (FACT cols)   │
│ Date pre-extracted  │ No              │ DIM_DATE table    │
└──────────────────────────────────────────────────────────┘
*/

-- ─────────────────────────────────────────────────────────────
-- DEMONSTRATE: EXPLAIN PLAN difference example
-- Run this and compare "rows" scanned in output
-- ─────────────────────────────────────────────────────────────

-- WORST CASE: OLTP, no indexes, string function on date
EXPLAIN SELECT SUM(total_amount)
FROM SALES s
JOIN PRODUCT p ON s.product_id = p.product_id
WHERE p.product_name = 'Laptop Pro 15'
  AND YEAR(s.sale_date) = 2025;
-- ↑ Expected: type=ALL (full scan), rows=50 (all rows checked)

-- BEST CASE: DWH Star Schema, covering index, integer keys
EXPLAIN SELECT SUM(fs.net_revenue)
FROM FACT_SALES fs
JOIN DIM_DATE dd ON fs.date_key = dd.date_key
WHERE fs.product_key = 1
  AND dd.year = 2025;
-- ↑ Expected: type=ref (index lookup), rows=6 (only matching rows)
