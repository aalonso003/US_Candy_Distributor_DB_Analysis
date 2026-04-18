
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



-- 3. Total Sales per factory
SELECT F.FactoryName, SUM(S.Revenue) AS FactoryRevenue
FROM Sales S
JOIN Products P ON S.ProductID = P.ProductID
JOIN Factories F ON P.FactoryID = F.FactoryID
GROUP BY F.FactoryName
ORDER BY FactoryRevenue DESC;

/* 4- Creating A Factory Report by joining sales, products, and factories into a 
single analysis with multiple JOINS making it more accessible  */
GO
CREATE VIEW dbo.vFactoryReportV AS
SELECT S.OrderDate, SUM(S.Revenue) AS TotalRevenue, P.ProductName, F.FactoryName
FROM Sales S
INNER JOIN Products P  
    ON S.ProductID = P.ProductID
INNER JOIN Factories F
    ON p.FactoryID = F.FactoryID
GROUP BY S.OrderDate, P.ProductName, F.FactoryName
GO
;

SELECT * FROM vFactoryReportV;

 -- 5. Identify what are the best perfomance-based factories
SELECT F.FactoryName, COUNT(*) AS TotalSales
FROM Factories F
INNER JOIN Products P
    ON F.FactoryID = P.FactoryID
GROUP BY F.FactoryName
HAVING COUNT(*) > 3;


