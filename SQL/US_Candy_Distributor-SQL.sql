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
-- QUERY 5: Factory Output Performance (VIEW)
-- Goal: Helps Track which Factories are responsible for the most distributed product volume
-- Skills: JOIN, GROUP BY, ORDER BY, CONCAT, COUNT
-- ============================================================
GO
CREATE VIEW vFactoryPerformance AS
SELECT 
    f.FactoryID,
    f.FactoryName,
    CONCAT(f.City, ', ', f.STATE) AS 'LOCATION',
    COUNT(s.SaleID) AS OrdersFulfilled,
    SUM(s.UnitsSold) AS TotalUnitsShipped
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
JOIN Factories f ON p.FactoryID = f.FactoryID
GROUP BY f.FactoryID,f.FactoryName, f.City, f.[State];

SELECT * FROM vFactoryPerformance
ORDER BY TotalUnitsShipped DESC;


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


-- ============================================================
-- QUERY 10: High-Value Customer Analysis (Subquery)
-- GOAL: Find customers whose total spending exceeds the
--       overall average order value — our most valuable accounts.
-- ============================================================
SELECT
    C.CustomerName,
    C.CustomerType,
    SUM(S.Revenue)                        AS TotalSpend,
    COUNT(S.SaleID)                        AS TotalOrders,
    CAST(AVG(S.Revenue) AS DECIMAL(10,2)) AS AvgOrderValue
FROM Customers C
INNER JOIN Sales S ON C.CustomerID = S.CustomerID
GROUP BY C.CustomerID, C.CustomerName, C.CustomerType
HAVING SUM(S.Revenue) > (
    -- Subquery: average total spend per customer
    SELECT AVG(CustomerTotal)
    FROM (
        SELECT SUM(Revenue) AS CustomerTotal
        FROM Sales
        GROUP BY CustomerID
    ) AS AvgSubquery
)
ORDER BY TotalSpend DESC;



-- ============================================================
-- QUERY 11: Monthly Sales Snapshot (Variable)
-- Goal: Pull all sales for a specific month and year using
--       a variable so the query can be reused without
--       rewriting the filter every time.
-- Skills: DECLARE, WHERE with YEAR/MONTH, JOIN, GROUP BY
-- ============================================================
DECLARE @TargetMonth INT = 3;
DECLARE @TargetYear  INT = 2024;

SELECT
    p.ProductName,
    p.Division,
    f.FactoryName,
    SUM(s.UnitsSold) AS UnitsSold,
    SUM(s.Revenue)   AS MonthRevenue
FROM Sales s
JOIN Products  p ON s.ProductID = p.ProductID
JOIN Factories f ON p.FactoryID = f.FactoryID
WHERE MONTH(s.OrderDate) = @TargetMonth
  AND YEAR(s.OrderDate)  = @TargetYear
GROUP BY p.ProductName, p.Division, f.FactoryName
ORDER BY MonthRevenue DESC;


-- ============================================================
-- QUERY 12: Stored Procedure for High-Value Purchase Orders
-- Goal: Create a reusable stored procedure that returns all
--       purchase orders above a specified minimum amount and
--       classifies them as "VIP Customer" or "Regular Customer" based on
--       their total amount spent.
-- Skills: CREATE PROCEDURE, parameters, CASE statement, JOIN
-- ============================================================
GO
CREATE PROCEDURE CustomerVIPStatus
    @CustomerID INT
AS
BEGIN
    DECLARE @TotalSpent DECIMAL(18, 2);
    SELECT @TotalSpent = SUM(S.Revenue)
    FROM Sales S
    INNER JOIN Customers C ON S.CustomerID = C.CustomerID
    WHERE C.CustomerID = @CustomerID;
IF @TotalSpent >= 500
    BEGIN
        SELECT C.CustomerID, 
               C.CustomerName,
               @TotalSpent AS TotalSpent,
               'VIP Customer' AS Status
        FROM Customers C
        INNER JOIN Sales S ON C.CustomerID = S.CustomerID
        WHERE C.CustomerID = @CustomerID
        GROUP BY c.CustomerID, c.CustomerName;
    END
ELSE
    BEGIN
        SELECT C.CustomerID, 
               C.CustomerName,
               @TotalSpent AS TotalSpent,               
               'Regular Customer' AS Status
        FROM Customers C
        INNER JOIN Sales S ON C.CustomerID = S.CustomerID
        WHERE C.CustomerID =3
        GROUP BY c.CustomerID, c.CustomerName;
    END
END;
GO

EXEC CustomerVIPStatus @CustomerID = 9;
