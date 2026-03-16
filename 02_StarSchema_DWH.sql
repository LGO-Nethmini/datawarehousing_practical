-- ============================================================
-- STEP 2: DATA WAREHOUSE — STAR SCHEMA
-- Purpose: Analytical / Reporting queries (OLAP)
-- Optimized for: SELECT, GROUP BY, aggregations (reads)
-- Structure: 1 Fact Table + 4 Dimension Tables
-- ============================================================

-- Drop if exists
DROP TABLE IF EXISTS FACT_SALES;
DROP TABLE IF EXISTS DIM_DATE;
DROP TABLE IF EXISTS DIM_CUSTOMER;
DROP TABLE IF EXISTS DIM_PRODUCT;
DROP TABLE IF EXISTS DIM_LOCATION;

-- ─────────────────────────────────────────────────────
-- DIMENSION TABLE 1: DIM_DATE
-- Why? Time is the most queried dimension in analytics.
-- Pre-exploding date into attributes avoids date functions
-- in every query → massive performance gain.
-- ─────────────────────────────────────────────────────
CREATE TABLE DIM_DATE (
    date_key      INT         PRIMARY KEY,   -- surrogate key e.g. 20250115
    full_date     DATE        NOT NULL,
    day_of_week   VARCHAR(10),               -- Monday, Tuesday...
    day_number    TINYINT,                   -- 1–31
    week_number   TINYINT,                   -- 1–52
    month_number  TINYINT,                   -- 1–12
    month_name    VARCHAR(10),               -- January...
    quarter       TINYINT,                   -- 1–4
    year          SMALLINT,
    is_weekend    BOOLEAN     DEFAULT FALSE,
    is_holiday    BOOLEAN     DEFAULT FALSE
);

-- ─────────────────────────────────────────────────────
-- DIMENSION TABLE 2: DIM_CUSTOMER
-- Slowly Changing Dimension (SCD Type 1)
-- Stores latest customer snapshot for analytics
-- ─────────────────────────────────────────────────────
CREATE TABLE DIM_CUSTOMER (
    customer_key  INT         PRIMARY KEY,   -- surrogate key (DWH)
    customer_id   INT,                       -- natural key from OLTP
    full_name     VARCHAR(100),
    email         VARCHAR(100),
    city          VARCHAR(50),
    state         VARCHAR(50),
    zip_code      VARCHAR(10),
    customer_segment VARCHAR(30)             -- e.g. Premium, Regular, New
);

-- ─────────────────────────────────────────────────────
-- DIMENSION TABLE 3: DIM_PRODUCT
-- Denormalized: category & brand stored directly
-- No joins needed during analytics → faster queries
-- ─────────────────────────────────────────────────────
CREATE TABLE DIM_PRODUCT (
    product_key   INT         PRIMARY KEY,   -- surrogate key
    product_id    INT,                       -- natural key from OLTP
    product_name  VARCHAR(100),
    category      VARCHAR(50),
    sub_category  VARCHAR(50),
    brand         VARCHAR(50),
    unit_price    DECIMAL(10,2)
);

-- ─────────────────────────────────────────────────────
-- DIMENSION TABLE 4: DIM_LOCATION
-- Denormalized geography hierarchy
-- region → country → state → city → store
-- ─────────────────────────────────────────────────────
CREATE TABLE DIM_LOCATION (
    location_key  INT         PRIMARY KEY,   -- surrogate key
    location_id   INT,                       -- natural key from OLTP
    store_name    VARCHAR(100),
    city          VARCHAR(50),
    state         VARCHAR(50),
    country       VARCHAR(50),
    region        VARCHAR(50)
);

-- ─────────────────────────────────────────────────────
-- FACT TABLE: FACT_SALES
-- Contains ONLY measurable numeric facts + FK keys
-- All descriptive data lives in Dimension tables
-- This separation is what makes DWH queries fast
-- ─────────────────────────────────────────────────────
CREATE TABLE FACT_SALES (
    sale_key        BIGINT       PRIMARY KEY AUTO_INCREMENT,

    -- Foreign Keys → Dimension Tables (surrogate keys)
    date_key        INT          NOT NULL,
    customer_key    INT          NOT NULL,
    product_key     INT          NOT NULL,
    location_key    INT          NOT NULL,

    -- Degenerate dimension (transaction reference)
    sale_id         INT,

    -- FACTS (measurable metrics)
    quantity_sold   INT          NOT NULL,
    unit_price      DECIMAL(10,2),
    total_amount    DECIMAL(12,2),
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    net_revenue     DECIMAL(12,2),

    -- Constraints
    FOREIGN KEY (date_key)     REFERENCES DIM_DATE(date_key),
    FOREIGN KEY (customer_key) REFERENCES DIM_CUSTOMER(customer_key),
    FOREIGN KEY (product_key)  REFERENCES DIM_PRODUCT(product_key),
    FOREIGN KEY (location_key) REFERENCES DIM_LOCATION(location_key)
);

-- ─────────────────────────────────────────────────────
-- INDEXES on FACT_SALES (critical for DWH performance)
-- Composite indexes match common query patterns
-- ─────────────────────────────────────────────────────
CREATE INDEX idx_fact_product_date    ON FACT_SALES(product_key, date_key);
CREATE INDEX idx_fact_location_date   ON FACT_SALES(location_key, date_key);
CREATE INDEX idx_fact_product_loc     ON FACT_SALES(product_key, location_key);
CREATE INDEX idx_fact_all_dims        ON FACT_SALES(product_key, location_key, date_key);
