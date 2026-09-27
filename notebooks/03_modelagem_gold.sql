-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## Modelagem Gold — Esquema Estrela
-- MAGIC Este notebook cria a tabela fato (fato_pedidos) e as dimensões 
-- MAGIC (dim_clientes, dim_produtos, dim_vendedores) a partir das tabelas Bronze.
-- MAGIC
-- MAGIC - **fato_pedidos (grão = um item de pedido):** order_id, order_item_id, customer_id, product_id, seller_id, order_purchase_timestamp, price, freight_value, payment_value (vem de order_payments), review_score (vem de order_reviews), delivery_days (calculado), order_status
-- MAGIC
-- MAGIC - **dim_clientes:** customer_id, customer_unique_id, customer_city, customer_state
-- MAGIC
-- MAGIC - **dim_produtos:** product_id, product_category_name_english (já traduzido, via join com product_category_name_translation), product_weight_g
-- MAGIC
-- MAGIC - **dim_vendedores:** seller_id, seller_city, seller_state
-- MAGIC
-- MAGIC - **dim_tempo:** derivada de order_purchase_timestamp — ano, mês, dia, dia da semana

-- COMMAND ----------

CREATE OR REPLACE TABLE ecommerce_mvp.gold.dim_clientes AS
SELECT * FROM ecommerce_mvp.silver.customers;

CREATE OR REPLACE TABLE ecommerce_mvp.gold.dim_produtos AS
SELECT p.product_id, t.product_category_name_english, p.product_weight_g
FROM ecommerce_mvp.silver.products p
LEFT JOIN ecommerce_mvp.bronze.product_category_name_translation t
  ON p.product_category_name = t.product_category_name;

CREATE OR REPLACE TABLE ecommerce_mvp.gold.dim_vendedores AS
SELECT * FROM ecommerce_mvp.silver.sellers;

CREATE OR REPLACE TABLE ecommerce_mvp.gold.fato_pedidos AS
SELECT
  oi.order_id, oi.order_item_id, o.customer_id, oi.product_id, oi.seller_id,
  o.order_purchase_timestamp, oi.price, oi.freight_value,
  pay.payment_value, rev.review_score,
  DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS delivery_days,
  o.order_status
FROM ecommerce_mvp.silver.order_items oi
JOIN ecommerce_mvp.silver.orders o ON oi.order_id = o.order_id
LEFT JOIN ecommerce_mvp.silver.order_payments_agg pay ON oi.order_id = pay.order_id
LEFT JOIN ecommerce_mvp.silver.order_reviews_agg rev ON oi.order_id = rev.order_id;

-- COMMAND ----------

SELECT order_id, order_item_id, COUNT(*) 
FROM ecommerce_mvp.gold.fato_pedidos
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- COMMAND ----------

DESCRIBE TABLE ecommerce_mvp.gold.fato_pedidos;

-- COMMAND ----------

DESCRIBE TABLE ecommerce_mvp.gold.dim_clientes;

-- COMMAND ----------

DESCRIBE TABLE ecommerce_mvp.gold.dim_produtos;

-- COMMAND ----------

DESCRIBE TABLE ecommerce_mvp.gold.dim_vendedores;

-- COMMAND ----------

-- Para colunas numéricas (min/max)
SELECT MIN(price), MAX(price), MIN(delivery_days), MAX(delivery_days)
FROM ecommerce_mvp.gold.fato_pedidos;

-- Para colunas categóricas (valores possíveis)
SELECT DISTINCT customer_state FROM ecommerce_mvp.gold.dim_clientes;

-- COMMAND ----------

SELECT COUNT(*) FROM ecommerce_mvp.gold.fato_pedidos;

SELECT review_score, COUNT(*) 
FROM ecommerce_mvp.gold.fato_pedidos 
GROUP BY review_score 
ORDER BY review_score;

-- COMMAND ----------

SELECT COUNT(*) FROM ecommerce_mvp.gold.fato_pedidos;

-- COMMAND ----------

