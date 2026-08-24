--- 1) What is the conversion rate in comparison to website visits? ---

WITH order_website AS (
SELECT o.website_session_id AS session_orders, 
       ws.website_session_id AS sessions
FROM website_sessions as ws
LEFT JOIN orders as o
ON o.website_session_id = ws.website_session_id
)
select count(distinct session_orders) AS sessions_with_orders,
       count(distinct sessions) AS total_sessions,
       round(count(distinct session_orders) / count(distinct sessions)*100,2) AS conversion_rate
from order_website;

--- 2) How are marketing channels or ads performing? ---

--- Checking utm_source and their corresponding sessions --
SELECT utm_source,
       COUNT(website_session_id) AS total_session
FROM website_sessions
GROUP BY utm_source;

--- null utm_source ---
SELECT http_referer,
       COUNT(website_session_id) AS total_session
FROM website_sessions
where utm_source is null
group by http_referer;

--- Final solution ---
WITH utm_source_order AS (
SELECT utm_source,
       COUNT(DISTINCT website_sessions.website_session_id) AS total_session,
       COUNT(DISTINCT orders.website_session_id) AS total_session_order
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
GROUP BY utm_source
ORDER BY total_session desc , 
        total_session_order desc
)
SELECT utm_source, 
       total_session,
       total_session_order,
       round((total_session_order/total_session)*100,2) AS conversion_rate
FROM utm_source_order;

--- Null has higher conversion rate but null is not a single marketing channel ---

SELECT utm_campaign,
       total_sessions,
       total_session_order,
       round((total_session_order/total_sessions)*100,2) AS conversion_rate
FROM (
SELECT utm_campaign,
      COUNT(DISTINCT ws.website_session_id) AS total_sessions,
      COUNT(DISTINCT o.website_session_id) AS total_session_order
FROM website_sessions AS ws 
LEFT JOIN orders as o 
ON ws.website_session_id = o.website_session_id
GROUP BY utm_campaign ) AS utm_campaign_session_order;

WITH utm_session_order AS (
SELECT utm_content, 
	   Count(DISTINCT ws.website_session_id) as total_sessions,
       Count(DISTINCT o.website_session_id) as total_session_order
FROM website_sessions AS ws 
LEFT JOIN orders AS o 
ON ws.website_session_id = o.website_session_id
group by utm_content
)
SELECT utm_content, total_sessions, total_session_order, round((total_session_order/total_sessions)*100, 2) AS conversion_rate
FROM utm_session_order;

--- 3) What are total revenue and AOV? ---

SELECT 
     round(sum(price_usd),2) AS total_revenue
FROM orders ;

SELECT 
     round(sum(price_usd)/count(distinct order_id),2) AS Avg_order_value
FROM orders ;

--- 4) Which product is more profitable? ---

SELECT primary_product_id,
       round(SUM(price_usd - cogs_usd),2) AS total_profit
FROM orders
GROUP BY primary_product_id
ORDER BY total_profit desc;

select primary_product_id, 
	   round(SUM((price_usd-cogs_usd))/SUM(price_usd),2)*100 AS profit_margin
From orders
GROUP BY primary_product_id;

SELECT primary_product_id,
       COUNT(distinct order_id) AS total_orders
FROM orders
GROUP BY primary_product_id;

--- 5) What is the total refundable amount in the last two years? ---

SELECT
       round(SUM(refund_amount_usd),2) AS total_refund_amount
FROM order_item_refunds
WHERE YEAR(created_at) IN ('2014', '2015') ;

--- How are sales performing monthly and yearly? ---

SELECT YEAR(created_at) as order_year,
	 month(created_at) AS order_month,
	 ROUND(SUM(price_usd),2) AS total_sales
FROM orders
GROUP BY order_year, order_month
ORDER BY order_year DESC, order_month ;


