CREATE DATABASE globalstore;

USE globalstore;

CREATE TABLE transaksi (
	order_id			INT,
    customer_name		VARCHAR(100),
    product_category	VARCHAR(50),
    product_name		VARCHAR(100),
    order_date			DATE,
    quantity			INT,
    unit_price			DECIMAL(10,2),
    status				VARCHAR(20),
    country				VARCHAR(50),
    payment_method		VARCHAR(50)
);

SELECT * FROM transaksi;

CREATE TABLE cost_per_unit (
	product_number		INT PRIMARY KEY,
    product_name		VARCHAR(50),
    cost_percentage		DECIMAL(5,4)
);

SELECT * FROM cost_per_unit;

-- Data Inspection (Pemeriksaan awal kualitas data)

-- Menghitung total jumlah transaksi
SELECT COUNT(*) AS total_transaksi FROM transaksi; 

-- Menghitung jumlah customer yang unik
SELECT COUNT(DISTINCT customer_name) FROM transaksi; 

-- Menampilkan daftar kategori produk yang tersedia
SELECT DISTINCT product_category FROM transaksi; 

-- Menampilkan daftar produk unik yang tersedia
SELECT DISTINCT product_name FROM transaksi; 

-- Menentukan rentang tanggal transaksi (tanggal paling awal & paling akhir)
SELECT
	MIN(order_date) AS min,
    MAX(order_date) AS max
FROM transaksi;

-- Menentukan nilai minimum, maksimum, dan rata-rata kuantitas barang yang dibeli
SELECT 
	MIN(quantity),
    MAX(quantity),
    AVG(quantity)
FROM transaksi;

-- Menentukan nilai minimum, maksimum, dan rata-rata harga barang
SELECT 
	MIN(unit_price),
    MAX(unit_price),
    AVG(unit_price)
FROM transaksi;

-- Menampilkan daftar status transaksi yang unik
SELECT DISTINCT status FROM transaksi; 

-- Menampilkan daftar negara yang unik
SELECT DISTINCT country FROM transaksi; 

-- Menampilkan daftar metode pembayaran yang unik
SELECT DISTINCT payment_method FROM transaksi; 

-- Melihat isi tabel cost_per_unit (asumsi tabel referensi biaya per unit)
SELECT * FROM cost_per_unit;

-- Mengecek apakah ada baris data yang benar-benar duplikat pada kolom transaksi
WITH check_duplicate AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY order_id, customer_name, product_category, product_name, 
                         order_date, quantity, unit_price, status, country, payment_method
		) AS duplicate
	FROM transaksi
)
SELECT
	*
FROM check_duplicate
WHERE duplicate > 1;

-- Mengecek apakah ada nilai kosong (NULL atau blank) maupun nilai yang tidak valid pada table transaksi
SELECT
	* 
FROM transaksi
WHERE
	order_id IS NULL OR
    customer_name IS NULL OR customer_name = '' OR
	product_category IS NULL OR product_category = '' OR
	product_name IS NULL OR product_name = '' OR
    order_date IS NULL OR
    quantity IS NULL OR quantity <= 0  OR
	unit_price IS NULL OR unit_price <= 0  OR
    status IS NULL OR status = '' OR
    country IS NULL OR country = '' OR
    payment_method IS NULL OR payment_method = '' ;
    
-- Mengecek jumlah data dan data product apa saja yang tersedia pada table cost_per_unit
SELECT product_name FROM cost_per_unit;   
SELECT COUNT(DISTINCT product_name) FROM cost_per_unit;     

-- Menentukan nilai minimum, maksimum, dan rata-rata cost percentage
SELECT 
	MIN(cost_percentage),
    MAX(cost_percentage),
    AVG(cost_percentage)
FROM cost_per_unit;

-- Mengecek apakah ada baris data yang benar-benar duplikat pada cost_per_unit
WITH check_duplicate AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY product_number, product_name, cost_percentage
		) AS duplicate
	FROM cost_per_unit
)
SELECT
	*
FROM check_duplicate
WHERE duplicate > 1;

-- Mengecek apakah ada nilai kosong (NULL atau blank) maupun nilai yang tidak valid pada table cost_per_unit
SELECT
	* 
FROM cost_per_unit
WHERE
	product_number IS NULL OR
	product_name IS NULL OR product_name = '' OR
    cost_percentage IS NULL OR cost_percentage >= 1 ;
    

-- BERDASARKAN DATA INSPECTION DITEMUKAN DUPLICATE VALUE (ORDER ID 16) DAN DATA DENGAN NILAI NULL (ORDER ID 36) PADA TABLE TRANSAKSI

-- Data Cleansing
CREATE TABLE transaksi_cleaned (
	order_id			INT,
    customer_name		VARCHAR(100),
    product_category	VARCHAR(50),
    product_name		VARCHAR(100),
    order_date			DATE,
    quantity			INT,
    unit_price			DECIMAL(10,2),
    status				VARCHAR(20),
    country				VARCHAR(50),
    payment_method		VARCHAR(50),
    duplicate_value		INT
);

-- Membuat Table Untuk Proses Data Cleansing 
INSERT INTO transaksi_cleaned
WITH check_duplicate AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY order_id, customer_name, product_category, product_name, 
                         order_date, quantity, unit_price, status, country, payment_method
		) AS duplicate
	FROM transaksi
)
SELECT
	*
FROM check_duplicate;

-- Hapus data duplicat
DELETE FROM transaksi_cleaned WHERE duplicate_value > 1; 

-- Hapus Null Value
DELETE FROM transaksi_cleaned
WHERE
	order_id IS NULL OR
    customer_name IS NULL OR customer_name = '' OR
	product_category IS NULL OR product_category = '' OR
	product_name IS NULL OR product_name = '' OR
    order_date IS NULL OR
    quantity IS NULL OR quantity <= 0  OR
	unit_price IS NULL OR unit_price <= 0  OR
    status IS NULL OR status = '' OR
    country IS NULL OR country = '' OR
    payment_method IS NULL OR payment_method = '' ;

SELECT * FROM transaksi_cleaned;
ALTER TABLE transaksi_cleaned DROP COLUMN duplicate_value;

-- FEATURE ENGINERING 
CREATE TABLE feature_enginering (
	order_id			INT,
    customer_name		VARCHAR(100),
    product_category	VARCHAR(50),
    product_name		VARCHAR(100),
    order_date			DATE,
    quantity			INT,
    unit_price			DECIMAL(10,2),
    status				VARCHAR(20),
    country				VARCHAR(50),
    payment_method		VARCHAR(50)
);

INSERT INTO feature_enginering
SELECT * FROM transaksi_cleaned;

SELECT * FROM feature_enginering;

-- Ektraksi bulan dan tahun
ALTER TABLE feature_enginering
ADD COLUMN year INT;
UPDATE feature_enginering
SET year = YEAR(order_date);

ALTER TABLE feature_enginering
ADD COLUMN month INT;
UPDATE feature_enginering
SET month = MONTH(order_date);

SELECT * FROM feature_enginering;

-- Menambah Kolom baru

-- Menambah kolom cost percentage 
ALTER TABLE feature_enginering
ADD COLUMN cost_percentage DECIMAL (5,4);

UPDATE feature_enginering AS fe
LEFT JOIN cost_per_unit AS cpu
ON fe.product_name = cpu.product_name
SET fe.cost_percentage = cpu.cost_percentage;

-- Menambah kolom clustering price
ALTER TABLE feature_enginering
ADD COLUMN kategori_unit_price VARCHAR(20);

UPDATE feature_enginering
SET kategori_unit_price = CASE 
    WHEN unit_price <= 200 THEN 'Low'
    WHEN unit_price > 200 AND unit_price <= 400 THEN 'Lower Mid'
    WHEN unit_price > 400 AND unit_price <= 600 THEN 'Mid'
    WHEN unit_price > 600 AND unit_price <= 800 THEN 'Upper Mid'
    WHEN unit_price > 800 AND unit_price <= 1000 THEN 'High'
    ELSE 'Error'
END;

-- Menambah kolom revenue
ALTER TABLE feature_enginering
ADD COLUMN revenue DECIMAL (10,2);

UPDATE feature_enginering
SET revenue = quantity * unit_price;

-- Menambah kolom cost_per_unit
ALTER TABLE feature_enginering
ADD COLUMN cost_per_unit DECIMAL (10,2);

UPDATE feature_enginering
SET cost_per_unit = cost_percentage * unit_price;

-- Menambah kolom total_cost
ALTER TABLE feature_enginering
ADD COLUMN total_cost DECIMAL (10,2);

UPDATE feature_enginering
SET total_cost = quantity * cost_per_unit; 

-- Menambah kolom total_profit
ALTER TABLE feature_enginering
ADD COLUMN total_profit DECIMAL (10,2);

UPDATE feature_enginering
SET total_profit = revenue - total_cost; 

SELECT * FROM feature_enginering;


-- EXPLORASI DATA

CREATE TABLE `final_table` (
  `order_id` int DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `product_category` varchar(50) DEFAULT NULL,
  `product_name` varchar(100) DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `unit_price` decimal(10,2) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `year` INT DEFAULT NULL,
  `month` INT DEFAULT NULL,
  `cost_percentage` decimal(5,4) DEFAULT NULL,
  `kategori_unit_price` varchar(20) DEFAULT NULL,
  `revenue` decimal(10,2) DEFAULT NULL,
  `cost_per_unit` decimal(10,2) DEFAULT NULL,
  `total_cost` decimal(10,2) DEFAULT NULL,
  `total_profit` decimal(10,2) DEFAULT NULL
);
INSERT INTO final_table
SELECT * FROM feature_enginering;

-- General 
SELECT
	COUNT(DISTINCT order_id) AS total_transaksi,
    COUNT(DISTINCT customer_name) AS total_pelanggan_unik,
    SUM(quantity) AS total_produk_terjual,
    SUM(revenue) AS total_revenue,
    SUM(total_profit) AS total_profit,
    (SUM(total_profit) / SUM(revenue)) * 100 AS margin_ratio,
    SUM(revenue) / COUNT(order_id) AS aov
FROM final_table;

-- Time base
SELECT
	year,
    SUM(revenue) AS total_revenue,
    SUM(total_profit) AS total_profit,
    AVG(revenue) AS avg_revenue,
    AVG(total_profit) AS avg_profit,
    (SUM(total_profit) / SUM(revenue)) * 100 AS margin_ratio
FROM final_table
GROUP BY year;

SELECT
	year,
    month,
    SUM(revenue) AS total_revenue,
    SUM(total_profit) AS total_profit,
    (SUM(total_profit) / SUM(revenue)) * 100 AS margin_ratio
FROM final_table
GROUP BY year, month
ORDER BY year ASC, month ASC;

-- Price Segmentation
SELECT 
	kategori_unit_price,
    SUM(revenue) AS total_revenue,
    SUM(total_profit) AS total_profit,
    SUM(quantity) AS total_terjual,
    (SUM(total_profit) / SUM(revenue)) * 100 AS margin_ratio
FROM final_table
GROUP BY kategori_unit_price;

-- Product & category performance
 SELECT 
	product_category,
    SUM(revenue) AS total_revenue,
    SUM(total_profit) AS total_profit,
    SUM(quantity) AS total_terjual,
    (SUM(total_profit) / SUM(revenue)) * 100 AS margin_ratio
FROM final_table
GROUP BY product_category;

 SELECT 
	product_name,
    SUM(revenue) AS total_revenue,
    SUM(total_profit) AS total_profit,
    SUM(quantity) AS total_terjual,
    (SUM(total_profit) / SUM(revenue)) * 100 AS margin_ratio
FROM final_table
GROUP BY product_name ORDER BY 2 DESC LIMIT 10;

-- Payment Method & Country
 SELECT 
	payment_method,
    SUM(revenue) AS total_revenue,
    COUNT(payment_method)
FROM final_table
GROUP BY payment_method ORDER BY 2 DESC; 

 SELECT 
	country,
    SUM(revenue) AS total_revenue,
    COUNT(country)
FROM final_table
GROUP BY country ORDER BY 2 DESC; 


-- Returned vs completed
SELECT 
	status,
    SUM(revenue) AS total_revenue,
    SUM(total_profit) AS total_profit,
    SUM(quantity) AS total_terjual
FROM final_table
GROUP BY status;

SELECT
	SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) AS returned_revenue,
    SUM(revenue) AS total_revenue,
    (SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) / SUM(revenue) ) * 100 AS return_rate_ratio
FROM final_table;


-- Category
SELECT
	product_category,
    COUNT(CASE WHEN status = 'Returned' THEN order_id END) AS returned_transaction,
    COUNT(order_id) AS total_transaction,
    (COUNT(CASE WHEN status = 'Returned' THEN order_id END) / COUNT(order_id)) * 100 AS return_rate_transaction,
	SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) AS returned_revenue,
    SUM(revenue) AS total_revenue,
    (SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) / SUM(revenue) ) * 100 AS return_rate_ratio_revenue,
    SUM(CASE WHEN status = 'Returned' THEN total_profit ELSE 0 END) AS returned_profit,
    SUM(total_profit) AS total_profit,
    (SUM(CASE WHEN status = 'Returned' THEN total_profit ELSE 0 END) / SUM(total_profit) ) * 100 AS return_rate_ratio_profit
FROM final_table
GROUP BY product_category;

-- Country 
SELECT
	country,
    COUNT(CASE WHEN status = 'Returned' THEN order_id END) AS returned_transaction,
    COUNT(order_id) AS total_transaction,
    (COUNT(CASE WHEN status = 'Returned' THEN order_id END) / COUNT(order_id)) * 100 AS return_rate_transaction,
	SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) AS returned_revenue,
    SUM(revenue) AS total_revenue,
    (SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) / SUM(revenue) ) * 100 AS return_rate_ratio_revenue,
    SUM(CASE WHEN status = 'Returned' THEN total_profit ELSE 0 END) AS returned_profit,
    SUM(total_profit) AS total_profit,
    (SUM(CASE WHEN status = 'Returned' THEN total_profit ELSE 0 END) / SUM(total_profit) ) * 100 AS return_rate_ratio_profit
FROM final_table
GROUP BY country;

-- Unit Price Segmentation
SELECT
	kategori_unit_price,
    COUNT(CASE WHEN status = 'Returned' THEN order_id END) AS returned_transaction,
    COUNT(order_id) AS total_transaction,
    (COUNT(CASE WHEN status = 'Returned' THEN order_id END) / COUNT(order_id)) * 100 AS return_rate_transaction,
	SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) AS returned_revenue,
    SUM(revenue) AS total_revenue,
    (SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) / SUM(revenue) ) * 100 AS return_rate_ratio_revenue,
    SUM(CASE WHEN status = 'Returned' THEN total_profit ELSE 0 END) AS returned_profit,
    SUM(total_profit) AS total_profit,
    (SUM(CASE WHEN status = 'Returned' THEN total_profit ELSE 0 END) / SUM(total_profit) ) * 100 AS return_rate_ratio_profit
FROM final_table
GROUP BY kategori_unit_price;

-- Time 
SELECT
	year,
    month,
    COUNT(CASE WHEN status = 'Returned' THEN order_id END) AS returned_transaction,
    COUNT(order_id) AS total_transaction,
    (COUNT(CASE WHEN status = 'Returned' THEN order_id END) / COUNT(order_id)) * 100 AS return_rate_transaction,
	SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) AS returned_revenue,
    SUM(revenue) AS total_revenue,
    (SUM(CASE WHEN status = 'Returned' THEN revenue ELSE 0 END) / SUM(revenue) ) * 100 AS return_rate_ratio_revenue,
    SUM(CASE WHEN status = 'Returned' THEN total_profit ELSE 0 END) AS returned_profit,
    SUM(total_profit) AS total_profit,
    (SUM(CASE WHEN status = 'Returned' THEN total_profit ELSE 0 END) / SUM(total_profit) ) * 100 AS return_rate_ratio_profit
FROM final_table
GROUP BY year, month
ORDER BY year ASC, month ASC;


	


	













