-- ============================================================
-- QUERY 1. Total Revenue per Year
-- Goal: See YoY revenue for the Company
-- Skills:  GROUP BY, ORDER BY, aggregate functions
-- ============================================================
SELECT 
    CAST(YEAR(OrderDate) AS VARCHAR(4)) AS Year,
    SUM(Revenue) AS TotalRevenue
FROM Sales
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate);


-- ============================================================
-- QUERY 2: Top 5 Best-Selling Products by Revenue
-- Goal: Identify which individual products generate the most
--       revenue for the distributor.
-- Skills: JOIN, GROUP BY, ORDER BY, TOP
-- ============================================================
SELECT TOP 5
    p.ProductName,
    p.Division,
    SUM(s.UnitsSold)  AS TotalUnitsSold,
    SUM(s.Revenue)    AS TotalRevenue
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductName, p.Division
ORDER BY TotalRevenue DESC;



-- 3. Total Sales per factory
-- ============================================================
-- QUERY 3. Total Sales per factory
-- Goal: Identify the Total Sales per Factory
-- Skills: JOIN, GROUP BY, ORDER BY
-- ============================================================
SELECT F.FactoryName, SUM(S.Revenue) AS FactoryRevenue
FROM Sales S
JOIN Products P ON S.ProductID = P.ProductID
JOIN Factories F ON P.FactoryID = F.FactoryID
GROUP BY F.FactoryName
ORDER BY FactoryRevenue DESC;

