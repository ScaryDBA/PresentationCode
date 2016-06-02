--Reading Execution Plans

-- Query #1
SELECT  *
FROM    dbo.ErrorLog AS el

























--Query #2
SELECT  soh.AccountNumber,
        s.Name AS StoreName,
        soh.OrderDate,
        p.Name AS ProductName,
        sod.OrderQty,
        sod.UnitPrice,
        sod.LineTotal
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Sales.Customer AS c
        ON soh.CustomerID = c.CustomerID
        JOIN Sales.Store AS s
        ON c.StoreID = s.BusinessEntityID
        JOIN Production.Product AS p
        ON sod.ProductID = p.ProductID ;















--Query #3
SELECT  soh.AccountNumber,
        s.Name AS StoreName,
        soh.OrderDate,
        p.Name AS ProductName,
        sod.OrderQty,
        sod.UnitPrice,
        sod.LineTotal
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Sales.Customer AS c
        ON soh.CustomerID = c.CustomerID
        JOIN Sales.Store AS s
        ON c.StoreID = s.BusinessEntityID
        JOIN Production.Product AS p
        ON sod.ProductID = p.ProductID
WHERE   sod.ProductID = 921 ;














--Query #4
BEGIN TRAN

INSERT  Person.Address
        (AddressLine1,
         AddressLine2,
         City,
         StateProvinceID,
         PostalCode,
         SpatialLocation,
         rowguid,
         ModifiedDate
        )
VALUES  (N'1313 Mockingbird Lane', -- AddressLine1 - nvarchar(60)
         NULL, -- AddressLine2 - nvarchar(60)
         N'Springfield', -- City - nvarchar(30)
         30, -- StateProvinceID - int
         N'02134', -- PostalCode - nvarchar(15)
         NULL, -- SpatialLocation - geography
         NEWID(), -- rowguid - uniqueidentifier
         '2011-08-12 21:57:43'  -- ModifiedDate - datetime
        )

ROLLBACK TRAN



















--Query #5
BEGIN TRAN

UPDATE  Production.Product
SET     DaysToManufacture = 42
WHERE   ProductID = 784

ROLLBACK





















--Query #6
--Delete
BEGIN TRAN

DELETE  FROM Production.Product
WHERE   ProductID = 3343

ROLLBACK TRAN





















--Query #7
SELECT  ve.FirstName,
        ve.LastName,
        ve.BusinessEntityID
FROM    HumanResources.vEmployee AS ve
WHERE   ve.BusinessEntityID = 221














--Full view
SELECT  *
FROM    HumanResources.vEmployee AS ve
WHERE   ve.BusinessEntityID = 221



















-- Tuning Execution Plans

-- Missing indexes
--straight from BOL
SELECT  mig.*,
        mid.statement AS table_name,
        column_id,
        column_name,
        column_usage
FROM    sys.dm_db_missing_index_details AS mid
        CROSS APPLY sys.dm_db_missing_index_columns(mid.index_handle)
        INNER JOIN sys.dm_db_missing_index_groups AS mig
        ON mig.index_handle = mid.index_handle
WHERE   mid.database_id = DB_ID('AdventureWorks2008R2')
ORDER BY mig.index_group_handle,
        mig.index_handle,
        column_id ;













--Not from BOL
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan'
    AS sp)
SELECT  p.query_plan.value(N'(sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/@Database)[1]',
                           'NVARCHAR(256)') AS DatabaseName
       ,dest.text AS QueryText
       ,s.total_elapsed_time
       ,s.last_execution_time
       ,s.execution_count
       ,s.total_logical_writes
       ,s.total_logical_reads
       ,s.min_elapsed_time
       ,s.max_elapsed_time
       ,p.query_plan
       ,p.query_plan.value(N'(sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/@Table)[1]',
                           'NVARCHAR(256)') AS TableName
       ,p.query_plan.value(N'(/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/@Schema)[1]',
                           'NVARCHAR(256)') AS SchemaName
       ,p.query_plan.value(N'(/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/@Impact)[1]',
                           'DECIMAL(6,4)') AS ProjectedImpact
       ,ColumnGroup.value('./@Usage', 'NVARCHAR(256)') AS ColumnGroupUsage
       ,ColumnGroupColumn.value('./@Name', 'NVARCHAR(256)') AS ColumnName
FROM    sys.dm_exec_query_stats s
        CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) AS p
        CROSS APPLY p.query_plan.nodes('/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/sp:ColumnGroup')
        AS t1 (ColumnGroup)
        CROSS APPLY t1.ColumnGroup.nodes('./sp:Column') AS t2 (ColumnGroupColumn)
        CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS dest
WHERE   p.query_plan.exist(N'/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan//sp:MissingIndexes') = 1
AND p.query_plan.value(N'(sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/@Database)[1]',
                           'NVARCHAR(256)') = 'AdventureWorks2008R2'













--DMVs and costs

CREATE FUNCTION dbo.SalesInfo ()
RETURNS @return_variable TABLE (
     SalesOrderID INT,
     OrderDate DATETIME,
     SalesPersonID INT,
     PurchaseOrderNumber dbo.OrderNumber,
     AccountNumber dbo.AccountNumber,
     ShippingCity NVARCHAR(30)
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                (SalesOrderID,
                 OrderDate,
                 SalesPersonID,
                 PurchaseOrderNumber,
                 AccountNumber,
                 ShippingCity
                )
                SELECT  soh.SalesOrderID,
                        soh.OrderDate,
                        soh.SalesPersonID,
                        soh.PurchaseOrderNumber,
                        soh.AccountNumber,
                        a.City
                FROM    Sales.SalesOrderHeader AS soh
                        JOIN Person.Address AS a
                        ON soh.ShipToAddressID = a.AddressID ;
        RETURN ;
    END ;


CREATE FUNCTION dbo.SalesDetails ()
RETURNS @return_variable TABLE (
     SalesOrderID INT,
     SalesOrderDetailID INT,
     OrderQty SMALLINT,
     UnitPrice MONEY
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                (SalesOrderID,
                 SalesOrderDetailId,
                 OrderQty,
                 UnitPrice
                )
                SELECT  sod.SalesOrderID,
                        sod.SalesOrderDetailID,
                        sod.OrderQty,
                        sod.UnitPrice
                FROM    Sales.SalesOrderDetail AS sod ;
        RETURN ;
    END ;



CREATE FUNCTION dbo.CombinedSalesInfo ()
RETURNS @return_variable TABLE (
     SalesPersonID INT,
     ShippingCity NVARCHAR(30),
     OrderDate DATETIME,
     PurchaseOrderNumber dbo.OrderNumber,
     AccountNumber dbo.AccountNumber,
     OrderQty SMALLINT,
     UnitPrice MONEY
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                (SalesPersonId,
                 ShippingCity,
                 OrderDate,
                 PurchaseOrderNumber,
                 AccountNumber,
                 OrderQty,
                 UnitPrice
                )
                SELECT  si.SalesPersonID,
                        si.ShippingCity,
                        si.OrderDate,
                        si.PurchaseOrderNumber,
                        si.AccountNumber,
                        sd.OrderQty,
                        sd.UnitPrice
                FROM    dbo.SalesInfo() AS si
                        JOIN dbo.SalesDetails() AS sd
                        ON si.SalesOrderID = sd.SalesOrderID ;
        RETURN ;
    END ;



SELECT  csi.OrderDate,
        csi.PurchaseOrderNumber,
        csi.AccountNumber,
        csi.OrderQty,
        csi.UnitPrice
FROM    dbo.CombinedSalesInfo() AS csi
WHERE   csi.SalesPersonID = 277
        AND csi.ShippingCity = 'Odessa' ;










SELECT  soh.OrderDate,
        soh.PurchaseOrderNumber,
        soh.AccountNumber,
        sod.OrderQty,
        sod.UnitPrice
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Person.Address AS ba
        ON soh.BillToAddressID = ba.AddressID
        JOIN Person.Address AS sa
        ON soh.ShipToAddressID = sa.AddressID
WHERE   soh.SalesPersonID = 277
        AND sa.City = 'Odessa' ;





-- SCANS & SEEKS
SELECT  sod.SalesOrderDetailID
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID ;













SELECT  sod.SalesOrderDetailID
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE   soh.SalesOrderID = 58707 ;









-- row count

SELECT  soh.AccountNumber,
        soh.DueDate,
        soh.Freight,
        sod.LineTotal,
        sod.CarrierTrackingNumber
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE   soh.CustomerID = 11722





ALTER PROC dbo.spAddressByCity @City VARCHAR(30)
AS 
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City ;


ALTER DATABASE AdventureWorks2008R2
SET AUTO_UPDATE_STATISTICS OFF;




BEGIN TRAN

UPDATE Person.Address
SET City = 'Mentor'
WHERE City = 'London'

EXEC dbo.spAddressByCity @City = N'Mentor'
DBCC freeproccache


ROLLBACK TRAN

ALTER DATABASE AdventureWorks2008R2
SET AUTO_UPDATE_STATISTICS ON;






-- Bad Parameter Sniffing
EXEC dbo.spAddressByCity 'London'












-- showing that parameter sniffing helps
DECLARE @city VARCHAR(75) = 'London' ;

SELECT  a.AddressID,
        a.AddressLine1,
        a.AddressLine2,
        a.City,
        sp.[Name] AS StateProvinceName,
        a.PostalCode
FROM    Person.Address AS a
        JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   a.City = @City ;



















    SELECT  decp.plan_handle
    FROM    sys.dm_exec_cached_plans AS decp
            CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest
    WHERE   dest.[text] LIKE 'CREATE PROC dbo.spAddressByCity%' ;


--to just remove the one plan from cache
    DBCC freeproccache(0x05000700424E641640C18192000000000000000000000000) ;



EXEC dbo.spAddressByCity 'Mentor';


EXEC dbo.spAddressByCity 'London';





-- #1 Local variables
--#2 OPTIMIZE FOR <Value>
--#3 OPTIMIZE FOR UNKNOWN
--#4 WITH RECOMPILE
-- #5 STATS
-- #6 Plan Guides
--#7 Turn off parameter sniffing












-- key lookup
SELECT  soh.AccountNumber,
        soh.DueDate,
        soh.Freight,
        sod.LineTotal,
        sod.CarrierTrackingNumber
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE   soh.CustomerID = 11722












DBCC SHOW_STATISTICS('Sales.SalesOrderHeader','PK_SalesOrderHeader_SalesOrderID')









SELECT  *
FROM    sys.indexes AS i
        JOIN sys.index_columns AS ic
        ON i.object_id = ic.object_id
           AND i.index_id = ic.index_id
WHERE   i.object_id = OBJECT_ID('Sales.SalesOrderHeader')
AND i.name = 'pK_SalesOrderHeader_SalesOrderID'









SELECT  INDEXPROPERTY(OBJECT_ID('Sales.SalesOrderHeader'),
                      'pK_SalesOrderHeader_SalesOrderID', 'IndexDepth')




SELECT  soh.AccountNumber,
        soh.DueDate,
        soh.Freight,
        sod.LineTotal,
        sod.CarrierTrackingNumber
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE   soh.CustomerID = 11091








CREATE INDEX LookupFix
ON Sales.SalesOrderHeader ( CustomerID )
INCLUDE (AccountNumber, DueDate, Freight)
GO

 
 
 
SELECT  soh.AccountNumber,
        soh.DueDate,
        soh.Freight,
        sod.LineTotal,
        sod.CarrierTrackingNumber
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE   soh.CustomerID = 11091






DROP INDEX Sales.SalesOrderHeader.LookupFix
