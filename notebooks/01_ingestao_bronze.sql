-- Databricks notebook source
CREATE OR REPLACE TABLE ecommerce_mvp.bronze.orders AS
SELECT * FROM read_files('/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/olist_orders_dataset.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE ecommerce_mvp.bronze.order_items AS
SELECT * FROM read_files('/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/olist_order_items_dataset.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE ecommerce_mvp.bronze.order_payments AS
SELECT * FROM read_files('/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/olist_order_payments_dataset.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE ecommerce_mvp.bronze.order_reviews AS
SELECT * FROM read_files(
  '/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/olist_order_reviews_dataset.csv',
  format => 'csv',
  header => true,
  inferSchema => true,
  multiLine => true,
  quote => '"',
  escape => '"'
);

CREATE OR REPLACE TABLE ecommerce_mvp.bronze.customers AS
SELECT * FROM read_files('/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/olist_customers_dataset.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE ecommerce_mvp.bronze.products AS
SELECT * FROM read_files('/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/olist_products_dataset.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE ecommerce_mvp.bronze.sellers AS
SELECT * FROM read_files('/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/olist_sellers_dataset.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE ecommerce_mvp.bronze.geolocation AS
SELECT * FROM read_files('/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/olist_geolocation_dataset.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE ecommerce_mvp.bronze.product_category_name_translation AS
SELECT * FROM read_files('/Volumes/ecommerce_mvp/bronze/raw_files_csvs/archive (4)/product_category_name_translation.csv', format => 'csv', header => true, inferSchema => true);

-- COMMAND ----------

SHOW TABLES IN ecommerce_mvp.bronze;

-- COMMAND ----------

SELECT review_score, COUNT(*) 
FROM ecommerce_mvp.bronze.order_reviews 
GROUP BY review_score 
ORDER BY review_score;

-- COMMAND ----------

