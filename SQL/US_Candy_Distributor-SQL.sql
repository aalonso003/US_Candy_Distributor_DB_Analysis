
-- 1. Total Revenue per Year
SELECT 
    CAST(YEAR(OrderDate) AS VARCHAR(4)) AS Year,
    SUM(Revenue) AS TotalRevenue
FROM Sales
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate);



-- 2. Top 5 selling products by revenue
SELECT TOP (5) P.ProductName, SUM(S.UnitsSold) AS TotalUnits, SUM(S.Revenue) AS TotalRevenue
FROM Sales S
JOIN Products P ON S.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalRevenue DESC;

