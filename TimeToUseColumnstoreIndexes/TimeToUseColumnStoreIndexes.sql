USE AdventureWorks
GO

--setup after running make_big_adventure
CREATE TABLE dbo.TransactionHistoryCS
(
    TransactionID INT NOT NULL,
    ProductID INT NOT NULL,
    TransactionDate DATETIME NULL,
    Quantity INT NULL,
    ActualCost MONEY NULL,
    INDEX TransactionHistoryClusteredColumnStore CLUSTERED COLUMNSTORE
);
GO

INSERT INTO dbo.TransactionHistoryCS
(
    TransactionID,
    ProductID,
    TransactionDate,
    Quantity,
    ActualCost
)
SELECT bth.TransactionID,
       bth.productid,
       bth.transactiondate,
       bth.quantity,
       bth.actualcost
FROM dbo.bigTransactionHistory AS bth;
GO



--SELECT COUNT(*)
--Kids, don't try this at home
--I'm a professional

SELECT COUNT(*) FROM dbo.bigTransactionHistory AS bth



SELECT COUNT(*) FROM dbo.TransactionHistoryCS AS thc















--even on small tables
SELECT  p.Name,
        COUNT(th.ProductID) AS CountProductID,
        SUM(th.Quantity) AS SumQuantity,
        AVG(th.ActualCost) AS AvgActualCost
FROM    Production.TransactionHistory AS th
JOIN    Production.Product AS p
        ON p.ProductID = th.ProductID
GROUP BY th.ProductID,
        p.Name;





CREATE NONCLUSTERED COLUMNSTORE INDEX ix_csTest
ON Production.TransactionHistory
(ProductID,
Quantity,
ActualCost);





SELECT  p.Name,
        COUNT(th.ProductID) AS CountProductID,
        SUM(th.Quantity) AS SumQuantity,
        AVG(th.ActualCost) AS AvgActualCost
FROM    Production.TransactionHistory AS th
JOIN    Production.Product AS p
        ON p.ProductID = th.ProductID
GROUP BY th.ProductID,
        p.Name
--OPTION  (QUERYTRACEON 8649);
--Needed for 2012, 2014 to get parallel execution
--Undocumented, so testing is #1


--cleanup
DROP INDEX Production.TransactionHistory.ix_csTest;





--an aggregate query


WITH AggProduct
AS (SELECT bp.ProductID,
           SUM(bth.Quantity) AS TotalQuantity,
           SUM(bth.ActualCost) AS TotalCost
    FROM dbo.bigProduct AS bp
        JOIN dbo.bigTransactionHistory AS bth
            ON bth.ProductID = bp.ProductID
    GROUP BY bp.ProductID
    HAVING SUM(bth.ActualCost) > 0)
SELECT p.Name,
       ap.TotalQuantity,
       ap.TotalCost,
       ps.Name,
       pc.Name
FROM AggProduct AS ap
    JOIN dbo.bigProduct AS p
        ON p.ProductID = ap.ProductID
    JOIN Production.ProductSubcategory AS ps
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON pc.ProductCategoryID = ps.ProductCategoryID;



--Same one against the columnstore table
WITH AggProduct
AS (SELECT bp.ProductID,
           SUM(bth.Quantity) AS TotalQuantity,
           SUM(bth.ActualCost) AS TotalCost
    FROM dbo.bigProduct AS bp
        JOIN dbo.TransactionHistoryCS AS bth
            ON bth.ProductID = bp.ProductID
    GROUP BY bp.ProductID
    HAVING SUM(bth.ActualCost) > 0)
SELECT p.Name,
       ap.TotalQuantity,
       ap.TotalCost,
       ps.Name,
       pc.Name
FROM AggProduct AS ap
    JOIN dbo.bigProduct AS p
        ON p.ProductID = ap.ProductID
    JOIN Production.ProductSubcategory AS ps
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON pc.ProductCategoryID = ps.ProductCategoryID;







--what if we filter?

WITH AggProduct
AS (SELECT bp.ProductID,
           SUM(bth.Quantity) AS TotalQuantity,
           SUM(bth.ActualCost) AS TotalCost
    FROM dbo.bigProduct AS bp
        JOIN dbo.bigTransactionHistory AS bth
            ON bth.ProductID = bp.ProductID
    GROUP BY bp.ProductID
    HAVING SUM(bth.ActualCost) > 0)
SELECT p.Name,
       ap.TotalQuantity,
       ap.TotalCost,
       ps.Name,
       pc.Name
FROM AggProduct AS ap
    JOIN dbo.bigProduct AS p
        ON p.ProductID = ap.ProductID
    JOIN Production.ProductSubcategory AS ps
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON pc.ProductCategoryID = ps.ProductCategoryID
WHERE ap.TotalQuantity > 105000;






WITH AggProduct
AS (SELECT bp.ProductID,
           SUM(bth.Quantity) AS TotalQuantity,
           SUM(bth.ActualCost) AS TotalCost
    FROM dbo.bigProduct AS bp
        JOIN dbo.TransactionHistoryCS AS bth
            ON bth.ProductID = bp.ProductID
    GROUP BY bp.ProductID
    HAVING SUM(bth.ActualCost) > 0)
SELECT p.Name,
       ap.TotalQuantity,
       ap.TotalCost,
       ps.Name,
       pc.Name
FROM AggProduct AS ap
    JOIN dbo.bigProduct AS p
        ON p.ProductID = ap.ProductID
    JOIN Production.ProductSubcategory AS ps
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON pc.ProductCategoryID = ps.ProductCategoryID
		WHERE ap.TotalQuantity > 105000;











--maintenance
--check data distribution
SELECT i.name,
       i.object_id,
       i.index_id,
       ddcsrgps.partition_number,
       ddcsrgps.row_group_id,
       ddcsrgps.delta_store_hobt_id,
       ddcsrgps.state,
       ddcsrgps.state_desc,
       ddcsrgps.total_rows,
       ddcsrgps.deleted_rows,
       ddcsrgps.size_in_bytes
FROM sys.dm_db_column_store_row_group_physical_stats AS ddcsrgps
    JOIN sys.indexes AS i
        ON i.object_id = ddcsrgps.object_id
ORDER BY i.name,
         ddcsrgps.row_group_id ASC;



--check fragmentation
SELECT OBJECT_NAME(p.object_id) AS TableName,
       p.partition_number AS Partition,
       CAST(AVG((rg.deleted_rows * 1. / rg.total_rows) * 100) AS DECIMAL(5, 2)) AS 'Total Fragmentation (Percentage)',
       SUM(   CASE rg.deleted_rows
                  WHEN rg.total_rows THEN
                      1
                  ELSE
                      0
              END
          ) AS 'Deleted Segments Count',
       CAST((SUM(   CASE rg.deleted_rows
                        WHEN rg.total_rows THEN
                            1
                        ELSE
                            0
                    END
                ) * 1. / COUNT(*)
            ) * 100 AS DECIMAL(5, 2)) AS 'DeletedSegments (Percentage)'
FROM sys.partitions AS p
    INNER JOIN sys.column_store_row_groups rg
        ON p.object_id = rg.object_id
WHERE rg.state = 3 -- Compressed (Ignoring: 0 - Hidden, 1 - Open, 2 - Closed, 4 - Tombstone) 
GROUP BY p.object_id,
         p.partition_number
ORDER BY OBJECT_NAME(p.object_id);