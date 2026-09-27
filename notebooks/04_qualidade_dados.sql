-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## Verificações complementares para o Catálogo de Dados

-- COMMAND ----------

SELECT 
  MIN(price) AS min_price, MAX(price) AS max_price,
  MIN(freight_value) AS min_freight, MAX(freight_value) AS max_freight,
  MIN(payment_value) AS min_payment, MAX(payment_value) AS max_payment
FROM ecommerce_mvp.gold.fato_pedidos;

-- COMMAND ----------

SELECT DISTINCT order_status FROM ecommerce_mvp.gold.fato_pedidos;

-- COMMAND ----------

SELECT MIN(product_weight_g), MAX(product_weight_g) FROM ecommerce_mvp.gold.dim_produtos;

-- COMMAND ----------

-- Completude: nulos em campos-chave
SELECT 
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS nulos_customer,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS nulos_product,
  SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS nulos_payment,
  SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS nulos_review,
  SUM(CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END) AS nulos_delivery,
  COUNT(*) AS total_linhas
FROM ecommerce_mvp.gold.fato_pedidos;

-- COMMAND ----------

-- Acurácia/Outliers: entregas com prazo negativo ou absurdamente longo
SELECT MIN(delivery_days), MAX(delivery_days), AVG(delivery_days)
FROM ecommerce_mvp.gold.fato_pedidos
WHERE delivery_days IS NOT NULL;

-- COMMAND ----------

-- Quantos pedidos têm entrega muito demorada (ex: mais de 60 dias)?
SELECT COUNT(*) FROM ecommerce_mvp.gold.fato_pedidos WHERE delivery_days > 60;

-- COMMAND ----------

-- Distribuição rápida pra entender se são poucos casos extremos ou muitos
SELECT 
  CASE 
    WHEN delivery_days <= 15 THEN '0-15 dias'
    WHEN delivery_days <= 30 THEN '16-30 dias'
    WHEN delivery_days <= 60 THEN '31-60 dias'
    ELSE '60+ dias'
  END AS faixa,
  COUNT(*) AS qtd
FROM ecommerce_mvp.gold.fato_pedidos
WHERE delivery_days IS NOT NULL
GROUP BY faixa
ORDER BY faixa;

-- COMMAND ----------

-- Unicidade: confirma que não há order_id + order_item_id duplicado
SELECT order_id, order_item_id, COUNT(*) 
FROM ecommerce_mvp.gold.fato_pedidos
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- COMMAND ----------

-- Consistência: estados de clientes fora do padrão de sigla (2 letras)
SELECT DISTINCT customer_state 
FROM ecommerce_mvp.gold.dim_clientes
WHERE LENGTH(customer_state) != 2;

-- COMMAND ----------

SELECT 
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS nulos_customer,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS nulos_product,
  SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS nulos_payment,
  SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS nulos_review,
  SUM(CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END) AS nulos_delivery,
  COUNT(*) AS total_linhas
FROM ecommerce_mvp.gold.fato_pedidos;

-- COMMAND ----------

