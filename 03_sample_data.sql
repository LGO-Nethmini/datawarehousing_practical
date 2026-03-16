-- ============================================================
-- STEP 3: SAMPLE DATA — OLTP Tables
-- ============================================================

-- ─────────────────────────────────────────
-- CUSTOMER DATA
-- ─────────────────────────────────────────
INSERT INTO CUSTOMER VALUES
(1,  'James',   'Smith',   'james.smith@email.com',   '9001111111', '12 Oak St',   'New York',   'NY', '10001', '2023-01-15'),
(2,  'Sarah',   'Johnson', 'sarah.j@email.com',       '9002222222', '34 Pine Ave', 'Los Angeles', 'CA', '90001', '2023-03-20'),
(3,  'Robert',  'Brown',   'rob.brown@email.com',     '9003333333', '56 Elm Rd',   'Chicago',    'IL', '60601', '2023-05-10'),
(4,  'Emily',   'Davis',   'emily.d@email.com',       '9004444444', '78 Maple Dr', 'Houston',    'TX', '77001', '2023-07-22'),
(5,  'Michael', 'Wilson',  'mike.w@email.com',        '9005555555', '90 Cedar Ln', 'Phoenix',    'AZ', '85001', '2023-09-05'),
(6,  'Jessica', 'Taylor',  'jess.t@email.com',        '9006666666', '11 Birch Ct', 'New York',   'NY', '10002', '2024-01-08'),
(7,  'David',   'Martinez','david.m@email.com',       '9007777777', '22 Walnut St','Los Angeles', 'CA', '90002', '2024-02-14'),
(8,  'Ashley',  'Anderson','ashley.a@email.com',      '9008888888', '33 Spruce Ave','Chicago',   'IL', '60602', '2024-04-19'),
(9,  'Daniel',  'Thomas',  'dan.t@email.com',         '9009999999', '44 Ash Blvd', 'Houston',    'TX', '77002', '2024-06-30'),
(10, 'Laura',   'Jackson', 'laura.j@email.com',       '9010000000', '55 Poplar Way','Phoenix',   'AZ', '85002', '2024-08-11');

-- ─────────────────────────────────────────
-- PRODUCT DATA
-- ─────────────────────────────────────────
INSERT INTO PRODUCT VALUES
(1,  'Laptop Pro 15',   'Electronics', 'TechBrand',  1200.00, 150, 101),
(2,  'Wireless Mouse',  'Accessories', 'ClickMaster',  25.00, 500, 102),
(3,  'USB-C Hub',       'Accessories', 'ConnectPro',   45.00, 300, 102),
(4,  'Monitor 27"',     'Electronics', 'ViewMax',     350.00, 100, 101),
(5,  'Mechanical Keyboard','Accessories','TypeKing',   90.00, 250, 103),
(6,  'Webcam HD',       'Electronics', 'ClearVision',  75.00, 200, 101),
(7,  'SSD 1TB',         'Storage',     'FastDrive',   110.00, 180, 104),
(8,  'RAM 16GB',        'Components',  'SpeedMem',     80.00, 220, 104),
(9,  'Gaming Chair',    'Furniture',   'ComfortZone', 320.00,  60, 105),
(10, 'Desk Lamp LED',   'Furniture',   'BrightLife',   35.00, 400, 105);

-- ─────────────────────────────────────────
-- LOCATION DATA
-- ─────────────────────────────────────────
INSERT INTO LOCATION VALUES
(1, 'NY Downtown Store',  '5th Ave',    'New York',    'NY', 'USA', 'East',  '10001'),
(2, 'LA Westside Store',  'Sunset Blvd','Los Angeles', 'CA', 'USA', 'West',  '90001'),
(3, 'Chicago North Store','Michigan Ave','Chicago',    'IL', 'USA', 'Central','60601'),
(4, 'Houston Main Store', 'Main St',    'Houston',     'TX', 'USA', 'South', '77001'),
(5, 'Phoenix East Store', 'Camelback Rd','Phoenix',    'AZ', 'USA', 'West',  '85001');

-- ─────────────────────────────────────────
-- SALES DATA (50 transaction records)
-- ─────────────────────────────────────────
INSERT INTO SALES (sale_id, customer_id, product_id, location_id, sale_date, quantity_sold, unit_price, payment_method) VALUES
(1,  1,  1, 1, '2025-01-05',  2, 1200.00, 'Credit Card'),
(2,  2,  2, 2, '2025-01-10',  5,   25.00, 'Cash'),
(3,  3,  3, 3, '2025-01-15',  3,   45.00, 'Debit Card'),
(4,  4,  4, 4, '2025-01-20',  1,  350.00, 'Credit Card'),
(5,  5,  5, 5, '2025-01-25',  2,   90.00, 'Cash'),
(6,  6,  1, 2, '2025-02-03',  1, 1200.00, 'Credit Card'),
(7,  7,  6, 1, '2025-02-08',  4,   75.00, 'Debit Card'),
(8,  8,  7, 3, '2025-02-14',  2,  110.00, 'Cash'),
(9,  9,  8, 4, '2025-02-20',  3,   80.00, 'Credit Card'),
(10, 10, 9, 5, '2025-02-25',  1,  320.00, 'Cash'),
(11, 1,  2, 1, '2025-03-01',  6,   25.00, 'Credit Card'),
(12, 2,  3, 2, '2025-03-06',  4,   45.00, 'Debit Card'),
(13, 3,  1, 3, '2025-03-12',  3, 1200.00, 'Credit Card'),
(14, 4,  4, 4, '2025-03-18',  2,  350.00, 'Cash'),
(15, 5,  5, 5, '2025-03-22',  5,   90.00, 'Debit Card'),
(16, 6,  6, 1, '2025-04-04',  2,   75.00, 'Credit Card'),
(17, 7,  7, 2, '2025-04-10',  3,  110.00, 'Cash'),
(18, 8,  8, 3, '2025-04-16',  4,   80.00, 'Credit Card'),
(19, 9,  9, 4, '2025-04-22',  1,  320.00, 'Debit Card'),
(20, 10,10, 5, '2025-04-28',  6,   35.00, 'Cash'),
(21, 1,  1, 1, '2025-05-03',  1, 1200.00, 'Credit Card'),
(22, 2,  4, 2, '2025-05-09',  2,  350.00, 'Debit Card'),
(23, 3,  5, 3, '2025-05-15',  3,   90.00, 'Cash'),
(24, 4,  6, 4, '2025-05-21',  4,   75.00, 'Credit Card'),
(25, 5,  7, 5, '2025-05-27',  2,  110.00, 'Cash'),
(26, 6,  8, 1, '2025-06-02',  5,   80.00, 'Debit Card'),
(27, 7,  9, 2, '2025-06-08',  1,  320.00, 'Credit Card'),
(28, 8, 10, 3, '2025-06-14',  8,   35.00, 'Cash'),
(29, 9,  2, 4, '2025-06-20',  6,   25.00, 'Credit Card'),
(30, 10, 3, 5, '2025-06-26',  4,   45.00, 'Debit Card'),
(31, 1,  1, 2, '2025-07-05',  2, 1200.00, 'Credit Card'),
(32, 2,  5, 3, '2025-07-11',  3,   90.00, 'Cash'),
(33, 3,  7, 4, '2025-07-17',  5,  110.00, 'Debit Card'),
(34, 4,  8, 5, '2025-07-23',  4,   80.00, 'Credit Card'),
(35, 5,  1, 1, '2025-08-01',  3, 1200.00, 'Cash'),
(36, 6,  4, 2, '2025-08-07',  1,  350.00, 'Credit Card'),
(37, 7,  6, 3, '2025-08-13',  6,   75.00, 'Debit Card'),
(38, 8,  9, 4, '2025-08-19',  2,  320.00, 'Cash'),
(39, 9, 10, 5, '2025-08-25',  7,   35.00, 'Credit Card'),
(40, 10, 2, 1, '2025-09-02',  5,   25.00, 'Debit Card'),
(41, 1,  3, 2, '2025-09-08',  4,   45.00, 'Cash'),
(42, 2,  1, 3, '2025-09-14',  2, 1200.00, 'Credit Card'),
(43, 3,  5, 4, '2025-09-20',  6,   90.00, 'Cash'),
(44, 4,  7, 5, '2025-09-26',  3,  110.00, 'Debit Card'),
(45, 5,  8, 1, '2025-10-04',  4,   80.00, 'Credit Card'),
(46, 6,  4, 2, '2025-10-10',  2,  350.00, 'Cash'),
(47, 7,  6, 3, '2025-10-16',  5,   75.00, 'Credit Card'),
(48, 8,  9, 4, '2025-10-22',  1,  320.00, 'Debit Card'),
(49, 9,  1, 5, '2025-11-01',  4, 1200.00, 'Credit Card'),
(50, 10, 2, 1, '2025-11-07',  8,   25.00, 'Cash');

-- ─────────────────────────────────────────────────────────────
-- STEP 3B: SAMPLE DATA — DWH Star Schema Tables
-- ─────────────────────────────────────────────────────────────

-- DIM_DATE (key format: YYYYMMDD)
INSERT INTO DIM_DATE VALUES
(20250105, '2025-01-05', 'Sunday',    5,  1, 1,  'January',  1, 2025, TRUE,  FALSE),
(20250110, '2025-01-10', 'Friday',   10,  2, 1,  'January',  1, 2025, FALSE, FALSE),
(20250115, '2025-01-15', 'Wednesday',15,  3, 1,  'January',  1, 2025, FALSE, FALSE),
(20250120, '2025-01-20', 'Monday',   20,  3, 1,  'January',  1, 2025, FALSE, FALSE),
(20250125, '2025-01-25', 'Saturday', 25,  4, 1,  'January',  1, 2025, TRUE,  FALSE),
(20250203, '2025-02-03', 'Monday',    3,  5, 2,  'February', 1, 2025, FALSE, FALSE),
(20250208, '2025-02-08', 'Saturday',  8,  6, 2,  'February', 1, 2025, TRUE,  FALSE),
(20250214, '2025-02-14', 'Friday',   14,  7, 2,  'February', 1, 2025, FALSE, TRUE),
(20250220, '2025-02-20', 'Thursday', 20,  8, 2,  'February', 1, 2025, FALSE, FALSE),
(20250225, '2025-02-25', 'Tuesday',  25,  8, 2,  'February', 1, 2025, FALSE, FALSE),
(20250301, '2025-03-01', 'Saturday',  1,  9, 3,  'March',    1, 2025, TRUE,  FALSE),
(20250306, '2025-03-06', 'Thursday',  6, 10, 3,  'March',    1, 2025, FALSE, FALSE),
(20250312, '2025-03-12', 'Wednesday',12, 11, 3,  'March',    1, 2025, FALSE, FALSE),
(20250318, '2025-03-18', 'Tuesday',  18, 12, 3,  'March',    1, 2025, FALSE, FALSE),
(20250322, '2025-03-22', 'Saturday', 22, 12, 3,  'March',    1, 2025, TRUE,  FALSE),
(20250404, '2025-04-04', 'Friday',    4, 14, 4,  'April',    2, 2025, FALSE, FALSE),
(20250410, '2025-04-10', 'Thursday', 10, 15, 4,  'April',    2, 2025, FALSE, FALSE),
(20250416, '2025-04-16', 'Wednesday',16, 16, 4,  'April',    2, 2025, FALSE, FALSE),
(20250422, '2025-04-22', 'Tuesday',  22, 17, 4,  'April',    2, 2025, FALSE, FALSE),
(20250428, '2025-04-28', 'Monday',   28, 18, 4,  'April',    2, 2025, FALSE, FALSE),
(20250503, '2025-05-03', 'Saturday',  3, 18, 5,  'May',      2, 2025, TRUE,  FALSE),
(20250509, '2025-05-09', 'Friday',    9, 19, 5,  'May',      2, 2025, FALSE, FALSE),
(20250515, '2025-05-15', 'Thursday', 15, 20, 5,  'May',      2, 2025, FALSE, FALSE),
(20250521, '2025-05-21', 'Wednesday',21, 21, 5,  'May',      2, 2025, FALSE, FALSE),
(20250527, '2025-05-27', 'Tuesday',  27, 22, 5,  'May',      2, 2025, FALSE, FALSE),
(20250602, '2025-06-02', 'Monday',    2, 23, 6,  'June',     2, 2025, FALSE, FALSE),
(20250608, '2025-06-08', 'Sunday',    8, 23, 6,  'June',     2, 2025, TRUE,  FALSE),
(20250614, '2025-06-14', 'Saturday', 14, 24, 6,  'June',     2, 2025, TRUE,  FALSE),
(20250620, '2025-06-20', 'Friday',   20, 25, 6,  'June',     2, 2025, FALSE, FALSE),
(20250626, '2025-06-26', 'Thursday', 26, 26, 6,  'June',     2, 2025, FALSE, FALSE),
(20250705, '2025-07-05', 'Saturday',  5, 27, 7,  'July',     3, 2025, TRUE,  FALSE),
(20250711, '2025-07-11', 'Friday',   11, 28, 7,  'July',     3, 2025, FALSE, FALSE),
(20250717, '2025-07-17', 'Thursday', 17, 29, 7,  'July',     3, 2025, FALSE, FALSE),
(20250723, '2025-07-23', 'Wednesday',23, 30, 7,  'July',     3, 2025, FALSE, FALSE),
(20250801, '2025-08-01', 'Friday',    1, 31, 8,  'August',   3, 2025, FALSE, FALSE),
(20250807, '2025-08-07', 'Thursday',  7, 32, 8,  'August',   3, 2025, FALSE, FALSE),
(20250813, '2025-08-13', 'Wednesday',13, 33, 8,  'August',   3, 2025, FALSE, FALSE),
(20250819, '2025-08-19', 'Tuesday',  19, 34, 8,  'August',   3, 2025, FALSE, FALSE),
(20250825, '2025-08-25', 'Monday',   25, 35, 8,  'August',   3, 2025, FALSE, FALSE),
(20250902, '2025-09-02', 'Tuesday',   2, 36, 9,  'September',3, 2025, FALSE, FALSE),
(20250908, '2025-09-08', 'Monday',    8, 37, 9,  'September',3, 2025, FALSE, FALSE),
(20250914, '2025-09-14', 'Sunday',   14, 37, 9,  'September',3, 2025, TRUE,  FALSE),
(20250920, '2025-09-20', 'Saturday', 20, 38, 9,  'September',3, 2025, TRUE,  FALSE),
(20250926, '2025-09-26', 'Friday',   26, 39, 9,  'September',3, 2025, FALSE, FALSE),
(20251004, '2025-10-04', 'Saturday',  4, 40, 10, 'October',  4, 2025, TRUE,  FALSE),
(20251010, '2025-10-10', 'Friday',   10, 41, 10, 'October',  4, 2025, FALSE, FALSE),
(20251016, '2025-10-16', 'Thursday', 16, 42, 10, 'October',  4, 2025, FALSE, FALSE),
(20251022, '2025-10-22', 'Wednesday',22, 43, 10, 'October',  4, 2025, FALSE, FALSE),
(20251101, '2025-11-01', 'Saturday',  1, 44, 11, 'November', 4, 2025, TRUE,  FALSE),
(20251107, '2025-11-07', 'Friday',    7, 45, 11, 'November', 4, 2025, FALSE, FALSE);

-- DIM_CUSTOMER
INSERT INTO DIM_CUSTOMER VALUES
(1,  1,  'James Smith',    'james.smith@email.com', 'New York',    'NY', '10001', 'Premium'),
(2,  2,  'Sarah Johnson',  'sarah.j@email.com',     'Los Angeles', 'CA', '90001', 'Regular'),
(3,  3,  'Robert Brown',   'rob.brown@email.com',   'Chicago',     'IL', '60601', 'Regular'),
(4,  4,  'Emily Davis',    'emily.d@email.com',     'Houston',     'TX', '77001', 'Premium'),
(5,  5,  'Michael Wilson', 'mike.w@email.com',      'Phoenix',     'AZ', '85001', 'Regular'),
(6,  6,  'Jessica Taylor', 'jess.t@email.com',      'New York',    'NY', '10002', 'New'),
(7,  7,  'David Martinez', 'david.m@email.com',     'Los Angeles', 'CA', '90002', 'Regular'),
(8,  8,  'Ashley Anderson','ashley.a@email.com',    'Chicago',     'IL', '60602', 'New'),
(9,  9,  'Daniel Thomas',  'dan.t@email.com',       'Houston',     'TX', '77002', 'Regular'),
(10, 10, 'Laura Jackson',  'laura.j@email.com',     'Phoenix',     'AZ', '85002', 'Premium');

-- DIM_PRODUCT
INSERT INTO DIM_PRODUCT VALUES
(1,  1,  'Laptop Pro 15',     'Electronics', 'Computers',  'TechBrand',   1200.00),
(2,  2,  'Wireless Mouse',    'Accessories', 'Peripherals','ClickMaster',    25.00),
(3,  3,  'USB-C Hub',         'Accessories', 'Connectivity','ConnectPro',    45.00),
(4,  4,  'Monitor 27"',       'Electronics', 'Displays',   'ViewMax',       350.00),
(5,  5,  'Mechanical Keyboard','Accessories','Peripherals','TypeKing',        90.00),
(6,  6,  'Webcam HD',         'Electronics', 'Cameras',    'ClearVision',    75.00),
(7,  7,  'SSD 1TB',           'Storage',     'Drives',     'FastDrive',     110.00),
(8,  8,  'RAM 16GB',          'Components',  'Memory',     'SpeedMem',       80.00),
(9,  9,  'Gaming Chair',      'Furniture',   'Seating',    'ComfortZone',   320.00),
(10,10,  'Desk Lamp LED',     'Furniture',   'Lighting',   'BrightLife',     35.00);

-- DIM_LOCATION
INSERT INTO DIM_LOCATION VALUES
(1, 1, 'NY Downtown Store',   'New York',    'NY', 'USA', 'East'),
(2, 2, 'LA Westside Store',   'Los Angeles', 'CA', 'USA', 'West'),
(3, 3, 'Chicago North Store', 'Chicago',     'IL', 'USA', 'Central'),
(4, 4, 'Houston Main Store',  'Houston',     'TX', 'USA', 'South'),
(5, 5, 'Phoenix East Store',  'Phoenix',     'AZ', 'USA', 'West');

-- FACT_SALES (loaded from OLTP SALES)
INSERT INTO FACT_SALES (date_key, customer_key, product_key, location_key, sale_id, quantity_sold, unit_price, total_amount, discount_amount, net_revenue)
VALUES
(20250105, 1,  1, 1, 1,   2, 1200.00,  2400.00, 0.00,  2400.00),
(20250110, 2,  2, 2, 2,   5,   25.00,   125.00, 0.00,   125.00),
(20250115, 3,  3, 3, 3,   3,   45.00,   135.00, 0.00,   135.00),
(20250120, 4,  4, 4, 4,   1,  350.00,   350.00, 0.00,   350.00),
(20250125, 5,  5, 5, 5,   2,   90.00,   180.00, 0.00,   180.00),
(20250203, 6,  1, 2, 6,   1, 1200.00,  1200.00, 50.00, 1150.00),
(20250208, 7,  6, 1, 7,   4,   75.00,   300.00, 0.00,   300.00),
(20250214, 8,  7, 3, 8,   2,  110.00,   220.00, 0.00,   220.00),
(20250220, 9,  8, 4, 9,   3,   80.00,   240.00, 0.00,   240.00),
(20250225,10,  9, 5,10,   1,  320.00,   320.00, 0.00,   320.00),
(20250301, 1,  2, 1,11,   6,   25.00,   150.00, 0.00,   150.00),
(20250306, 2,  3, 2,12,   4,   45.00,   180.00, 0.00,   180.00),
(20250312, 3,  1, 3,13,   3, 1200.00,  3600.00,100.00, 3500.00),
(20250318, 4,  4, 4,14,   2,  350.00,   700.00, 0.00,   700.00),
(20250322, 5,  5, 5,15,   5,   90.00,   450.00, 0.00,   450.00),
(20250404, 6,  6, 1,16,   2,   75.00,   150.00, 0.00,   150.00),
(20250410, 7,  7, 2,17,   3,  110.00,   330.00, 0.00,   330.00),
(20250416, 8,  8, 3,18,   4,   80.00,   320.00, 0.00,   320.00),
(20250422, 9,  9, 4,19,   1,  320.00,   320.00, 0.00,   320.00),
(20250428,10, 10, 5,20,   6,   35.00,   210.00, 0.00,   210.00),
(20250503, 1,  1, 1,21,   1, 1200.00,  1200.00,  0.00, 1200.00),
(20250509, 2,  4, 2,22,   2,  350.00,   700.00,  0.00,  700.00),
(20250515, 3,  5, 3,23,   3,   90.00,   270.00,  0.00,  270.00),
(20250521, 4,  6, 4,24,   4,   75.00,   300.00,  0.00,  300.00),
(20250527, 5,  7, 5,25,   2,  110.00,   220.00,  0.00,  220.00),
(20250602, 6,  8, 1,26,   5,   80.00,   400.00,  0.00,  400.00),
(20250608, 7,  9, 2,27,   1,  320.00,   320.00,  0.00,  320.00),
(20250614, 8, 10, 3,28,   8,   35.00,   280.00,  0.00,  280.00),
(20250620, 9,  2, 4,29,   6,   25.00,   150.00,  0.00,  150.00),
(20250626,10,  3, 5,30,   4,   45.00,   180.00,  0.00,  180.00),
(20250705, 1,  1, 2,31,   2, 1200.00,  2400.00, 75.00, 2325.00),
(20250711, 2,  5, 3,32,   3,   90.00,   270.00,  0.00,  270.00),
(20250717, 3,  7, 4,33,   5,  110.00,   550.00,  0.00,  550.00),
(20250723, 4,  8, 5,34,   4,   80.00,   320.00,  0.00,  320.00),
(20250801, 5,  1, 1,35,   3, 1200.00,  3600.00,  0.00, 3600.00),
(20250807, 6,  4, 2,36,   1,  350.00,   350.00,  0.00,  350.00),
(20250813, 7,  6, 3,37,   6,   75.00,   450.00,  0.00,  450.00),
(20250819, 8,  9, 4,38,   2,  320.00,   640.00, 20.00,  620.00),
(20250825, 9, 10, 5,39,   7,   35.00,   245.00,  0.00,  245.00),
(20250902,10,  2, 1,40,   5,   25.00,   125.00,  0.00,  125.00),
(20250908, 1,  3, 2,41,   4,   45.00,   180.00,  0.00,  180.00),
(20250914, 2,  1, 3,42,   2, 1200.00,  2400.00, 50.00, 2350.00),
(20250920, 3,  5, 4,43,   6,   90.00,   540.00,  0.00,  540.00),
(20250926, 4,  7, 5,44,   3,  110.00,   330.00,  0.00,  330.00),
(20251004, 5,  8, 1,45,   4,   80.00,   320.00,  0.00,  320.00),
(20251010, 6,  4, 2,46,   2,  350.00,   700.00,  0.00,  700.00),
(20251016, 7,  6, 3,47,   5,   75.00,   375.00,  0.00,  375.00),
(20251022, 8,  9, 4,48,   1,  320.00,   320.00, 10.00,  310.00),
(20251101, 9,  1, 5,49,   4, 1200.00,  4800.00,  0.00, 4800.00),
(20251107,10,  2, 1,50,   8,   25.00,   200.00,  0.00,  200.00);
