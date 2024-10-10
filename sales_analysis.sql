-- Question 1: What are the monthly and quarterly sales trends for Macbooks sold in North America across all years?
SELECT date_trunc(orders.purchase_ts, month) as month,
    ROUND(SUM(orders.usd_price), 2) as total_price,
    ROUND(AVG(orders.usd_price), 2) as aov,
    count(DISTINCT orders.id) as order_count

FROM elist.orders
LEFT JOIN elist.customers
  ON orders.customer_id = customers.id
LEFT JOIN elist.geo_lookup
  ON customers.country_code = geo_lookup.country
WHERE orders.product_name LIKE 'Macbook Air Laptop'
  AND geo_lookup.region LIKE 'NA'
GROUP BY month
ORDER BY month DESC;


SELECT date_trunc(orders.purchase_ts, quarter) as quarter,
    ROUND(SUM(orders.usd_price), 2) as total_price,
    ROUND(AVG(orders.usd_price), 2) as aov,
    count(DISTINCT orders.id) as order_count

FROM elist.orders
LEFT JOIN elist.customers
  ON orders.customer_id = customers.id
LEFT JOIN elist.geo_lookup
  ON customers.country_code = geo_lookup.country
WHERE orders.product_name LIKE 'Macbook Air Laptop'
  AND geo_lookup.region LIKE 'NA'
GROUP BY quarter
ORDER BY quarter DESC;

-- Question 2: What was the monthly refund rate for purchases made in 2020? How many refunds did we have each month in 2021 for Apple products? 
SELECT date_trunc(order_status.purchase_ts, month) AS month,
  SUM(CASE WHEN order_status.refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS is_refund,
  ROUND(SUM(CASE WHEN order_status.refund_ts IS NOT NULL THEN 1 ELSE 0 END)/COUNT(DISTINCT order_status.order_id), 2)*100 AS refund_rate,
FROM elist.order_status
WHERE EXTRACT(YEAR FROM order_status.purchase_ts)= 2020
AND order_status.purchase_ts IS NOT NULL
GROUP BY month
ORDER BY month;

SELECT date_trunc(order_status.purchase_ts, month) AS month,
  SUM(CASE WHEN order_status.refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS is_refund
FROM elist.orders
LEFT JOIN elist.order_status
ON orders.id = order_status.order_id
WHERE EXTRACT(YEAR FROM order_status.purchase_ts)= 2021
AND orders.product_name LIKE 'Macbook Air Laptop'
AND order_status.refund_ts IS NOT NULL
GROUP BY month;

-- Question 3: Are there certain products that are getting refunded more frequently than others? What are the top 3 most frequently refunded products across all years? What are the top 3 products that have the highest count of refunds?
SELECT orders.product_name, 
  SUM(CASE WHEN order_status.refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS is_refund,
  ROUND(SUM(CASE WHEN order_status.refund_ts IS NOT NULL THEN 1 ELSE 0 END)/COUNT(DISTINCT order_status.order_id), 2)*100 AS refund_rate
FROM elist.orders
LEFT JOIN elist.order_status
ON orders.id = order_status.order_id
GROUP BY 1
ORDER BY 2 DESC;

-- Question 4: What’s the average order value across different account creation methods in the first two months of 2022? Which method had the most new customers in this time?
SELECT account_creation_method, 
  ROUND(AVG(orders.usd_price), 2) AS aov
FROM elist.customers
LEFT JOIN elist.orders
  ON customers.id = orders.customer_id
WHERE EXTRACT(YEAR FROM customers.created_on)= 2022
  AND EXTRACT(MONTH FROM customers.created_on) IN (1, 2)
GROUP BY 1
ORDER BY aov DESC;

-- Question 5: What’s the average time between customer registration and placing an order?
  SELECT --customers.id,
  --  orders.id,
  --  customers.created_on,
  --  orders.purchase_ts,
   AVG( date_diff(orders.purchase_ts, customers.created_on, day)) AS elapsed_time
  FROM elist.customers
  LEFT JOIN elist.orders
    ON customers.id = orders.customer_id;

-- Question 6: Which marketing channels perform the best in each region? Does the top channel differ across regions?
SELECT customers.marketing_channel,
  geo_lookup.region,
  COUNT(orders.id) AS total_orders,
  ROUND(SUM(usd_price), 2) AS total_sales,
  ROUND(AVG(usd_price), 2) AS aov
FROM elist.customers
LEFT JOIN elist.orders
  ON customers.id = orders.customer_id
LEFT JOIN elist.geo_lookup
  ON customers.country_code = geo_lookup.country
-- WHERE EXTRACT(YEAR FROM customers.created_on)= 2022
GROUP BY 1, 2
ORDER BY total_orders DESC;
