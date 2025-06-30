-- SQL retail_sale analysis pj1

-- Firstly, create database
CREATE DATABASE sql_project_p1_D1

-- CREATE TABLE
CREATE TABLE retail_sale
	(
transactions_id INT,
sale_date DATE,
sale_time TIME,
customer_id	 INT,
gender	VARCHAR(10),
age	INT,
category VARCHAR(15),
quantiy INT,
price_per_unit FLOAT,
cogs FLOAT,
total_sale FLOAT
	)

-- Data cleaning
SELECT * FROM retail_sale

SELECT COUNT(*)
FROM retail_sale

SELECT MAX(age)
FROM retail_sale

-- Check null values in age column
SELECT *
FROM retail_sale
WHERE 
	transactions_id IS NULL
	OR sale_date IS NULL
 	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR category IS NULL
	OR quantiy IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL

-- Delete the null values

DELETE
FROM retail_sale
WHERE 
	transactions_id IS NULL
	OR sale_date IS NULL
 	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR category IS NULL
	OR quantiy IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL

-- Rename an incorrect column
ALTER TABLE retail_sale
RENAME column quantiy to quantity

-- Data exploration

--  How much total sales we have
SELECT DISTINCT(category) tot_cat
FROM retail_sale

-- Q1. Retrieve all columns for sales made on '2022-11.05'
SELECT *
FROM retail_sale
WHERE sale_date = '2022-11-05'

-- Q2. Retrieve all transactions where the category is 'Clothing' and the quantity sold
-- is more than 3 in the month of Nov-2022

SELECT *
FROM retail_sale
WHERE 
	category = 'Clothing' 
	AND 
	quantity > 2 
	AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'

--Q3. Calculate the total sales (total_sale) for each category

SELECT SUM(total_sale) tot_sale, category, COUNT(*) tot_orders
FROM retail_sale
GROUP BY 2

-- Q4. Find the average age of customers who purchased items from the 'Beauty' category
SELECT ROUND(AVG(age),3) avg_age, category
FROM retail_sale
WHERE category = 'Beauty'
GROUP BY 2

--Q5. Find all transactions where the total_sale is greater than 1000
SELECT *
FROM retail_sale

	-- End of Project
WHERE 
	total_sale > 1000

-- Q6. Find the total number of transactions (transaction_id) made by each gender in each category
SELECT COUNT(*), gender, category
FROM retail_sale
GROUP BY 2,3
ORDER BY 1 DESC

-- Q7. Calculate the average sale for each month. Find out the best selling month in each year
-- Do it with a Subquery
SELECT year, month, avg_sale
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) as year,
		EXTRACT(MONTH FROM sale_date) as month,
		ROUND(AVG(total_sale)::numeric,2) avg_sale,
		RANK() OVER
		(
		PARTITION BY EXTRACT(YEAR FROM sale_date) 
		ORDER BY ROUND(AVG(total_sale)::numeric,2) desc
		)
		AS rank	
			
	FROM retail_sale 
	GROUP BY 1, 2
)
WHERE rank =1

-- Do thesame with a CTE

WITH avg_sales_ranked AS(
	SELECT 
		EXTRACT(YEAR FROM sale_date) as year,
		EXTRACT(MONTH FROM sale_date) as month,
		ROUND(AVG(total_sale)::numeric,2) as avg_sale,
		RANK() OVER(
		PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY ROUND(AVG(total_sale)::numeric,2) desc
		) AS rank
	FROM retail_sale
	GROUP BY 1,2	
)
SELECT year, month, avg_sale
FROM avg_sales_ranked
WHERE rank = 1

-- Q8. Which month has the most avg_sales in the 2 years combined?

SELECT 
	TO_CHAR(sale_date, 'month') as month_name,
	EXTRACT(MONTH FROM sale_date) as month,
	ROUND(AVG(total_sale)::numeric,2) as avg_sale
FROM retail_sale
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5

-- Q9. Calculate the monthly sales for each year. Find the month with the most sales

WITH sales_ranked AS(
	SELECT 
		SUM(total_sale) as Tot_sale,
		EXTRACT(MONTH FROM sale_date) as month,
		EXTRACT(YEAR FROM sale_date) as year,
		TO_CHAR(sale_date, 'month') as Month_name,
		RANK() OVER
		(
		PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY SUM(total_sale) DESC
		) AS rank
	FROM retail_sale
	GROUP BY 2,3,4
	ORDER BY 1 DESC)

SELECT month_name, year, tot_sale
FROM sales_ranked
ORDER BY 3 desc
LIMIT 6

-- Q10. Calculate the month that has had the most sale overall

SELECT TO_CHAR(sale_date, 'month') month_name,
		SUM(total_sale) Tot_sale
FROM retail_sale
GROUP BY 1
ORDER BY 2 DESC


-- Q11. Find the top 5 customers based on the highest total sales
SELECT SUM(total_sale) total, customer_id
FROM retail_sale
GROUP BY 2
ORDER BY 1 DESC
LIMIT 5

-- Q11. Find the number of unique customers who purchased items from each category
SELECT COUNT(DISTINCT customer_id), category
FROM retail_sale
GROUP BY 2
ORDER BY 1 DESC

-- Q12. Create each shift and number of orders example (morning < 12, afternoon >12 and <17, evening )

WITH hourly_orders AS
(	SELECT *,
		CASE 
		WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon' 
		ELSE 'Evening' 
		END AS periods
		
	FROM retail_sale
)
	
SELECT COUNT(*), periods
FROM hourly_orders
GROUP BY 2
ORDER BY 1 DESC


