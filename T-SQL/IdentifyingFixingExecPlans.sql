--lookups
SELECT  sod.ProductID,
        sod.OrderQty,
        sod.UnitPrice
FROM    Sales.SalesOrderDetail AS sod
WHERE   sod.ProductID = 897 ;
















CREATE  NONCLUSTERED INDEX [ix_SalesOrderDetail_ProductID] 
ON [Sales].[SalesOrderDetail] ([ProductId] ASC)




SELECT  sod.ProductID,
        sod.OrderQty,
        sod.UnitPrice
FROM    Sales.SalesOrderDetail AS sod
WHERE   sod.ProductID = 897 ;









IF EXISTS ( SELECT  *
            FROM    sys.indexes
            WHERE   object_id = OBJECT_ID(N'[Sales].[SalesOrderDetail]')
                    AND name = N'ix_SalesOrderDetail_ProductID' ) 
    DROP INDEX [ix_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail] WITH ( ONLINE = OFF )
GO

CREATE  NONCLUSTERED INDEX [ix_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail] ([ProductId] ASC)
INCLUDE (OrderQty,UnitPrice)
ON  [PRIMARY]
GO




SELECT  sod.ProductID,
        sod.OrderQty,
        sod.UnitPrice
FROM    Sales.SalesOrderDetail AS sod
WHERE   sod.ProductID = 897 ;







    DROP INDEX [ix_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail] WITH ( ONLINE = OFF )












--missing index
--#1
SELECT  wo.WorkOrderID,
        wo.OrderQty,
        wo.StockedQty
FROM    Production.WorkOrder AS wo
WHERE   wo.OrderQty BETWEEN 80 AND 82









CREATE NONCLUSTERED INDEX [FixedIndex]
ON [Production].[WorkOrder] ([OrderQty])
INCLUDE ([WorkOrderID],[StockedQty]) ;




SELECT  wo.WorkOrderID,
        wo.OrderQty,
        wo.StockedQty
FROM    Production.WorkOrder AS wo
WHERE   wo.OrderQty BETWEEN 80 AND 82







DROP INDEX Production.WorkOrder.FixedIndex ;





--#2
SELECT  p.LastName + ', ' + p.FirstName AS PersonName,
        a.AddressLine1,
        a.City,
        a.PostalCode
FROM    person.Address AS a
        JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN Person.Person AS p
        ON bea.BusinessEntityID = p.BusinessEntityID
WHERE   city = 'Berlin'
        AND PostalCode = 14197








CREATE NONCLUSTERED INDEX [maybe]
ON [Person].[Address] ([City])




SELECT  p.LastName + ', ' + p.FirstName AS PersonName,
        a.AddressLine1,
        a.City,
        a.PostalCode
FROM    person.Address AS a
        JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN Person.Person AS p
        ON bea.BusinessEntityID = p.BusinessEntityID
WHERE   city = 'Berlin'
        AND PostalCode = 14197





IF EXISTS ( SELECT  *
            FROM    sys.indexes
            WHERE   object_id = OBJECT_ID(N'[Person].[Address]')
                    AND name = N'maybe' ) 
    DROP INDEX [maybe] ON [Person].[Address] WITH ( ONLINE = OFF )
GO




CREATE NONCLUSTERED INDEX [maybe2]
ON [Person].[Address] ([City],[PostalCode])






SELECT  p.LastName + ', ' + p.FirstName AS PersonName,
        a.AddressLine1,
        a.City,
        a.PostalCode
FROM    person.Address AS a
        JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN Person.Person AS p
        ON bea.BusinessEntityID = p.BusinessEntityID
WHERE   city = 'Berlin'
        AND PostalCode = 14197





DROP INDEX [maybe2] ON [Person].[Address] WITH ( ONLINE = OFF )
GO
USE [AdventureWorks2008R2]
GO
CREATE NONCLUSTERED INDEX [maybe3] ON [Person].[Address] 
(
[City] ASC,
[PostalCode] ASC
)
INCLUDE ( [AddressLine1])


SELECT  p.LastName + ', ' + p.FirstName AS PersonName,
        a.AddressLine1,
        a.City,
        a.PostalCode
FROM    person.Address AS a
        JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN Person.Person AS p
        ON bea.BusinessEntityID = p.BusinessEntityID
WHERE   city = 'Berlin'
        AND PostalCode = 14197






DROP INDEX Person.Address.maybe3





--statistics
SELECT  *
INTO    dbo.NewOrders
FROM    Sales.SalesOrderDetail AS sod
GO
CREATE INDEX IX_NewOrders_ProductID ON NewOrders(ProductID)
GO

ALTER DATABASE AdventureWorks2008R2
SET AUTO_UPDATE_STATISTICS OFF ;





SET STATISTICS XML ON ;
GO
SELECT  n.OrderQty,
        n.CarrierTrackingNumber
FROM    dbo.NewOrders AS n
WHERE   ProductID = 897 ;
GO
SET STATISTICS XML OFF ;
GO

BEGIN TRAN ;
UPDATE  dbo.NewOrders
SET     ProductID = 897
WHERE   ProductID BETWEEN 600 AND 900 ;
GO

UPDATE STATISTICS dbo.NewOrders ;

SET STATISTICS XML ON ;
GO
SELECT  n.OrderQty,
        n.CarrierTrackingNumber
FROM    dbo.NewOrders AS n
WHERE   ProductID = 897 ;
ROLLBACK TRAN ; 
GO
SET STATISTICS XML OFF ;
GO


ALTER DATABASE AdventureWorks2008R2
SET AUTO_UPDATE_STATISTICS ON ;

DROP TABLE dbo.NewOrders ;













--ad hoc sql
SELECT  *
FROM    Production.Product AS p
        JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE   pc.[Name] = 'Bikes'
        AND ps.[Name] = 'Touring Bikes'
        
        
        
        

SELECT  *
FROM    Production.Product AS p
        JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE   pc.[Name] = 'Bikes'
        AND ps.[Name] = 'Road Bikes'
        




SELECT  deqs.execution_count,
        deqs.query_hash,
        deqs.query_plan_hash,
        dest.[text]
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS dest
WHERE   dest.text LIKE 'SELECT  *%'   





SELECT  p.ProductID
FROM    Production.Product AS p
        JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE   pc.[Name] = 'Bikes'
        AND ps.[Name] = 'Road Bikes'
        
        
        
SELECT  deqs.execution_count,
        deqs.query_hash,
        deqs.query_plan_hash,
        dest.[text]
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS dest
WHERE   dest.text LIKE 'SELECT  *%'
        OR dest.text LIKE 'SELECT  p.ProductID%'





SELECT  p.[Name],
        tha.TransactionDate,
        tha.TransactionType,
        tha.Quantity,
        tha.ActualCost
FROM    Production.TransactionHistoryArchive tha
        JOIN Production.Product p
        ON tha.ProductID = p.ProductID
WHERE   P.ProductID = 461 ;



SELECT  p.[Name],
        tha.TransactionDate,
        tha.TransactionType,
        tha.Quantity,
        tha.ActualCost
FROM    Production.TransactionHistoryArchive tha
        JOIN Production.Product p
        ON tha.ProductID = p.ProductID
WHERE   P.ProductID = 712 ;







SELECT  deqs.execution_count,
        deqs.query_hash,
        deqs.query_plan_hash,
        dest.[text]
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS dest
WHERE   dest.text LIKE 'SELECT  p.![%' ESCAPE '!'








--parameter sniffing
-- a procedure that could lead to sniffing
IF (SELECT  OBJECT_ID('spAddressByCity')
   ) IS NOT NULL 
    DROP PROCEDURE dbo.spAddressByCity ;
GO
CREATE PROC dbo.spAddressByCity @City NVARCHAR(30)
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





--Two different sets of data
EXEC dbo.spAddressByCity @City = N'London' ;


EXEC dbo.spAddressByCity @City = N'Mentor' ;






-- to get the plan_handle	
SELECT  decp.plan_handle
FROM    sys.dm_exec_cached_plans AS decp
        CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest
WHERE   dest.[text] LIKE 'CREATE PROC dbo.spAddressByCity%' ;


--to just remove the one plan from cache
DBCC freeproccache(0x0500070064611346B8E0A10E000000000000000000000000) ;





--running in the reverse order leads to a different plan for both
EXEC dbo.spAddressByCity @City = N'Mentor' ;



EXEC dbo.spAddressByCity @City = N'London' ;






--one way  to get a more generic plan	
ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
    DECLARE @LocalCity NVARCHAR(30) ;

    SET @LocalCity = @City ;

    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @LocalCity ;







EXEC dbo.spAddressByCity @City = N'London' ;

EXEC dbo.spAddressByCity @City = N'Mentor' ;







--one way to get a specific plan
ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
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
WHERE   a.City = @City
OPTION  (OPTIMIZE FOR (@city = 'London')) ;



EXEC dbo.spAddressByCity @City = N'Mentor' ;







--another way to get a generic plan
ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
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
WHERE   a.City = @City
OPTION  (OPTIMIZE FOR (@city UNKNOWN)) ;



EXEC dbo.spAddressByCity @City = N'London' ;









--multi-statement UDF

CREATE FUNCTION dbo.SalesInfo ()
RETURNS @return_variable TABLE
    (
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
RETURNS @return_variable TABLE
    (
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
RETURNS @return_variable TABLE
    (
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








--query hints
SELECT  s.[Name] AS StoreName,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
        JOIN HumanResources.Employee AS e
        ON sp.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID
OPTION  (LOOP JOIN)











SELECT  s.[Name] AS StoreName,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
        JOIN HumanResources.Employee AS e
        ON sp.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID







--query hints 2
SELECT  *
FROM    Purchasing.PurchaseOrderHeader AS poh
WHERE   poh.PurchaseOrderID * 2 = 3400






SELECT  *
FROM    Purchasing.PurchaseOrderHeader AS poh WITH (INDEX (PK_PurchaseOrderHeader_PurchaseOrderID))
WHERE   poh.PurchaseOrderID * 2 = 3400








SELECT  *
FROM    Purchasing.PurchaseOrderHeader poh
WHERE   PurchaseOrderID = 3400 / 2



--Sargeable
--Search argument able

SELECT  soh.SalesOrderID
FROM    Sales.SalesOrderHeader AS soh
WHERE   LEFT(soh.SalesOrderNumber, 4) = 'SO62' ;










SELECT  soh.SalesOrderID
FROM    Sales.SalesOrderHeader AS soh
WHERE   soh.SalesOrderNumber LIKE 'SO62%' ;








--sargeable2
SELECT  *
FROM    Sales.SalesOrderDetail AS sod
WHERE   sod.SalesOrderID IN (51825, 51826, 51827, 51828) ;












SET STATS TIME 
SET STATS IO




SELECT  *
FROM    Sales.SalesOrderDetail AS sod
WHERE   sod.SalesOrderID BETWEEN 51825 AND 51828 ;


