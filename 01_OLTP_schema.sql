-- ============================================================
-- STEP 1: OLTP SCHEMA (Online Transaction Processing)
-- Purpose: Day-to-day transactional operations
-- Optimized for: INSERT, UPDATE, DELETE (writes)
-- NOT optimized for: complex analytics (reads)
-- ============================================================

-- Drop tables if exist (clean start)
DROP TABLE IF EXISTS SALES;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS PRODUCT;
DROP TABLE IF EXISTS LOCATION;

-- ─────────────────────────────────────────
-- CUSTOMER TABLE
-- ─────────────────────────────────────────
CREATE TABLE CUSTOMER (
    customer_id       INT           PRIMARY KEY,
    first_name        VARCHAR(50)   NOT NULL,
    last_name         VARCHAR(50)   NOT NULL,
    email             VARCHAR(100)  UNIQUE NOT NULL,
    phone             VARCHAR(15),
    address           VARCHAR(200),
    city              VARCHAR(50),
    state             VARCHAR(50),
    zip_code          VARCHAR(10),
    registration_date DATE          DEFAULT CURRENT_DATE
);

-- ─────────────────────────────────────────
-- PRODUCT TABLE
-- ─────────────────────────────────────────
CREATE TABLE PRODUCT (
    product_id    INT           PRIMARY KEY,
    product_name  VARCHAR(100)  NOT NULL,
    category      VARCHAR(50),
    brand         VARCHAR(50),
    unit_price    DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT          DEFAULT 0,
    supplier_id   INT
);

-- ─────────────────────────────────────────
-- LOCATION TABLE
-- ─────────────────────────────────────────
CREATE TABLE LOCATION (
    location_id  INT           PRIMARY KEY,
    store_name   VARCHAR(100)  NOT NULL,
    address      VARCHAR(200),
    city         VARCHAR(50),
    state        VARCHAR(50),
    country      VARCHAR(50),
    region       VARCHAR(50),
    zip_code     VARCHAR(10)
);

-- ─────────────────────────────────────────
-- SALES TABLE (Transaction Fact)
-- ─────────────────────────────────────────
CREATE TABLE SALES (
    sale_id        INT            PRIMARY KEY,
    customer_id    INT            NOT NULL,
    product_id     INT            NOT NULL,
    location_id    INT            NOT NULL,
    sale_date      DATE           NOT NULL,
    quantity_sold  INT            NOT NULL CHECK (quantity_sold > 0),
    unit_price     DECIMAL(10,2)  NOT NULL,
    total_amount   DECIMAL(12,2)  GENERATED ALWAYS AS (quantity_sold * unit_price) STORED,
    payment_method VARCHAR(30)    DEFAULT 'Cash',

    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (product_id)  REFERENCES PRODUCT(product_id),
    FOREIGN KEY (location_id) REFERENCES LOCATION(location_id)
);

-- ─────────────────────────────────────────
-- INDEXES on SALES (OLTP basic indexes)
-- ─────────────────────────────────────────
CREATE INDEX idx_sales_product  ON SALES(product_id);
CREATE INDEX idx_sales_location ON SALES(location_id);
CREATE INDEX idx_sales_date     ON SALES(sale_date);
CREATE INDEX idx_sales_customer ON SALES(customer_id);
