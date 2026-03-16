# Phase 2 Documentation Report

## Title
Performance Comparison of OLTP Queries and Dimensional Model Queries in a Data Warehouse

## Objective
In Phase 1, the application was implemented using the OLTP workflow, where queries were executed directly on transactional tables such as `customer`, `product`, `location`, and `sales`.

In Phase 2, a dimensional model was introduced using:
- `fact_sales` as the fact table
- `dim_product`, `dim_location`, `dim_date`, and `dim_customer` as dimension tables

The objective of Phase 2 is to compare the same analytical queries:
1. Without dimension/fact tables (OLTP model)
2. With dimension/fact tables (Star Schema / Data Warehouse model)

---

## Business Requirement
The system should answer the following queries:

1. **Sales for a given product by location over a period of time**
2. **Maximum number of sales for a given product over time for a given location**

---

## Phase 1: OLTP Model
In the OLTP model, the data is stored in normalized transactional tables:
- `customer`
- `product`
- `location`
- `sales`

### Characteristics of OLTP
- Suitable for daily transactions
- Optimized for insert, update, delete operations
- Queries for analysis are more complex
- More runtime joins and calculations are needed

---

## Phase 2: Dimensional Model
In Phase 2, a star schema was introduced.

### Fact Table
- `fact_sales`

This table stores measurable business facts such as:
- `quantity_sold`
- `unit_price`
- `total_amount`
- `discount_amount`
- `net_revenue`

### Dimension Tables
- `dim_product` → product details
- `dim_location` → location details
- `dim_date` → day, month, quarter, year
- `dim_customer` → customer details

### Characteristics of Dimensional Model
- Designed for analytics and reporting
- Easier aggregation and summarization
- Better for OLAP queries
- Simpler query structure for business analysis

---

## Query Comparison

## Query 1
### Requirement
**Sales for a given product by location over a period of time**

### OLTP Query
Uses `sales`, `product`, and `location` directly.

### Star Schema Query
Uses `fact_sales`, `dim_product`, `dim_location`, and `dim_date`.

### Observation
- OLTP query performs joins on transactional tables
- Star schema query is easier to group by month/year/location
- Star schema is better suited for reporting and trend analysis

---

## Query 2
### Requirement
**Maximum number of sales for a given product over time for a given location**

### OLTP Query
Uses runtime functions like `YEAR(sale_date)` and `MONTH(sale_date)`.

### Star Schema Query
Uses pre-structured attributes from `dim_date` such as:
- `month_name`
- `month_number`
- `year`

### Observation
- OLTP requires more runtime processing
- Star schema reduces complexity by separating facts and descriptive dimensions
- Analytical queries become cleaner and more readable

---

## Performance Comparison Using EXPLAIN
The `EXPLAIN` command was used to compare query execution plans.

### Important EXPLAIN Columns
- `table` → which table is being accessed
- `type` → join/access type
- `possible_keys` → indexes MySQL may use
- `key` → actual index used
- `rows` → estimated rows scanned
- `Extra` → extra operations such as `Using where`, `Using temporary`, `Using filesort`

### OLTP Observations
Common findings in OLTP queries:
- More dependence on transactional joins
- Runtime date processing using `YEAR()` and `MONTH()`
- `Using temporary`
- `Using filesort`
- Higher query cost for analytics

### Star Schema Observations
Common findings in dimensional queries:
- Better analytical structure
- Easier joins through surrogate keys
- Better grouping by date/location/product
- More suitable for reporting workloads
- Improved readability and maintainability

---

## Conclusion
The Phase 2 implementation demonstrates that introducing fact and dimension tables improves analytical querying.

### Final Conclusion
- The **OLTP model** is suitable for transactional operations.
- The **dimensional model** is better for business intelligence and reporting.
- Fact and dimension tables simplify query writing.
- Query analysis using `EXPLAIN` shows that the dimensional model is more appropriate for analytical workloads.

Therefore, Phase 2 successfully improves the system by introducing a star schema and enabling more efficient decision-support queries.

---

## Files Used
- [01_OLTP_schema.sql](01_OLTP_schema.sql)
- [02_StarSchema_DWH.sql](02_StarSchema_DWH.sql)
- [03_sample_data.sql](03_sample_data.sql)
- [07_phase2_performance_comparison.sql](07_phase2_performance_comparison.sql)
- [08_phase2_clean_output.sql](08_phase2_clean_output.sql)

---

## Short Viva Answer
In Phase 2, the OLTP transactional model was transformed into a dimensional model using one fact table and multiple dimension tables. The same business queries were executed in both models and compared using `EXPLAIN`. The star schema provided a cleaner analytical structure, simplified query design, and better reporting suitability compared to the OLTP model.
