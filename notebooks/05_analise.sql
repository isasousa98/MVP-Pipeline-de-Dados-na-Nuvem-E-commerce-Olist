-- Databricks notebook source
--Pergunta 1: Quais categorias de produto geram maior receita total e maior volume de pedidos?

SELECT 
  p.product_category_name_english AS categoria,
  COUNT(*) AS qtd_itens_vendidos,
  ROUND(SUM(f.price), 2) AS receita_total,
  ROUND(AVG(f.price), 2) AS ticket_medio_item
FROM ecommerce_mvp.gold.fato_pedidos f
JOIN ecommerce_mvp.gold.dim_produtos p ON f.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY receita_total DESC
LIMIT 15;

-- COMMAND ----------

--Pergunta 2: Existe relação entre atraso na entrega (diferença entre a data estimada e a data real de entrega) e a nota de avaliação (review_score) dada pelo cliente? 

SELECT 
  CASE 
    WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 0 THEN 'Entregue no prazo ou antes'
    WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 7 THEN 'Atraso leve (1-7 dias)'
    ELSE 'Atraso grande (8+ dias)'
  END AS situacao_entrega,
  COUNT(*) AS qtd_pedidos,
  ROUND(AVG(f.review_score), 2) AS nota_media
FROM ecommerce_mvp.gold.fato_pedidos f
JOIN ecommerce_mvp.silver.orders o ON f.order_id = o.order_id
WHERE f.review_score IS NOT NULL AND o.order_delivered_customer_date IS NOT NULL
GROUP BY situacao_entrega
ORDER BY nota_media DESC;

-- COMMAND ----------

--Pergunta 3: Quais estados brasileiros apresentam o maior ticket médio por pedido, e como isso se relaciona com o tempo médio de entrega nessas regiões?

SELECT 
  c.customer_state AS estado,
  COUNT(DISTINCT f.order_id) AS qtd_pedidos,
  ROUND(AVG(f.price + f.freight_value), 2) AS ticket_medio,
  ROUND(AVG(f.delivery_days), 1) AS entrega_media_dias
FROM ecommerce_mvp.gold.fato_pedidos f
JOIN ecommerce_mvp.gold.dim_clientes c ON f.customer_id = c.customer_id
WHERE f.delivery_days IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(DISTINCT f.order_id) >= 30
ORDER BY ticket_medio DESC;

-- COMMAND ----------

--Pergunta 4: qual a forma de pagamento mais utilizada, e há diferença no ticket médio entre os métodos?

SELECT 
  pay.payment_type AS forma_pagamento,
  COUNT(*) AS qtd_pagamentos,
  ROUND(AVG(pay.payment_value), 2) AS valor_medio_pago,
  ROUND(AVG(pay.payment_installments), 1) AS parcelas_media
FROM ecommerce_mvp.silver.order_payments pay
GROUP BY pay.payment_type
ORDER BY qtd_pagamentos DESC;

-- COMMAND ----------

--Pergunta 5: como o tempo médio de entrega varia entre as regiões do Brasil, e isso impacta a satisfação do cliente?

SELECT 
  CASE 
    WHEN c.customer_state IN ('AC','AP','AM','PA','RO','RR','TO') THEN 'Norte'
    WHEN c.customer_state IN ('AL','BA','CE','MA','PB','PE','PI','RN','SE') THEN 'Nordeste'
    WHEN c.customer_state IN ('DF','GO','MT','MS') THEN 'Centro-Oeste'
    WHEN c.customer_state IN ('ES','MG','RJ','SP') THEN 'Sudeste'
    WHEN c.customer_state IN ('PR','RS','SC') THEN 'Sul'
  END AS regiao,
  COUNT(*) AS qtd_pedidos,
  ROUND(AVG(f.delivery_days), 1) AS entrega_media_dias,
  ROUND(AVG(f.review_score), 2) AS nota_media
FROM ecommerce_mvp.gold.fato_pedidos f
JOIN ecommerce_mvp.gold.dim_clientes c ON f.customer_id = c.customer_id
WHERE f.delivery_days IS NOT NULL AND f.review_score IS NOT NULL
GROUP BY regiao
ORDER BY entrega_media_dias DESC;

-- COMMAND ----------

