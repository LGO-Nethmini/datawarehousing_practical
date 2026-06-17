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
DROP VIEW IF EXISTS VW_TIME_HIERARCHY;
DROP VIEW IF EXISTS VW_LOCATION_HIERARCHY;
DROP VIEW IF EXISTS VW_PRODUCT_HIERARCHY;
DROP VIEW IF EXISTS VW_CUSTOMER_HIERARCHY;
DROP TABLE IF EXISTS DIM_TIME_MONTH;
DROP TABLE IF EXISTS DIM_TIME_QUARTER;
DROP TABLE IF EXISTS DIM_TIME_YEAR;
DROP TABLE IF EXISTS DIM_GEO_CITY;
DROP TABLE IF EXISTS DIM_GEO_STATE;
DROP TABLE IF EXISTS DIM_GEO_COUNTRY;
DROP TABLE IF EXISTS DIM_GEO_REGION;
DROP TABLE IF EXISTS DIM_PRODUCT_BRAND;
DROP TABLE IF EXISTS DIM_PRODUCT_SUBCATEGORY;
DROP TABLE IF EXISTS DIM_PRODUCT_CATEGORY;
DROP TABLE IF EXISTS DIM_CUSTOMER_CITY;
DROP TABLE IF EXISTS DIM_CUSTOMER_STATE;
DROP TABLE IF EXISTS DIM_CUSTOMER_SEGMENT;

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
    day_number    NUMBER(3),                 -- 1–31
    week_number   NUMBER(3),                 -- 1–52
    month_number  NUMBER(3),                 -- 1–12
    month_name    VARCHAR(10),               -- January...
    quarter       NUMBER(3),                 -- 1–4
    year          NUMBER(5),
    is_weekend    CHAR(1)     DEFAULT '0',
    is_holiday    CHAR(1)     DEFAULT '0'
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
    sale_key        NUMBER(19)   PRIMARY KEY,

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

-- ─────────────────────────────────────────────────────
-- HIERARCHY SUPPORT TABLES (Snowflake-style helper layer)
-- These tables model actual roll-up hierarchies while keeping
-- core DIM_* tables unchanged for existing loads.
-- ─────────────────────────────────────────────────────

CREATE TABLE DIM_TIME_YEAR (
    year_key      NUMBER(5)    PRIMARY KEY,
    year_label    VARCHAR(10) NOT NULL
);

CREATE TABLE DIM_TIME_QUARTER (
    quarter_key     INT         PRIMARY KEY,
    year_key        NUMBER(5)    NOT NULL,
    quarter_number  NUMBER(3)     NOT NULL,
    quarter_label   VARCHAR(10) NOT NULL,
    FOREIGN KEY (year_key) REFERENCES DIM_TIME_YEAR(year_key)
);

CREATE TABLE DIM_TIME_MONTH (
    month_key      INT         PRIMARY KEY,
    quarter_key    INT         NOT NULL,
    month_number   NUMBER(3)     NOT NULL,
    month_name     VARCHAR(10) NOT NULL,
    FOREIGN KEY (quarter_key) REFERENCES DIM_TIME_QUARTER(quarter_key)
);

CREATE TABLE DIM_GEO_REGION (
    region_key     INT          PRIMARY KEY,
    region_name    VARCHAR(50)  NOT NULL
);

CREATE TABLE DIM_GEO_COUNTRY (
    country_key    INT          PRIMARY KEY,
    region_key     INT          NOT NULL,
    country_name   VARCHAR(50)  NOT NULL,
    FOREIGN KEY (region_key) REFERENCES DIM_GEO_REGION(region_key)
);

CREATE TABLE DIM_GEO_STATE (
    state_key      INT          PRIMARY KEY,
    country_key    INT          NOT NULL,
    state_name     VARCHAR(50)  NOT NULL,
    FOREIGN KEY (country_key) REFERENCES DIM_GEO_COUNTRY(country_key)
);

CREATE TABLE DIM_GEO_CITY (
    city_key       INT          PRIMARY KEY,
    state_key      INT          NOT NULL,
    city_name      VARCHAR(50)  NOT NULL,
    FOREIGN KEY (state_key) REFERENCES DIM_GEO_STATE(state_key)
);

CREATE TABLE DIM_PRODUCT_CATEGORY (
    category_key    INT          PRIMARY KEY,
    category_name   VARCHAR(50)  NOT NULL
);

CREATE TABLE DIM_PRODUCT_SUBCATEGORY (
    sub_category_key   INT          PRIMARY KEY,
    category_key       INT          NOT NULL,
    sub_category_name  VARCHAR(50)  NOT NULL,
    FOREIGN KEY (category_key) REFERENCES DIM_PRODUCT_CATEGORY(category_key)
);

CREATE TABLE DIM_PRODUCT_BRAND (
    brand_key      INT          PRIMARY KEY,
    sub_category_key INT        NOT NULL,
    brand_name     VARCHAR(50)  NOT NULL,
    FOREIGN KEY (sub_category_key) REFERENCES DIM_PRODUCT_SUBCATEGORY(sub_category_key)
);

CREATE TABLE DIM_CUSTOMER_SEGMENT (
    segment_key      INT          PRIMARY KEY,
    segment_name     VARCHAR(30)  NOT NULL
);

CREATE TABLE DIM_CUSTOMER_STATE (
    customer_state_key  INT          PRIMARY KEY,
    state_name          VARCHAR(50)  NOT NULL
);

CREATE TABLE DIM_CUSTOMER_CITY (
    customer_city_key   INT          PRIMARY KEY,
    customer_state_key  INT          NOT NULL,
    city_name           VARCHAR(50)  NOT NULL,
    FOREIGN KEY (customer_state_key) REFERENCES DIM_CUSTOMER_STATE(customer_state_key)
);

-- ─────────────────────────────────────────────────────
-- HIERARCHY VIEWS from existing dimensions
-- Time hierarchy: Year -> Quarter -> Month -> Day
-- Location hierarchy: Region -> Country -> State -> City -> Store
-- Product hierarchy: Category -> Sub-category -> Brand -> Product
-- Customer hierarchy: Segment -> State -> City -> Customer
-- ─────────────────────────────────────────────────────

CREATE VIEW VW_TIME_HIERARCHY AS
SELECT
    d.date_key,
    d.full_date,
    d.year,
    d.quarter,
    d.month_number,
    d.month_name,
    d.week_number,
    d.day_number,
    d.day_of_week
FROM DIM_DATE d;

CREATE VIEW VW_LOCATION_HIERARCHY AS
SELECT
    l.location_key,
    l.store_name,
    l.city,
    l.state,
    l.country,
    l.region
FROM DIM_LOCATION l;

CREATE VIEW VW_PRODUCT_HIERARCHY AS
SELECT
    p.product_key,
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    p.brand,
    p.unit_price
FROM DIM_PRODUCT p;

CREATE VIEW VW_CUSTOMER_HIERARCHY AS
SELECT
    c.customer_key,
    c.customer_id,
    c.full_name,
    c.customer_segment,
    c.state,
    c.city,
    c.zip_code
FROM DIM_CUSTOMER c;
