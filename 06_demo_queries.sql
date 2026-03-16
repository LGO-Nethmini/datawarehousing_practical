USE datawarehousing_practical;

-- Verify row counts
SELECT COUNT(*) AS sales_rows FROM sales;
SELECT COUNT(*) AS fact_sales_rows FROM fact_sales;

-- View all OLTP tables
SELECT * FROM customer;
SELECT * FROM product;
SELECT * FROM location;
SELECT * FROM sales;

-- View all DWH tables
SELECT * FROM dim_date;
SELECT * FROM dim_customer;
SELECT * FROM dim_product;
SELECT * FROM dim_location;
SELECT * FROM fact_sales;

-- Assignment Query 1:
-- Sales for a given product by location over a period of time
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
ORDER BY dd.year, dl.city;

-- Assignment Query 2:
-- Maximum number of sales for a given product over time for a given location
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
