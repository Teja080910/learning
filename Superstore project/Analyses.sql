USE sales_db;
SELECT * FROM sales_data;
SELECT 
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(AVG(`Profit Margin`), 4) AS Avg_Profit_Margin
FROM sales_data;

SELECT 
    DATE_FORMAT(`Order Date`, '%Y-%m') AS Month,
    ROUND(SUM(Sales), 2) AS Monthly_Sales,
    ROUND(SUM(Profit), 2) AS Monthly_Profit
FROM sales_data
GROUP BY Month
ORDER BY Month;

SELECT 
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(AVG(`Profit Margin`), 4) AS Avg_Profit_Margin
FROM sales_data
GROUP BY Region
ORDER BY Total_Profit;

SELECT 
    `Product Name`,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM sales_data
GROUP BY `Product Name`
ORDER BY Total_Profit DESC
LIMIT 10;

SELECT 
    Discount,
    COUNT(*) AS Orders,
    ROUND(AVG(Profit), 2) AS Avg_Profit,
    ROUND(AVG(`Profit Margin`), 4) AS Avg_Profit_Margin
FROM sales_data
GROUP BY Discount
ORDER BY Discount;


