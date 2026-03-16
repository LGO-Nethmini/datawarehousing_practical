# Phase 3 Documentation Report

## Title
Implementation of Data Warehouse Architecture with Staging Area, Star Schema, and Sales Data Mart

## Objective
In Phase 3, the solution is extended from the dimensional model to a complete data warehouse architecture. The architecture includes:
- Source transactional data (OLTP)
- Staging area
- Data warehouse schema
- Sales Data Mart

The goal is to support business reporting in a cleaner and more scalable way.

---

## Architecture Overview
The Phase 3 architecture contains four layers:

1. **OLTP Layer**
   - `customer`
   - `product`
   - `location`
   - `sales`

2. **Staging Area**
   - `stg_customer`
   - `stg_product`
   - `stg_location`
   - `stg_sales`

3. **Data Warehouse Layer**
   - Fact table: `fact_sales`
   - Dimension tables: `dim_customer`, `dim_product`, `dim_location`, `dim_date`

4. **Sales Data Mart**
   - `sales_datamart_monthly`
   - `vw_sales_datamart`

---

## Role of Each Layer

### 1. OLTP Layer
This layer stores daily transactional data. It is optimized for inserts, updates, and deletes.

### 2. Staging Area
The staging area acts as a temporary storage layer between OLTP and the data warehouse.

#### Purpose of staging:
- collect source data
- clean and validate data before warehouse loading
- isolate source systems from analytical systems
- simplify ETL processing

### 3. Data Warehouse Layer
The warehouse uses a **star schema**.

#### Fact Table
- `fact_sales`

#### Dimension Tables
- `dim_customer`
- `dim_product`
- `dim_location`
- `dim_date`

This structure supports analytical queries efficiently.

### 4. Sales Data Mart
The sales data mart is a business-oriented subset of the warehouse created specifically for sales analysis.

#### Sales data mart benefits:
- ready-to-use reporting structure
- pre-aggregated monthly values
- simpler business queries
- faster dashboard and reporting performance

---

## Why Star Schema Was Used
A star schema was used because:
- it is easy to understand
- it supports reporting and aggregation well
- it reduces query complexity
- it is suitable for sales analysis

A snowflake schema could also be used, but the star schema is simpler and better for this academic business case.

---

## ETL Flow
The ETL flow in Phase 3 is:

1. Extract data from OLTP tables
2. Load data into staging tables
3. Transform and organize data into dimensions and fact table
4. Aggregate warehouse data into the sales data mart

---

## Business Queries Supported
The Phase 3 architecture supports:
1. Sales for a given product by location over a period of time
2. Maximum sales for a given product over time for a given location
3. Revenue analysis by region, category, and period

---

## Conclusion
Phase 3 introduces a complete data warehouse architecture with a staging area and a sales data mart. The staging area improves ETL organization, while the sales data mart makes reporting easier and faster. This architecture is more suitable for business intelligence and decision support than using OLTP tables directly.

---

## Files Used
- [09_phase3_staging_and_datamart.sql](09_phase3_staging_and_datamart.sql)
- [10_phase3_demo_queries.sql](10_phase3_demo_queries.sql)
- [PHASE3_REPORT.md](PHASE3_REPORT.md)
