/* ===========================================================================
   BRONZE LOAD (MySQL)  -  CSV -> bronze tables
   ---------------------------------------------------------------------------
   MySQL mein LOAD DATA stored procedure ke andar allowed nahi hai (Error 1314),
   isliye ye plain script hai. Poori file ek baar run karo (Ctrl+A -> Execute).
   Path apne Uploads folder ke hisaab se rakho (secure_file_priv wala folder).
   NOTE: ERP tables ke column names assume kiye hain: DESCRIBE se match kar lena.
   =========================================================================== */
USE bronze;
SET @batch_start = NOW();
SELECT '================ Loading Bronze Layer ================' AS msg;

-- ------------------------------ CRM ---------------------------------------
-- 1) crm_cust_info
SET @t = NOW();
TRUNCATE TABLE crm_cust_info;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@id, cust_key, cust_firstname, cust_lastname, cust_material_status, cust_gndr, @d)
SET cust_id          = NULLIF(TRIM(@id), ''),
    cust_create_data = STR_TO_DATE(NULLIF(TRIM(@d), ''), '%d-%m-%Y');
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS rows_loaded,
       TIMESTAMPDIFF(SECOND, @t, NOW()) AS seconds_taken FROM crm_cust_info;

-- 2) crm_prd_info
SET @t = NOW();
TRUNCATE TABLE crm_prd_info;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE crm_prd_info
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, prd_key, Prd_nm, @cost, prd_line, @sd, @ed)
SET prd_id       = NULLIF(TRIM(REPLACE(@id,   '\r', '')), ''),
    prd_cost     = NULLIF(TRIM(REPLACE(@cost, '\r', '')), ''),
    prd_start_dt = STR_TO_DATE(NULLIF(TRIM(REPLACE(@sd, '\r', '')), ''), '%d-%m-%Y'),
    prd_end_dt   = STR_TO_DATE(NULLIF(TRIM(REPLACE(@ed, '\r', '')), ''), '%d-%m-%Y');
SELECT 'crm_prd_info' AS table_name, COUNT(*) AS rows_loaded,
       TIMESTAMPDIFF(SECOND, @t, NOW()) AS seconds_taken FROM crm_prd_info;

-- 3) crm_sales_details
SET @t = NOW();
TRUNCATE TABLE crm_sales_details;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE crm_sales_details
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(sls_ord_num, slr_prd_key, @cust, @od, @sd, @dd, @sales, @qty, @price)
SET sls_cust_id  = NULLIF(TRIM(@cust), ''),
    sls_order_dt = NULLIF(TRIM(@od), ''),
    sls_ship_dt  = NULLIF(TRIM(@sd), ''),
    sls_due_dt   = NULLIF(TRIM(@dd), ''),
    sls_sales    = NULLIF(TRIM(@sales), ''),
    sls_quantity = NULLIF(TRIM(@qty), ''),
    sls_price    = NULLIF(TRIM(@price), '');
SELECT 'crm_sales_details' AS table_name, COUNT(*) AS rows_loaded,
       TIMESTAMPDIFF(SECOND, @t, NOW()) AS seconds_taken FROM crm_sales_details;

-- ------------------------------ ERP ---------------------------------------
-- 4) erp_loc_a101   (cid, cntry)
SET @t = NOW();
TRUNCATE TABLE erp_loc_a101;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loc_a101.csv'
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(cid, @cntry)
SET cntry = NULLIF(TRIM(REPLACE(@cntry, '\r', '')), '');
SELECT 'erp_loc_a101' AS table_name, COUNT(*) AS rows_loaded,
       TIMESTAMPDIFF(SECOND, @t, NOW()) AS seconds_taken FROM erp_loc_a101;

-- 5) erp_cust_az12  (cid, bdate, gen)
SET @t = NOW();
TRUNCATE TABLE erp_cust_az12;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_az12.csv'
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(cid, @bd, @gen)
SET bdate = NULLIF(TRIM(@bd), ''),            -- agar dd-mm-yyyy ho to STR_TO_DATE(..., '%d-%m-%Y') lagao
    gen   = NULLIF(TRIM(REPLACE(@gen, '\r', '')), '');
SELECT 'erp_cust_az12' AS table_name, COUNT(*) AS rows_loaded,
       TIMESTAMPDIFF(SECOND, @t, NOW()) AS seconds_taken FROM erp_cust_az12;

-- 6) erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SET @t = NOW();
TRUNCATE TABLE erp_px_cat_g1v2;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/px_cat_g1v2.csv'
INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, cat, subcat, @m)
SET maintenance = NULLIF(TRIM(REPLACE(@m, '\r', '')), '');
SELECT 'erp_px_cat_g1v2' AS table_name, COUNT(*) AS rows_loaded,
       TIMESTAMPDIFF(SECOND, @t, NOW()) AS seconds_taken FROM erp_px_cat_g1v2;

SELECT CONCAT('Bronze load complete. Total time: ',
              TIMESTAMPDIFF(SECOND, @batch_start, NOW()), ' sec') AS msg;
