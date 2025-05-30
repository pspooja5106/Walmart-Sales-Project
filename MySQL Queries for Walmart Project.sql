DROP DATABASE IF EXISTS walmart_db;

CREATE DATABASE walmart_db;


SHOW DATABASES;

USE walmart_db;

SHOW TABLES;


SELECT * FROM walmart 
LIMIT 10;

SELECT payment_method, count(*)
FROM walmart
GROUP BY payment_method;

SELECT DISTINCT branch
FROM walmart;

SELECT MAX(quantity) FROM walmart;

-- Count total records
SELECT COUNT(*)
FROM walmart;

-- Count payment methods and number of transactions by payment method
SELECT payment_method, COUNT( *) as no_of_payment_done
FROM walmart
GROUP BY payment_method;

-- Count payment methods and number of transactions by payment method with total sales.
SELECT payment_method, COUNT(*) as no_of_payment, 
		SUM(quantity) AS qty_sold,
		ROUND(SUM(total_price), 2) AS total_sales
FROM walmart
GROUP BY payment_method
ORDER BY total_sales Desc;

-- Count distinct branches
SELECT COUNT( DISTINCT Branch)
FROM walmart;

-- Find the minimum quantity sold
SELECT MIN(quantity)
FROM walmart;

-- Business Problems --
-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method
SELECT payment_method, COUNT(*) as no_of_transactions, SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method
ORDER BY total_quantity Desc;


-- Q 2: Identify the highest-rated category in each branch and display the branch, category, and avg rating
SELECT branch, category, avg_rating
FROM 
( SELECT 
			branch, category, AVG(rating) AS avg_rating,
			RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS r
		FROM walmart
		GROUP BY branch, category
) AS ranked
WHERE r = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
SELECT branch, day_name, total_transactions 
FROM (
		SELECT 
			branch,
			DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
			COUNT(*) AS total_transactions,
			RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
		FROM walmart
		GROUP BY branch, day_name
) AS ranked
WHERE ranking = 1;


-- Q4: Calculate the total quantity of items sold per payment method
SELECT payment_method, SUM(quantity) as total_quantity
FROM walmart
GROUP BY payment_method
ORDER BY total_quantity Desc;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT city, category,
	ROUND(AVG(rating), 2) AS Avg_ratings,
    ROUND(MIN(rating), 2) AS Min_ratings,
	ROUND(MAX(rating), 2) AS Max_ratings
FROM walmart
GROUP BY city, category;

-- Q6: Calculate the total profit for each category
SELECT category, 
	ROUND(SUM(total_price),2) AS revenue,
	ROUND (SUM(total_price* profit_margin), 2 ) AS Profit
FROM walmart
GROUP BY category
ORDER BY Profit DESC;

-- or

SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- Q7: Determine the most common payment method for each branch 
SELECT branch, payment_method
FROM (
    SELECT 
        branch, payment_method,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(payment_method) DESC) AS r
    FROM walmart
    GROUP BY branch, payment_method
) AS ranked
WHERE r = 1;

-- OR

WITH CPM AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS Q
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method, total_trans
FROM CPM
WHERE Q = 1;

-- Q8: Determine the most common payment method for each category
SELECT category, payment_method
FROM (
    SELECT 
        category, payment_method,
        RANK() OVER(PARTITION BY category ORDER BY COUNT(payment_method) DESC) AS r
    FROM walmart
    GROUP BY category, payment_method
) AS ranked
WHERE r = 1;


-- Q9: Categorize sales into Morning, Afternoon, and Evening shifts and find out each of the shift and number of invoices.
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q10: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 10;













