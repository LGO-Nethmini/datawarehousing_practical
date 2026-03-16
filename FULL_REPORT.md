# DATA WAREHOUSING PRACTICAL REPORT

**Subject:** Data Warehousing  
**Database:** datawarehousing_practical  
**Environment:** XAMPP (MariaDB), VS Code, SQLTools  
**Date:** March 2026  

---

## Table of Contents
1. Business Problem
2. Phase 1 — OLTP Design
3. Phase 2 — Dimensional Model
4. Phase 3 — Data Warehouse Architecture
5. Query Results
6. Performance Comparison
7. Conclusion

---

## 1. Business Problem

A retail sales organization needs to analyze its transactional data to support business decisions.

**The organization cannot currently answer these questions efficiently:**

- What are the sales for a given product by location over a period of time?
- What is the maximum number of sales for a given product over time for a given location?

**Root Cause:**  
The transactional database is designed for operations, not analytics. Running analytical queries directly on OLTP tables is complex and slow.

**Solution:**  
Build a layered data warehouse architecture with staging, dimensional model, and a data mart.

---

## 2. Phase 1 — OLTP Design

### Objective
Design the transactional database for the sales business.

### Tables Designed

| Table | Purpose |
|---|---|
| `customer` | Stores customer personal details |
| `product` | Stores product details and pricing |
| `location` | Stores store and region details |
| `sales` | Records each sales transaction |

### Attributes

#### CUSTOMER
| Column | Type | Description |
|---|---|---|
| customer_id | INT (PK) | Unique customer identifier |
| first_name | VARCHAR | First name |
| last_name | VARCHAR | Last name |
| email | VARCHAR | Email address |
| phone | VARCHAR | Phone number |
| city | VARCHAR | City |
| state | VARCHAR | State |
| registration_date | DATE | Date of registration |

#### PRODUCT
| Column | Type | Description |
|---|---|---|
| product_id | INT (PK) | Unique product identifier |
| product_name | VARCHAR | Name of product |
| category | VARCHAR | Product category |
| brand | VARCHAR | Brand name |
| unit_price | DECIMAL | Price per unit |
| stock_quantity | INT | Quantity in stock |

#### LOCATION
| Column | Type | Description |
|---|---|---|
| location_id | INT (PK) | Unique store identifier |
| store_name | VARCHAR | Store name |
| city | VARCHAR | City |
| state | VARCHAR | State |
| region | VARCHAR | Geographic region |

#### SALES
| Column | Type | Description |
|---|---|---|
| sale_id | INT (PK) | Unique transaction identifier |
| customer_id | INT (FK) | Reference to customer |
| product_id | INT (FK) | Reference to product |
| location_id | INT (FK) | Reference to location |
| sale_date | DATE | Date of transaction |
| quantity_sold | INT | Units sold |
| unit_price | DECIMAL | Price at time of sale |
| total_amount | DECIMAL | Total value |
| payment_method | VARCHAR | Payment method used |

### ER Diagram

```
CUSTOMER ─────────────────────────────┐
                                       │
PRODUCT  ──────────────────────────> SALES
                                       │
LOCATION ─────────────────────────────┘
```

Each SALES record links to one CUSTOMER, one PRODUCT, and one LOCATION.

### Phase 1 Queries

**Query 1 — Sales for a given product by location over a period of time**
```sql
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
```

**Query 2 — Maximum sales for a given product over time for a given location**
```sql
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
```

### Phase 1 Limitations
- Queries are complex and hard to maintain
- Date functions like YEAR() and MONTH() prevent index usage
- Joins on large tables are slow
- No pre-aggregated data for reporting
- Not suitable for business intelligence

---

## 3. Phase 2 — Dimensional Model

### Objective
Introduce fact and dimension tables to improve analytical query performance and simplify reporting.

### What Changed from Phase 1
In Phase 1, all queries worked directly on OLTP tables. In Phase 2, a star schema was designed with:
- One central fact table
- Four dimension tables

### Dimension Tables

#### DIM_DATE
Pre-exploded date attributes for easy time-based filtering.

| Column | Description |
|---|---|
| date_key | Integer key (YYYYMMDD) |
| full_date | Actual date |
| day_of_week | Monday to Sunday |
| month_name | January to December |
| month_number | 1 to 12 |
| quarter | 1 to 4 |
| year | 4-digit year |
| is_weekend | Boolean flag |

#### DIM_PRODUCT
| Column | Description |
|---|---|
| product_key | Surrogate key |
| product_id | Natural key from OLTP |
| product_name | Name of product |
| category | Category |
| sub_category | Sub-category |
| brand | Brand |
| unit_price | Price |

#### DIM_LOCATION
| Column | Description |
|---|---|
| location_key | Surrogate key |
| location_id | Natural key from OLTP |
| store_name | Store name |
| city | City |
| state | State |
| region | Geographic region |

#### DIM_CUSTOMER
| Column | Description |
|---|---|
| customer_key | Surrogate key |
| customer_id | Natural key from OLTP |
| full_name | Full name |
| city | City |
| customer_segment | Premium / Regular / New |

### Fact Table

#### FACT_SALES
| Column | Description |
|---|---|
| sale_key | Auto-increment PK |
| date_key | FK to DIM_DATE |
| customer_key | FK to DIM_CUSTOMER |
| product_key | FK to DIM_PRODUCT |
| location_key | FK to DIM_LOCATION |
| quantity_sold | Number of units sold |
| unit_price | Price at time of sale |
| total_amount | Gross revenue |
| discount_amount | Discount applied |
| net_revenue | Net revenue after discount |

### Star Schema Diagram

```
               DIM_DATE
                  │
DIM_CUSTOMER ── FACT_SALES ── DIM_PRODUCT
                  │
              DIM_LOCATION
```

### Phase 2 Queries

**Query 1 — Star Schema**
```sql
SELECT
    dp.product_name,
    dl.city,
    dd.month_name,
    dd.year,
    SUM(fs.quantity_sold) AS total_units_sold,
    SUM(fs.net_revenue)   AS total_revenue
FROM fact_sales fs
JOIN dim_product  dp ON fs.product_key  = dp.product_key
JOIN dim_location dl ON fs.location_key = dl.location_key
JOIN dim_date     dd ON fs.date_key     = dd.date_key
WHERE dp.product_name = 'Laptop Pro 15'
  AND dd.year = 2025
GROUP BY dp.product_name, dl.city, dd.month_name, dd.year, dd.month_number
ORDER BY dd.month_number, dl.city;
```

**Query 2 — Star Schema**
```sql
SELECT
    dp.product_name,
    dl.city,
    dd.month_name,
    MAX(fs.quantity_sold) AS max_units_single_sale,
    SUM(fs.quantity_sold) AS total_units_sold,
    SUM(fs.net_revenue)   AS total_revenue
FROM fact_sales fs
JOIN dim_product  dp ON fs.product_key  = dp.product_key
JOIN dim_location dl ON fs.location_key = dl.location_key
JOIN dim_date     dd ON fs.date_key     = dd.date_key
WHERE dp.product_name = 'Laptop Pro 15'
  AND dl.city = 'New York'
  AND dd.year = 2025
GROUP BY dp.product_name, dl.city, dd.month_name, dd.year, dd.month_number
ORDER BY dd.month_number;
```

### Why Star Schema is Better

| Aspect | OLTP | Star Schema |
|---|---|---|
| Date filtering | YEAR(sale_date) — blocks index | dd.year = 2025 — integer lookup |
| Join columns | VARCHAR string comparison | INT surrogate key |
| Stored metrics | Computed at query time | Pre-stored in FACT table |
| Query complexity | Complex multi-table joins | Simple fact + dimension joins |
| Reporting | Not suitable | Designed for reporting |
| Grouping | Complex | Simple by month/year/city |

---

## 4. Phase 3 — Data Warehouse Architecture

### Objective
Introduce a complete data warehouse architecture with:
- Staging area
- Star schema
- Sales Data Mart

### Architecture Diagram

```
OLTP Layer        Staging Area       Data Warehouse       Sales Data Mart
─────────         ────────────       ──────────────       ───────────────
customer     →    stg_customer  →    dim_customer    →
product      →    stg_product   →    dim_product         sales_datamart
location     →    stg_location  →    dim_location    →   _monthly
sales        →    stg_sales     →    dim_date
                                     fact_sales      →    vw_sales_datamart
```

### Layer Descriptions

#### Layer 1 — OLTP (Source)
Stores daily transactional records. Not suitable for analytics.

#### Layer 2 — Staging Area
Temporarily holds data extracted from source systems.

**Purpose of staging:**
- Cleanly separate source and warehouse
- Allow data validation before loading
- Support reloading without affecting production
- Simplify ETL pipeline management

**Staging tables:**
- `stg_customer`
- `stg_product`
- `stg_location`
- `stg_sales`

#### Layer 3 — Data Warehouse
Stores integrated analytical data using the star schema.

**Tables:**
- `fact_sales` — central fact table
- `dim_customer` — customer dimension
- `dim_product` — product dimension
- `dim_location` — location dimension
- `dim_date` — date dimension

#### Layer 4 — Sales Data Mart
Pre-aggregated monthly data for business reporting.

**Table: `sales_datamart_monthly`**

| Column | Description |
|---|---|
| year | Year |
| quarter | Quarter (1–4) |
| month_number | Month number |
| month_name | Month name |
| product_name | Product |
| category | Category |
| region | Region |
| city | City |
| number_of_transactions | Count of sales |
| total_units_sold | Sum of quantity sold |
| gross_revenue | Total revenue |
| total_discount | Total discounts |
| net_revenue | Net revenue |
| avg_revenue_per_transaction | Average revenue |
| max_units_single_sale | Maximum units in one sale |

### Phase 3 Query — Using Data Mart

**Query 1 — Sales by product, location, and time**
```sql
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
```

**Query 2 — Maximum sales by product and location**
```sql
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
```

---

## 5. Query Results

### Sample Output — Query 1 (OLTP)

| product_name | city | sale_date | total_units_sold | total_revenue |
|---|---|---|---|---|
| Laptop Pro 15 | New York | 2025-01-05 | 2 | 2400.00 |
| Laptop Pro 15 | Chicago | 2025-03-12 | 3 | 3600.00 |
| Laptop Pro 15 | New York | 2025-05-03 | 1 | 1200.00 |
| Laptop Pro 15 | Los Angeles | 2025-07-05 | 2 | 2400.00 |

### Sample Output — Query 1 (Star Schema)

| product_name | city | month_name | year | total_units_sold | total_revenue |
|---|---|---|---|---|---|
| Laptop Pro 15 | Chicago | March | 2025 | 3 | 3500.00 |
| Laptop Pro 15 | Los Angeles | February | 2025 | 1 | 1150.00 |
| Laptop Pro 15 | New York | January | 2025 | 2 | 2400.00 |
| Laptop Pro 15 | New York | May | 2025 | 1 | 1200.00 |

### Sample Output — Query 2 (Star Schema, New York)

| product_name | city | month_name | max_units | total_units | net_revenue |
|---|---|---|---|---|---|
| Laptop Pro 15 | New York | January | 2 | 2 | 2400.00 |
| Laptop Pro 15 | New York | March | 1 | 1 | 1200.00 |
| Laptop Pro 15 | New York | May | 1 | 1 | 1200.00 |
| Laptop Pro 15 | New York | August | 3 | 3 | 3600.00 |

---

## 6. Performance Comparison

### EXPLAIN Analysis Summary

| Query | Schema | type | rows scanned | Extra |
|---|---|---|---|---|
| Query 1 | OLTP | ref / ALL | 2–5 | Using temporary; Using filesort |
| Query 1 | Star Schema | ref / eq_ref | 1–2 | Using index |
| Query 2 | OLTP | ref / ALL | 1–5 | Using where; Using filesort |
| Query 2 | Star Schema | ref / const | 1 | Using index |

### Key Observations

**OLTP:**
- Uses `Using temporary` and `Using filesort` — indicates extra operations needed
- Higher rows scanned
- Date functions like `YEAR()` and `MONTH()` prevent index use
- VARCHAR comparisons on product name are slower

**Star Schema:**
- Uses covering index
- Integer surrogate key joins are faster
- Pre-stored date attributes avoid runtime calculations
- Fewer rows scanned
- `Using index` — most efficient access type

### Performance Conclusion

The star schema dimensional model is significantly better for analytical queries because:
- It reduces rows scanned per query
- It uses better index access types
- It avoids runtime calculations
- It provides pre-stored aggregated metrics in the fact table
- The data mart further reduces query complexity

---

## 7. Conclusion

### Phase 1
The OLTP model was designed and implemented with the four tables required for sales transaction processing. Business queries were executed successfully but with higher complexity and lower performance for analytics.

### Phase 2
The dimensional model was introduced using a star schema. Fact and dimension tables improved query structure, readability, and performance. The `EXPLAIN` comparison confirmed that the star schema performs better for analytical queries.

### Phase 3
A complete data warehouse architecture was implemented with:
- Staging area for ETL pipeline management
- Star schema data warehouse for integrated analytics
- Sales data mart for business-oriented reporting

### Final Summary

| Phase | Design | Query Performance | Use Case |
|---|---|---|---|
| Phase 1 | OLTP (normalized) | Lower | Transactions |
| Phase 2 | Star Schema | Higher | Analytics |
| Phase 3 | Full DWH Architecture | Best | Reporting + BI |

The three-phase implementation demonstrates the full evolution from a transactional system to a complete data warehouse solution capable of supporting business intelligence and decision making.

---

## Files Summary

| File | Purpose |
|---|---|
| 01_OLTP_schema.sql | OLTP table definitions |
| 02_StarSchema_DWH.sql | Star schema DDL |
| 03_sample_data.sql | Sample data (50 records) |
| 04_query_comparison.sql | OLTP vs star schema queries |
| 05_performance_summary.sql | EXPLAIN performance analysis |
| 06_demo_queries.sql | Clean demo queries |
| 07_phase2_performance_comparison.sql | Phase 2 full comparison |
| 08_phase2_clean_output.sql | Phase 2 clean outputs |
| 09_phase3_staging_and_datamart.sql | Staging + data mart creation |
| 10_phase3_demo_queries.sql | Phase 3 demo queries |

---

*End of Report*
