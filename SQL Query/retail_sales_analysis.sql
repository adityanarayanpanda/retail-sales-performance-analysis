USE retail_sales_analysis;
SELECT * FROM superstore
LIMIT 10;

SELECT COUNT(*) FROM superstore;
DESCRIBE superstore;

-- check and convert order date and ship date data type to date
SELECT order_date,ship_date  
FROM superstore LIMIT 10;

ALTER TABLE superstore
ADD COLUMN clean_order_date DATE;

SET SQL_SAFE_UPDATES = 0;
UPDATE superstore
SET clean_order_date = STR_TO_DATE(order_date, '%m/%d/%Y')
WHERE order_date IS NOT NULL;

ALTER TABLE superstore DROP COLUMN order_date;--  DROP EXISTING DATE COL
ALTER TABLE superstore 
CHANGE clean_order_date order_date DATE;

-- SHIP DATE DATA TYPE CHANGE
ALTER TABLE superstore ADD COLUMN clean_ship_date DATE;

SET SQL_SAFE_UPDATES = 0;
UPDATE superstore
SET clean_ship_date=STR_TO_DATE(ship_date,'%m/%d/%Y')
WHERE ship_date IS NOT NULL;

ALTER TABLE superstore DROP COLUMN ship_date;
ALTER TABLE superstore 
CHANGE clean_ship_date ship_date DATE;

-- Check Null values or blank values
SELECT 
    SUM(CASE WHEN row_id IS NULL OR row_id = '' THEN 1 ELSE 0 END) AS row_id_null_blank,
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) AS order_id_null_blank,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_null,   -- DATE column
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS ship_date_null,     -- DATE column
    SUM(CASE WHEN ship_mode IS NULL OR ship_mode = '' THEN 1 ELSE 0 END) AS ship_mode_null_blank,
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS customer_id_null_blank,
    SUM(CASE WHEN customer_name IS NULL OR customer_name = '' THEN 1 ELSE 0 END) AS customer_name_null_blank,
    SUM(CASE WHEN segment IS NULL OR segment = '' THEN 1 ELSE 0 END) AS segment_null_blank,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS country_null_blank,
    SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS city_null_blank,
    SUM(CASE WHEN state IS NULL OR state = '' THEN 1 ELSE 0 END) AS state_null_blank,
    SUM(CASE WHEN postal_code IS NULL OR postal_code = '' THEN 1 ELSE 0 END) AS postal_code_null_blank,
    SUM(CASE WHEN region IS NULL OR region = '' THEN 1 ELSE 0 END) AS region_null_blank,
    SUM(CASE WHEN product_id IS NULL OR product_id = '' THEN 1 ELSE 0 END) AS product_id_null_blank,
    SUM(CASE WHEN category IS NULL OR category = '' THEN 1 ELSE 0 END) AS category_null_blank,
    SUM(CASE WHEN sub_category IS NULL OR sub_category = '' THEN 1 ELSE 0 END) AS sub_category_null_blank,
    SUM(CASE WHEN product_name IS NULL OR product_name = '' THEN 1 ELSE 0 END) AS product_name_null_blank,
    SUM(CASE WHEN sales IS NULL OR sales = '' THEN 1 ELSE 0 END) AS sales_null_blank,
    SUM(CASE WHEN quantity IS NULL OR quantity = '' THEN 1 ELSE 0 END) AS quantity_null_blank,
    SUM(CASE WHEN discount IS NULL OR discount = '' THEN 1 ELSE 0 END) AS discount_null_blank,
    SUM(CASE WHEN profit IS NULL OR profit = '' THEN 1 ELSE 0 END) AS profit_null_blank
FROM superstore;
-- Validate All Data Are correct or not
-- Sales < 0
SELECT sales FROM superstore WHERE sales<0;-- No rows
-- Quantity ≤ 0
SELECT quantity FROM superstore WHERE quantity<=0;-- No rows
-- Discount outside 0–1
SELECT discount FROM superstore 
WHERE discount < 0 AND discount> 1;-- No rows
-- Ship Date < Order Date
SELECT ship_date,order_date FROM superstore 
WHERE ship_date < order_date;-- No rows
-- Profit < 0
SELECT profit FROM superstore WHERE profit<0;-- (Yes less 0 also 0 is avilable for empty string)

-- Duplicate Checking
SELECT order_id,COUNT(*)
FROM superstore
GROUP BY order_id
HAVING COUNT(*)>1;

SELECT order_id, product_id, COUNT(*) AS line_count
FROM superstore
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

SELECT *
FROM superstore
WHERE order_id = 'US-2016-123750'
  AND product_id = 'TEC-AC-10004659';

-- SQL Business Analysis
-- Total Orders
SELECT COUNT(DISTINCT order_id)
AS 'Total Orders'
FROM superstore;
-- Total Customers
SELECT COUNT(DISTINCT customer_id )
AS 'Total Customers'
FROM superstore;
-- Total Sales
SELECT SUM(sales) AS 'Total Sales'
FROM superstore;
-- Total Profit
SELECT SUM(profit) AS 'Total Profit'
FROM superstore;
-- Total Quantity Sold
SELECT ROUND(SUM(quantity),2) AS 'Total Quantity'
FROM superstore;
-- Average Order Value 
SELECT ROUND(SUM(sales)/COUNT(DISTINCT order_id),2)
AS "Avg Order Value" FROM superstore;
-- Profit Margin (%)
SELECT ROUND((SUM(profit)/SUM(sales))*100,2) 
AS 'Profit Margin(%)' FROM superstore;
-- Average Profit Per Order
SELECT ROUND(SUM(profit)/COUNT(DISTINCT order_id),2)
AS 'Average Profit Per Order' FROM superstore;
-- SQL query that returns all 8 KPIs in a single result table.
SELECT 
    COUNT(DISTINCT order_id) AS Total_Orders,
    COUNT(DISTINCT customer_id) AS Total_Customers,
    ROUND(SUM(sales),2) AS Total_Sales,
    ROUND(SUM(profit),2) AS Total_Profit,
    SUM(quantity) AS Total_Quantity,
    ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) AS Avg_Order_Value,
    ROUND((SUM(profit)/SUM(sales))*100,2) AS Profit_Margin_Percent,
    ROUND(SUM(profit)/COUNT(DISTINCT order_id),2) AS Avg_Profit_Per_Order
FROM superstore;

-- Sales Trend Analysis
SELECT * FROM superstore
LIMIT 5;
-- Monthly Sales Trend
SELECT 
    YEAR(order_date) AS order_year,
    MONTHNAME(order_date) AS order_month,
    ROUND(SUM(sales),2) AS monthly_sales
FROM superstore
GROUP BY YEAR(order_date), MONTHNAME(order_date),MONTH(order_date)
ORDER BY order_year, MONTH(order_date);
-- Monthly Profit Trend
SELECT 
	YEAR(order_date) AS year_name,
    MONTHNAME(order_date) AS month_name,
    ROUND(SUM(profit),2) AS monthly_profit
FROM superstore
GROUP BY YEAR(order_date),MONTHNAME(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date);
-- Yearly Sales Trend
SELECT 
	YEAR(order_date) AS year_name,
	ROUND(SUM(sales),2) AS sales_amount
FROM superstore
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);
-- Yearly Profit Trend
SELECT 
	YEAR(order_date) AS year_name,
	ROUND(SUM(profit),2) AS profit_amount
FROM superstore
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);
-- Best Sales Month
SELECT 
    YEAR(order_date) AS year_name,
    MONTHNAME(order_date) AS best_sales_month,
    ROUND(SUM(sales),2) AS monthly_sales
FROM superstore
GROUP BY YEAR(order_date), MONTHNAME(order_date)
ORDER BY monthly_sales DESC
LIMIT 1;
-- AND Worst Sales Month
SELECT 
    YEAR(order_date) AS year_name,
    MONTHNAME(order_date) AS worst_sales_month,
    ROUND(SUM(sales),2) AS monthly_sales
FROM superstore
GROUP BY YEAR(order_date), MONTHNAME(order_date)
ORDER BY monthly_sales 
LIMIT 1;

-- Best Sales Year
SELECT 
	YEAR(order_date) AS best_year_name,
	ROUND(SUM(sales),2) AS sales_amount
FROM superstore
GROUP BY YEAR(order_date)
ORDER BY SUM(sales) DESC
LIMIT 1;
-- Growth Rate (Month-over-Month)
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    MONTHNAME(order_date) AS month_name,
    ROUND(SUM(sales),2) AS monthly_sales,
    ROUND(
        (
            (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)))
            / LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date), MONTH(order_date))
        ) * 100, 2
    ) AS mom_growth_percent
FROM superstore
GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date)
ORDER BY order_year, order_month;
-- Growth Rate (Year-over-Year)
SELECT 
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales),2) AS yearly_sales,
    ROUND(
        (
            (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)))
            / LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date))
        ) * 100, 2
    ) AS yoy_growth_percent
FROM superstore
GROUP BY YEAR(order_date)
ORDER BY order_year;
-- Running Total Sales
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    MONTHNAME(order_date) AS month_name,
    ROUND(SUM(sales),2) AS monthly_sales,
    ROUND(
        SUM(SUM(sales)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)),2
    ) AS running_total_sales
FROM superstore
GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date)
ORDER BY order_year, order_month;

-- Category & Sub-Category Analysis
CREATE VIEW category_sales AS
SELECT 
    category,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY category;
-- Highest Sales Category
SELECT category,total_sales
FROM category_sales
ORDER BY total_sales DESC LIMIT 1;
-- Highest Profit Category
SELECT category,total_profit
FROM category_sales
ORDER BY total_profit DESC LIMIT 1;
-- Lowest Profit Category
SELECT category,total_profit
FROM category_sales
ORDER BY total_profit LIMIT 1;
-- Category-wise Sales % and Category-wise Profit %
SELECT 
    category,
    ROUND((total_sales / (SELECT SUM(total_sales) FROM category_sales)) * 100,2) AS sales_percent,
    ROUND((total_profit / (SELECT SUM(total_profit) FROM category_sales)) * 100,2) AS profit_percent
FROM category_sales
ORDER BY sales_percent DESC;
-- Average Profit per Category
SELECT category,ROUND(AVG(profit) ,2)AS avg_profit_per_category
FROM superstore
GROUP BY category;
-- Profit Margin by Category
SELECT category,
ROUND((total_profit/total_sales)*100,2) AS profit_margin
FROM category_sales
ORDER BY profit_margin DESC;

CREATE VIEW sub_category_sales AS 
	SELECT sub_category,
		   SUM(sales) AS sub_cat_sales,
           SUM(profit) AS sub_cat_profit,
		   COUNT(*) AS order_count
	FROM superstore
    GROUP BY sub_category;

-- Highest Sales Sub-Category
SELECT sub_category,sub_cat_sales
FROM sub_category_sales
ORDER BY sub_cat_sales DESC LIMIT 1;
-- Lowest Sales Sub-Category
SELECT sub_category,sub_cat_sales
FROM sub_category_sales
ORDER BY sub_cat_sales LIMIT 1;
-- Most Ordered Sub-Category
SELECT sub_category,order_count
FROM sub_category_sales
ORDER BY order_count DESC LIMIT 1;

-- Regional Analysis
CREATE VIEW region_wise_sale AS
SELECT region,
SUM(sales) AS region_sales,
SUM(profit) AS region_profit,
COUNT(*) AS order_count
FROM superstore
GROUP BY region;
-- Region-wise Sales
SELECT region,region_sales
FROM region_wise_sale
ORDER BY region_sales DESC;
-- Region-wise Profit
SELECT region,region_profit
FROM region_wise_sale
ORDER BY region_profit DESC;
-- Best Performing Region
SELECT region,region_sales
FROM region_wise_sale
ORDER BY region_sales DESC LIMIT 1;
-- Worst Performing Region
SELECT region,region_profit
FROM region_wise_sale
ORDER BY region_profit LIMIT 1;
-- Profit Margin by Region 
SELECT region,
ROUND((region_profit/region_sales)*100,2) AS profit_margin_by_region
FROM region_wise_sale
ORDER BY profit_margin_by_region DESC;

-- Customer Analysis
-- Top 10 Customers by Sales
SELECT customer_name,SUM(sales) AS sales_amount
FROM superstore
GROUP BY customer_name 
ORDER BY SUM(sales) DESC LIMIT 10;
-- Top 10 Customers by Profit
SELECT customer_name,SUM(profit) AS profit_amount
FROM superstore
GROUP BY customer_name 
ORDER BY SUM(profit) DESC LIMIT 10;
-- Customers with Negative Profit(loss-making customers:)
SELECT customer_name,SUM(profit) AS profit_amount
FROM superstore
GROUP BY customer_name 
HAVING SUM(profit)<0
ORDER BY SUM(profit);
-- Average Sales per Customer
-- Step 1: Total sales per customer
WITH customer_totals AS (
    SELECT 
        customer_name,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY customer_name
)
SELECT ROUND(AVG(total_sales),2) AS avg_sales_per_customer
FROM customer_totals;
-- Product Analysis
-- Top 10 Products by Sales
SELECT product_name,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY product_name 
ORDER BY SUM(sales) DESC LIMIT 10;
-- Top 10 Products by Profit
SELECT product_name,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY product_name 
ORDER BY SUM(profit) DESC LIMIT 10;
-- Bottom 10 Products by Profit
SELECT product_name,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY product_name 
ORDER BY SUM(profit) LIMIT 10;
-- Most top 10 Sold Products
SELECT product_name,
SUM(quantity) AS total_sold
FROM superstore
GROUP BY product_name 
ORDER BY SUM(quantity) DESC LIMIT 10;
-- Average Profit per Product (Top 10)
SELECT product_name,
ROUND(AVG(profit),2) AS avg_profit_per_product
FROM superstore
GROUP BY product_name
ORDER BY avg_profit_per_product DESC
LIMIT 10;
-- Shipping Mode Analysis
-- Sales by Ship Mode
SELECT ship_mode,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY ship_mode
ORDER BY SUM(sales) DESC;
-- Profit by Ship Mode
SELECT ship_mode,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY ship_mode
ORDER BY SUM(profit) DESC;
-- Average Delivery Time (Days)
SELECT ROUND(AVG(DATEDIFF(ship_date, order_date)),2)
AS avg_delivery_time_days
FROM superstore;
-- Which Ship Mode is the most profitable?
SELECT ship_mode,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY ship_mode
ORDER BY SUM(profit) DESC LIMIT 1;
-- Which ship mode has the highest profit margin?
SELECT ship_mode,
ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin
FROM superstore
GROUP BY ship_mode 
ORDER BY profit_margin DESC
LIMIT 1;
-- Which ship mode has the fastest average delivery time?
SELECT ship_mode,ROUND(AVG(DATEDIFF(ship_date, order_date)),2)
AS avg_delivery_time_days
FROM superstore
GROUP BY ship_mode ORDER BY avg_delivery_time_days LIMIT 1 ;
-- Discount Analysis
-- Average Discount by Category
SELECT category,ROUND(AVG(discount),2) AS avg_discount
FROM superstore
GROUP BY category
ORDER BY AVG(discount);
-- Total Sales by Discount Level
SELECT discount,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY discount
ORDER BY discount;
-- Total Profit by Discount Level.
SELECT discount,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY discount
ORDER BY discount;
-- Which discount level generates the highest profit?
SELECT discount,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY discount
ORDER BY total_profit DESC
LIMIT 1;
-- Does increasing the discount always increase sales?
SELECT discount,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY discount
ORDER BY discount;
-- Top 3 Products in Each Category
WITH product_sales AS (
    SELECT 
        category,
        product_name,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY category, product_name
)
SELECT 
    category,
    product_name,
    ROUND(total_sales,2) AS total_sales
FROM (
    SELECT 
        category,
        product_name,
        total_sales,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_sales DESC) AS rn
    FROM product_sales
) ranked
WHERE rn <= 3
ORDER BY category, total_sales DESC;
-- Top 3 Products by Profit in each Category
WITH product_profit AS (
    SELECT 
        category,
        product_name,
        SUM(profit) AS total_profit
    FROM superstore
    GROUP BY category, product_name
)
SELECT 
    category,
    product_name,
    ROUND(total_profit,2) AS total_profit
FROM (
    SELECT 
        category,
        product_name,
        total_profit,
        RANK() OVER (PARTITION BY category ORDER BY total_profit DESC) AS rnk
    FROM product_profit
) ranked
WHERE rnk <= 3
ORDER BY category, total_profit DESC;
-- Top 3 Customers by Sales in each Region
WITH customer_sales AS (
    SELECT 
        region,
        customer_name,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY region, customer_name
)
SELECT 
    region,
    customer_name,
    ROUND(total_sales,2) AS total_sales
FROM (
    SELECT 
        region,
        customer_name,
        total_sales,
        DENSE_RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rnk
    FROM customer_sales
) ranked
WHERE rnk <= 3
ORDER BY region, total_sales DESC;
-- Profit Contribution (%) by Category 
SELECT
    category,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(
        SUM(profit) * 100 /
        (SELECT SUM(profit) FROM superstore),
        2
    ) AS contribution_percent
FROM superstore
GROUP BY category
ORDER BY contribution_percent DESC;
-- Running Profit by Month
WITH monthly_profit AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(profit) AS monthly_profit
    FROM superstore
    GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT
    *,
    ROUND(
        SUM(monthly_profit) OVER(
            ORDER BY order_year, order_month
        ),
        2
    ) AS running_profit
FROM monthly_profit;
-- 3-Month Moving Average of Sales
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM superstore
    GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT
    *,
    ROUND(
        AVG(monthly_sales) OVER(
            ORDER BY order_year, order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_avg_3_month
FROM monthly_sales;
