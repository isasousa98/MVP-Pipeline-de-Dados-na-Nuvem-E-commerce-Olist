-- Databricks notebook source
CREATE SCHEMA IF NOT EXISTS ecommerce_mvp.silver;

-- Reviews: corrige tipo e remove duplicatas (pode haver mais de uma review por order_id)

CREATE OR REPLACE TABLE ecommerce_mvp.silver.order_reviews_agg AS
SELECT 
  order_id,
  ROUND(AVG(review_score)) AS review_score
FROM ecommerce_mvp.silver.order_reviews
GROUP BY order_id;

-- Orders: garante tipos de data corretos e remove duplicatas de order_id
CREATE OR REPLACE TABLE ecommerce_mvp.silver.orders AS
SELECT DISTINCT
  order_id,
  customer_id,
  order_status,
  CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
  CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
  CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date
FROM ecommerce_mvp.bronze.orders;

-- Order items: remove duplicatas exatas, garante price/freight não negativos
CREATE OR REPLACE TABLE ecommerce_mvp.silver.order_items AS
SELECT DISTINCT
  order_id, order_item_id, product_id, seller_id, price, freight_value
FROM ecommerce_mvp.bronze.order_items
WHERE price >= 0 AND freight_value >= 0;

CREATE OR REPLACE TABLE ecommerce_mvp.silver.order_payments_agg AS
SELECT 
  order_id,
  SUM(payment_value) AS payment_value,
  COUNT(*) AS qtd_parcelas_pagamentos
FROM ecommerce_mvp.silver.order_payments
GROUP BY order_id;

-- Customers, products, sellers: remove duplicatas
CREATE OR REPLACE TABLE ecommerce_mvp.silver.customers AS
SELECT DISTINCT customer_id, customer_unique_id, customer_city, customer_state
FROM ecommerce_mvp.bronze.customers;

CREATE OR REPLACE TABLE ecommerce_mvp.silver.products AS
SELECT DISTINCT product_id, product_category_name, product_weight_g
FROM ecommerce_mvp.bronze.products
WHERE product_id IS NOT NULL;

CREATE OR REPLACE TABLE ecommerce_mvp.silver.sellers AS
SELECT DISTINCT seller_id, seller_city, seller_state
FROM ecommerce_mvp.bronze.sellers;

-- COMMAND ----------

SELECT COUNT(*) FROM ecommerce_mvp.silver.order_reviews_agg;

-- COMMAND ----------

SELECT * FROM ecommerce_mvp.bronze.order_reviews LIMIT 10;

-- COMMAND ----------

