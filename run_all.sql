CREATE DATABASE IF NOT EXISTS datawarehousing_practical;
USE datawarehousing_practical;

SOURCE 01_OLTP_schema.sql;
SOURCE 02_StarSchema_DWH.sql;
SOURCE 03_sample_data.sql;
SOURCE 04_query_comparison.sql;
SOURCE 05_performance_summary.sql;

SELECT 'SALES rows' AS metric, COUNT(*) AS value FROM SALES
UNION ALL
SELECT 'FACT_SALES rows' AS metric, COUNT(*) AS value FROM FACT_SALES;
