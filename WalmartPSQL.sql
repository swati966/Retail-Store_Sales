SELECT * FROM walmart;

--
SELECT COUNT(*) FROM walmart;

--DROP TABLE walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

--Business Problems
--Question: What are the different payment methods, and how many transactions and
--items were sold with each method?
--Purpose: This helps understand customer preferences for payment methods, aiding in
--payment optimization strategies.
SELECT payment_method,
	COUNT(*) AS no_of_payments,
	SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method

--Identify the Highest-Rated Category in Each Branch
-- Question: Which category received the highest average rating in each branch?
--Purpose: This allows Walmart to recognize and promote popular categories in specific
--branches, enhancing customer satisfaction and branch-specific marketing

SELECT *
FROM
(	SELECT
	branch,
	category,
	avg(rating) as avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating)desc) AS RANK

FROM walmart
GROUP BY 1,2
)
WHERE rank=1

--Determine the Busiest Day for Each Branch
--Question: What is the busiest day of the week for each branch based on transaction volume?
--Purpose: This insight helps in optimizing staffing and inventory management to accommodate peak days.
SELECT *

FROM 
(SELECT
	branch,
	TO_CHAR(TO_DATE(date, 'DD-MM-YYYY'), 'Day') AS day_name,
	COUNT(*) AS no_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC)AS RANK
	
	
FROM walmart
GROUP BY 1,2
)
WHERE RANK = 1

--4. Calculate Total Quantity Sold by Payment Method
--● Question: How many items were sold through each payment method?
--● Purpose: This helps Walmart track sales volume by payment type, providing insights
--into customer purchasing habits.

SELECT 
 	payment_method,
	--COUNT(*) AS 
	SUM(quantity) AS no_qty_sold
	
FROM walmart
GROUP BY payment_method

--5. Analyze Category Ratings by City
--● Question: What are the average, minimum, and maximum ratings for each category in each city?
--● Purpose: This data can guide city-level promotions, allowing Walmart to 
--address regional preferences and improve customer experiences.

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) AS max_rating,
	AVG(rating) AS avg_rating
FROM walmart
GROUP BY 1,2

--6. Calculate Total Profit by Category
--● Question: What is the total profit for each category, ranked from highest to lowest?
--● Purpose: Identifying high-profit categories helps focus efforts on expanding these
--products or managing pricing strategies effectively.
SELECT 
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1





SELECT * FROM walmart;

-- 7. Determine the Most Common Payment Method per Branch
-- ● Question: What is the most frequently used payment method in each branch?
-- ● Purpose: This information aids in understanding branch-specific payment preferences,
-- potentially allowing branches to streamline their payment processing systems.
WITH cte
AS
(SELECT 
	 
	 branch,
	 payment_method,
	 COUNT(*) AS total_trans,
	 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC)AS RANK

FROM walmart
GROUP BY 1,2
)
SELECT *
FROM cte
where RANK=1


-- --8. Analyze Sales Shifts Throughout the Day
-- ● Question: How many transactions occur in each shift (Morning, Afternoon, Evening)
-- across branches?
-- ● Purpose: This insight helps in managing staff shifts and stock replenishment schedules,
-- especially during high-sales periods.

SELECT 
	branch,
    CASE
        WHEN EXTRACT(HOUR FROM replace("time", '.', ':')::time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM replace("time", '.', ':')::time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS count_entries
FROM walmart
GROUP BY 1,day_time
ORDER BY 1,3 DESC








-- 9. Identify Branches with Highest Revenue Decline Year-Over-Year
-- ● Question: Which branches experienced the largest decrease in revenue compared to
-- the previous year?
-- ● Purpose: Detecting branches with declining revenue is crucial for understanding
-- possible local issues and creating strategies to boost sales or mitigate losses.

--SELECT * FROM walmart;
--rdr==last_rev-current_rev/last_rev*100
SELECT *,
	EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YYYY')) AS formatted_date
FROM walmart

-- 2022 and 2023 branch-wise revenue comparison
WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YYYY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YYYY')) = 2023
    GROUP BY branch
)
SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS current_year_revenue,
    ROUND(
        ((ls.revenue - cs.revenue)::numeric / ls.revenue::numeric) * 100,
        2
    ) AS rev_desc_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
    ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_desc_ratio DESC
LIMIT 5;


