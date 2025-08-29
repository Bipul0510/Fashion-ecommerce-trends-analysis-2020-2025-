-- Project Name: "Fashion ecommerce trends analysis (2020-2025)"

-- Queries and solutions for 'fashion_ecom_2020_2025' dataset

create database fashion_ecom_2020_2025

use fashion_ecom_2020_2025

select * from fashion_ecom_2020_2025



/* 1) Total Revenue Over the Years */

SELECT YEAR(order_date) as year,
       ROUND(SUM(revenue), 2) as total_revenue
FROM fashion_ecom_2020_2025
GROUP BY YEAR(order_date)
ORDER BY year;


/* 2) Top 5 Categories by Revenue */

SELECT TOP 5 category,
       ROUND(SUM(revenue),2) as total_revenue

FROM fashion_ecom_2020_2025
GROUP BY category
ORDER BY total_revenue DESC;


/* 3) Average Order Value (AOV) */

SELECT ROUND(SUM(revenue) * 1.0 / COUNT(DISTINCT order_id), 2) as avg_order_value
FROM fashion_ecom_2020_2025


/* 4) Orders by Sales Channel */

SELECT sales_channel,
       COUNT(DISTINCT order_id) as total_orders,
       round(SUM(revenue),2) as total_revenue
FROM fashion_ecom_2020_2025
GROUP BY sales_channel;


/* 5) Top 5 Customers with Highest Lifetime Value (LTV) */

SELECT TOP 5 customer_id,
       round(SUM(revenue),2) as lifetime_value

FROM fashion_ecom_2020_2025
GROUP BY customer_id
ORDER BY lifetime_value DESC;


/* 6) Return Rate by Category */

SELECT category,
       COUNT(CASE WHEN returned = 1 THEN 1 END) * 100.0 / COUNT(*) as return_rate_pct

FROM fashion_ecom_2020_2025
GROUP BY category
ORDER BY return_rate_pct DESC;


/* 7) Monthly Sales Trend for 2025 */

SELECT FORMAT(order_date, 'yyyy-MM') as year_month,
       ROUND(SUM(revenue), 2) as total_revenue

FROM fashion_ecom_2020_2025
WHERE YEAR(order_date) = 2025
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY year_month;


/* 8) Gender-wise Spending */

SELECT customer_gender,
       round(SUM(revenue),2) as total_revenue,
       COUNT(DISTINCT customer_id) as total_customers

FROM fashion_ecom_2020_2025
GROUP BY customer_gender;


/* 9) Top 5 Countries by Orders */

SELECT TOP 5 country,
       COUNT(DISTINCT order_id) as total_orders

FROM fashion_ecom_2020_2025
GROUP BY country
ORDER BY total_orders DESC


/* 10) Average Discount by Category */

SELECT category,
       ROUND(AVG(discount_pct), 2) as avg_discount

FROM fashion_ecom_2020_2025
GROUP BY category
ORDER BY 2 DESC


/* 11) Customer Segmentation by Age Group */

SELECT CASE 
           WHEN customer_age < 25 THEN '18-24'
           WHEN customer_age BETWEEN 25 AND 34 THEN '25-34'
           WHEN customer_age BETWEEN 35 AND 44 THEN '35-44'
           WHEN customer_age BETWEEN 45 AND 54 THEN '45-54'
           ELSE '55+'
       END as age_group,
       COUNT(DISTINCT customer_id) as customers,
       ROUND(SUM(revenue),2) as revenue

FROM fashion_ecom_2020_2025
GROUP BY CASE 
             WHEN customer_age < 25 THEN '18-24'
             WHEN customer_age BETWEEN 25 AND 34 THEN '25-34'
             WHEN customer_age BETWEEN 35 AND 44 THEN '35-44'
             WHEN customer_age BETWEEN 45 AND 54 THEN '45-54'
             ELSE '55+'
         END
ORDER BY revenue DESC;


/* 12) Repeat Purchase Rate */

SELECT 
    CAST(COUNT(DISTINCT customer_id) as FLOAT) /
    (SELECT COUNT(DISTINCT customer_id) 
     FROM fashion_ecom_2020_2025) as repeat_customer_ratio
FROM fashion_ecom_2020_2025
WHERE customer_id IN (
    SELECT customer_id
    FROM fashion_ecom_2020_2025
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
);



/* 13) Revenue Contribution by Top 10% Customers */

WITH customer_spending as (
    SELECT customer_id, SUM(revenue) as total_spent
    FROM fashion_ecom_2020_2025
    GROUP BY customer_id
),
ranked as (
    SELECT customer_id, total_spent,
           NTILE(10) OVER (ORDER BY total_spent DESC) as decile
    FROM customer_spending
)
SELECT decile,
       round(SUM(total_spent),2) as revenue_contribution
FROM ranked
GROUP BY decile;


/* 14) Highest Selling Product Each Year */

SELECT year, product_id, total_revenue
FROM (
    SELECT 
        YEAR(order_date) as year,
        product_id,
        SUM(revenue) as total_revenue,
        RANK() OVER (
            PARTITION BY YEAR(order_date) 
            ORDER BY SUM(revenue) DESC
        ) as rnk
    FROM fashion_ecom_2020_2025
    GROUP BY YEAR(order_date), product_id
) t
WHERE rnk = 1;



/* 15) Cohort Analysis – First Purchase Month vs Revenue in 2025 */

WITH first_purchase as (
    SELECT customer_id,
           MIN(order_date) as first_dt
    FROM fashion_ecom_2020_2025
    GROUP BY customer_id
),
orders_2025 as (
    SELECT customer_id,
           order_date,
           revenue,
           FORMAT(order_date, 'yyyy-MM') as order_month
    FROM fashion_ecom_2020_2025
    WHERE YEAR(order_date) = 2025
)
SELECT 
       FORMAT(fp.first_dt, 'yyyy-MM') as cohort_month,
       o.order_month,
       round(SUM(o.revenue),2) as total_revenue
FROM orders_2025 o
JOIN first_purchase fp 
     ON o.customer_id = fp.customer_id
GROUP BY FORMAT(fp.first_dt, 'yyyy-MM'), o.order_month
ORDER BY cohort_month, order_month;



--------------------------------------------------------------------------------------------------------------------------------------