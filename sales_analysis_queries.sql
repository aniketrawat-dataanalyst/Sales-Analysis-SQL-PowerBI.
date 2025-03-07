-- Data Cleaning Queries

-- Remove duplicate transactions
DELETE FROM sales
WHERE Transaction_ID IN (
    SELECT Transaction_ID FROM (
        SELECT Transaction_ID, ROW_NUMBER() OVER(PARTITION BY Transaction_ID ORDER BY Date) AS rn
        FROM sales
    ) t WHERE rn > 1
);

-- Handle missing profit values by setting them to 0
UPDATE sales
SET Profit = COALESCE(Profit, 0);

-- Ensure Date column is in DATE format
ALTER TABLE sales
ALTER COLUMN Date TYPE DATE USING Date::DATE;

-- Sales Analysis Queries

-- 1. Total Sales & Profit per Month
SELECT 
    DATE_TRUNC('month', Date) AS Month, 
    SUM(Sales_Amount) AS Total_Sales, 
    SUM(Profit) AS Total_Profit
FROM sales
GROUP BY Month
ORDER BY Month;

-- 2. Top 5 Best-Selling Products
SELECT 
    p.Category, 
    p.Sub_Category, 
    SUM(s.Quantity) AS Total_Units_Sold, 
    SUM(s.Sales_Amount) AS Revenue
FROM sales s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Category, p.Sub_Category
ORDER BY Revenue DESC
LIMIT 5;

-- 3. Customer Segments with Highest Spending
SELECT 
    c.Customer_Segment, 
    COUNT(s.Customer_ID) AS Total_Customers, 
    SUM(s.Sales_Amount) AS Total_Revenue
FROM sales s
JOIN customers c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY Total_Revenue DESC;

-- 4. Regional Sales Performance
SELECT 
    r.Region_Name, 
    COUNT(s.Transaction_ID) AS Total_Transactions, 
    SUM(s.Sales_Amount) AS Total_Sales,
    SUM(s.Profit) AS Total_Profit,
    ROUND((SUM(s.Sales_Amount)/r.Sales_Target) * 100, 2) AS Sales_Target_Percentage
FROM sales s
JOIN regions r ON s.Region_ID = r.Region_ID
GROUP BY r.Region_Name, r.Sales_Target
ORDER BY Total_Sales DESC;

-- 5. Cumulative Sales Trend using Window Functions
SELECT 
    Date, 
    SUM(Sales_Amount) OVER(ORDER BY Date) AS Cumulative_Sales
FROM sales;
