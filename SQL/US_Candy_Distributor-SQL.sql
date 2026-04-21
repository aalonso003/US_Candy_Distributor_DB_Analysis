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



-- ============================================================
-- QUERY 3: Total Revenue by Factory (Ranked)
-- GOAL: Rank factories by revenue contribution to spot
--       top performers and underperformers.
-- ============================================================
SELECT
    F.FactoryName,
    F.State,
    SUM(S.Revenue)       AS FactoryRevenue,
    COUNT(DISTINCT S.ProductID) AS UniqueProductsSold
FROM Sales S
INNER JOIN Products P  ON S.ProductID = P.ProductID
INNER JOIN Factories F ON P.FactoryID = F.FactoryID
GROUP BY F.FactoryName, F.State
ORDER BY FactoryRevenue DESC;




-- ============================================================
-- QUERY 4: Total Revenue by Product Division
-- Goal: Which candy division (Chocolate, Sugar, Other) drives
--       the most revenue?
-- Skills: JOIN, GROUP BY, ORDER BY, aggregate functions
-- ============================================================
SELECT
    p.Division,
    COUNT(s.SaleID)            AS TotalOrders,
    SUM(s.UnitsSold)           AS TotalUnitsSold,
    SUM(s.Revenue)             AS TotalRevenue,
    AVG(s.Revenue)             AS AvgRevenuePerSale
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.Division
ORDER BY TotalRevenue DESC;



-- ============================================================
-- QUERY 5: Top 10 Best-Selling Products by Revenue
-- Goal: Identify which individual products generate the most
--       revenue for the distributor.
-- Skills: JOIN, GROUP BY, ORDER BY, TOP
-- ============================================================
SELECT TOP 10
    p.ProductName,
    p.Division,
    SUM(s.UnitsSold)  AS TotalUnitsSold,
    SUM(s.Revenue)    AS TotalRevenue
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductName, p.Division
ORDER BY TotalRevenue DESC;



-- ============================================================
-- QUERY 6: Monthly Revenue vs. Sales Target by Division
-- Goal: Are divisions meeting their monthly sales targets?
--       Reveals over/under performance by month and division.
-- Skills: JOIN, GROUP BY, HAVING, calculated columns
-- ============================================================
SELECT
    st.Division,
    st.TargetMonth,
    st.TargetAmount,
    SUM(s.Revenue)                                  AS ActualRevenue,
    SUM(s.Revenue) - st.TargetAmount                AS Variance,
    ROUND((SUM(s.Revenue) / st.TargetAmount) * 100, 1) AS PctOfTarget
FROM SalesTargets st
JOIN Products p   ON st.Division = p.Division
JOIN Sales s      ON p.ProductID  = s.ProductID
               AND  YEAR(s.OrderDate)  = YEAR(st.TargetMonth)
               AND  MONTH(s.OrderDate) = MONTH(st.TargetMonth)
GROUP BY st.Division, st.TargetMonth, st.TargetAmount
HAVING SUM(s.Revenue) < st.TargetAmount   -- only show months that MISSED target
ORDER BY st.TargetMonth, st.Division;



-- ============================================================
-- QUERY 7: Customer Type Revenue Breakdown
-- Goal: Compare total spend across Retailer, Wholesaler, and
--       Specialty customer types to guide sales strategy.
-- Skills: JOIN, GROUP BY, ORDER BY, aggregate + calculated column
-- ============================================================
SELECT
    c.CustomerType,
    COUNT(DISTINCT c.CustomerID)   AS NumCustomers,
    COUNT(s.SaleID)                AS TotalTransactions,
    SUM(s.Revenue)                 AS TotalRevenue,
    ROUND(SUM(s.Revenue) / COUNT(DISTINCT c.CustomerID), 2) AS RevenuePerCustomer
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerType
ORDER BY TotalRevenue DESC;


-- ============================================================
-- QUERY 8 (revised): Slow-Moving Products by Factory
-- Goal: Identify which products have the lowest sales volume,
--       and which factory supplies them. Helps the distributor
--       spot underperforming products that may need promotion
--       or discontinuation.
-- Skills: JOIN (3 tables), GROUP BY, ORDER BY, TOP
-- ============================================================
SELECT TOP 10
    p.ProductName,
    p.Division,
    f.FactoryName,
    f.City,
    f.State,
    SUM(s.UnitsSold)  AS TotalUnitsSold,
    SUM(s.Revenue)    AS TotalRevenue
FROM Sales s
JOIN Products  p ON s.ProductID = p.ProductID
JOIN Factories f ON p.FactoryID = f.FactoryID
GROUP BY p.ProductName, p.Division, f.FactoryName, f.City, f.State
ORDER BY TotalUnitsSold ASC;


-- ============================================================
-- QUERY 9: Factory Output & Profitability
-- Goal: Rank factories by the revenue their products generate
--       and evaluate gross profit margin on their product lines.
-- Skills: JOIN (3 tables), GROUP BY, ORDER BY,
--         aggregate functions, calculated margin column
-- ============================================================
SELECT
    f.FactoryName,
    f.City,
    f.State,
    COUNT(DISTINCT p.ProductID)                              AS ProductsSupplied,
    SUM(s.UnitsSold)                                         AS TotalUnitsSold,
    SUM(s.Revenue)                                           AS TotalRevenue,
    SUM(s.UnitsSold * p.UnitCost)                            AS TotalCOGS,
    SUM(s.Revenue) - SUM(s.UnitsSold * p.UnitCost)          AS GrossProfit,
    ROUND(
        (SUM(s.Revenue) - SUM(s.UnitsSold * p.UnitCost))
        / SUM(s.Revenue) * 100, 1
    )                                                        AS GrossMarginPct
FROM Sales s
JOIN Products  p ON s.ProductID  = p.ProductID
JOIN Factories f ON p.FactoryID  = f.FactoryID
GROUP BY f.FactoryName, f.City, f.State
ORDER BY GrossProfit DESC;
