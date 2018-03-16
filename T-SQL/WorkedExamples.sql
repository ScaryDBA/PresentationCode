--worked example #1

SELECT  p.LastName + ', ' + p.FirstName AS SalesPersonName,
        sp.SalesQuota,
        sp.SalesYTD,
        st.Name,
        st.SalesYTD AS TerritorySalesYTD,
        (sp.SalesYTD / st.SalesYTD) * 100 AS TerritoryPercentage
FROM    Sales.SalesPerson AS sp
JOIN    Person.Person AS p
        ON p.BusinessEntityID = sp.BusinessEntityID
JOIN    Sales.SalesTerritory AS st
        ON st.TerritoryID = sp.TerritoryID
WHERE   p.LastName LIKE 'V%';








CREATE INDEX BusinessEntityID ON Sales.SalesPerson 
(BusinessEntityID)
INCLUDE
(SalesQuota,SalesYTD,TerritoryID);



SELECT  p.LastName + ', ' + p.FirstName AS SalesPersonName,
        sp.SalesQuota,
        sp.SalesYTD,
        st.Name,
        st.SalesYTD AS TerritorySalesYTD,
        (sp.SalesYTD / st.SalesYTD) * 100 AS TerritoryPercentage
FROM    Sales.SalesPerson AS sp
JOIN    Person.Person AS p
        ON p.BusinessEntityID = sp.BusinessEntityID
JOIN    Sales.SalesTerritory AS st
        ON st.TerritoryID = sp.TerritoryID
WHERE   p.LastName LIKE 'V%';


SELECT  p.LastName + ', ' + p.FirstName AS SalesPersonName,
        sp.SalesQuota,
        sp.SalesYTD,
        st.Name,
        st.SalesYTD AS TerritorySalesYTD,
        (sp.SalesYTD / st.SalesYTD) * 100 AS TerritoryPercentage
FROM    Sales.SalesPerson AS sp WITH (INDEX = BusinessEntityID) 
JOIN    Person.Person AS p
        ON p.BusinessEntityID = sp.BusinessEntityID
JOIN    Sales.SalesTerritory AS st
        ON st.TerritoryID = sp.TerritoryID
WHERE   p.LastName LIKE 'V%';


SELECT  *
FROM    Sales.SalesPerson AS sp;



DROP INDEX Sales.SalesPerson.BusinessEntityID;



















-- Worked Example #2

SELECT  p.Name,
        p.ProductNumber,
        plph.ListPrice
FROM    Production.Product AS p
JOIN    Production.ProductListPriceHistory AS plph
        ON p.ProductID = plph.ProductID
           AND plph.StartDate = (SELECT TOP (1)
                                        plph2.StartDate
                                 FROM   Production.ProductListPriceHistory plph2
                                 WHERE  plph2.ProductID = p.ProductID
                                 ORDER BY plph2.StartDate DESC
                                )
WHERE   p.ProductID = 839;







-- Better query
SELECT  p.Name,
        p.ProductNumber,
        plph.ListPrice
FROM    Production.Product AS p
CROSS APPLY (SELECT TOP (1)
                    plph2.ProductID,
                    plph2.ListPrice
             FROM   Production.ProductListPriceHistory AS plph2
             WHERE  plph2.ProductID = p.ProductID
             ORDER BY plph2.StartDate DESC
            ) AS plph
WHERE   p.ProductID = 839;



























-- Worked Example #3
SELECT  soh.OrderDate,
        sod.OrderQty,
        sod.LineTotal
FROM    Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
WHERE   soh.SalesOrderID IN (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10,
                             @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18,
                             @p19, @p20, @p21, @p22, @p23, @p24, @p25, @p26,
                             @p27, @p28, @p29, @p30, @p31, @p32, @p33, @p34,
                             @p35, @p36, @p37, @p38, @p39, @p40, @p41, @p42,
                             @p43, @p44, @p45, @p46, @p47, @p48, @p49, @p50,
                             @p51, @p52, @p53, @p54, @p55, @p56, @p57, @p58,
                             @p59, @p60, @p61, @p62, @p63, @p64, @p65, @p66,
                             @p67, @p68, @p69, @p70, @p71, @p72, @p73, @p74,
                             @p75, @p76, @p77, @p78, @p79, @p80, @p81, @p82,
                             @p83, @p84, @p85, @p86, @p87, @p88, @p89, @p90,
                             @p91, @p92, @p93, @p94, @p95, @p96, @p97, @p98,
                             @p99);














SELECT  soh.OrderDate,
        sod.OrderQty,
        sod.LineTotal
FROM    Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    @IDList AS il
        ON il.ID = soh.SalesOrderID;


































-- worked Example #4
DECLARE @LocationName AS NVARCHAR(50);

SET @LocationName = 'Paint';

SELECT  p.Name AS ProductName,
        pi.Shelf,
        l.Name AS LocationName
FROM    Production.Product AS p
JOIN    Production.ProductInventory AS pi
        ON pi.ProductID = p.ProductID
JOIN    Production.Location AS l
        ON l.LocationID = pi.LocationID
WHERE   LTRIM(RTRIM(l.Name)) = @LocationName;
GO



CREATE INDEX ProductionLocation ON Production.ProductInventory(LocationID)
INCLUDE (Shelf);





DROP INDEX productionlocation ON Production.ProductInventory





















--Worked Example #5

SELECT  soh.OrderDate,
        soh.ShipDate,
        sod.OrderQty,
        sod.UnitPrice,
        p.Name AS ProductName
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   p.Name = 'Water Bottle - 30 oz.'
        AND sod.UnitPrice < $0.0;




ALTER TABLE Sales.SalesOrderDetail DROP CONSTRAINT
CK_SalesOrderDetail_UnitPrice


ALTER TABLE Sales.SalesOrderDetail  WITH CHECK
ADD  CONSTRAINT CK_SalesOrderDetail_UnitPrice CHECK  ((UnitPrice>=(0.00)));
































--worked Example #6

SELECT  tha.ProductID,
        COUNT(tha.ProductID) AS CountProductID,
        SUM(tha.Quantity) AS SumQuantity,
        AVG(tha.ActualCost) AS AvgActualCost
FROM    Production.TransactionHistoryArchive AS tha
GROUP BY tha.ProductID;

DROP INDEX Production.TransactionHistoryArchive.ix_cstest;

CREATE NONCLUSTERED COLUMNSTORE INDEX ix_csTest
ON Production.TransactionHistoryArchive
(ProductID,
Quantity,
ActualCost);

DROP TABLE dbo.TransactionHistoryArchive;


SELECT  *
INTO    dbo.TransactionHistoryArchive
FROM    Production.TransactionHistoryArchive;

CREATE CLUSTERED INDEX ClusteredColumnStoreTest
ON dbo.TransactionHistoryArchive
(TransactionID);




CREATE CLUSTERED COLUMNSTORE INDEX ClusteredColumnStoreTest
ON dbo.TransactionHistoryArchive
WITH (DROP_EXISTING = ON);




SELECT  tha.ProductID,
        COUNT(tha.ProductID) AS CountProductID,
        SUM(tha.Quantity) AS SumQuantity,
        AVG(tha.ActualCost) AS AvgActualCost
FROM    dbo.TransactionHistoryArchive AS tha
GROUP BY tha.ProductID;

DROP TABLE dbo.TransactionHistoryArchive;
DROP INDEX Production.TransactionHistoryArchive.ix_csTest;


SELECT COUNT(*) FROM Production.TransactionHistoryArchive AS tha





















EXEC dbo.AddressByCity
    @City = N'London'



--Worked Example #7
--must remove
-- 1. Query is just running too slow
SELECT  p.Name,
        p.ProductNumber,
        plph.ListPrice
FROM    Production.Product AS p
JOIN    Production.ProductListPriceHistory AS plph
        ON p.ProductID = plph.ProductID
           AND plph.StartDate = (SELECT TOP (1)
                                        plph2.StartDate
                                 FROM   Production.ProductListPriceHistory plph2
                                 WHERE  plph2.ProductID = p.ProductID
                                 ORDER BY plph2.StartDate DESC
                                )
WHERE   p.ProductID = 839;















-- Better query
SELECT  p.Name,
        p.ProductNumber,
        plph.ListPrice
FROM    Production.Product AS p
CROSS APPLY (SELECT TOP (1)
                    plph2.ProductID,
                    plph2.ListPrice
             FROM   Production.ProductListPriceHistory AS plph2
             WHERE  plph2.ProductID = p.ProductID
             ORDER BY plph2.StartDate DESC
            ) AS plph
WHERE   p.ProductID = 839;
















--Worked Example #8
--Plans and cache
DBCC FREEPROCCACHE();



SELECT * FROM Production.ProductModel AS pm;




SELECT  deqs.plan_handle
FROM    sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE   dest.text = 'SELECT * FROM Production.ProductModel AS pm;';



SELECT  *
FROM    Production.Product AS p
JOIN    Production.ProductModel AS pm
        ON pm.ProductModelID = p.ProductModelID
JOIN    Production.ProductInventory AS pi
        ON pi.ProductID = p.ProductID
JOIN    Production.Location AS l
        ON l.LocationID = pi.LocationID
WHERE   p.ProductID = 750;



SELECT  deqs.plan_handle
FROM    sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE   dest.text = 'SELECT  *
FROM    Production.Product AS p
JOIN    Production.ProductModel AS pm
        ON pm.ProductModelID = p.ProductModelID
JOIN    Production.ProductInventory AS pi
        ON pi.ProductID = p.ProductID
JOIN    Production.Location AS l
        ON l.LocationID = pi.LocationID
WHERE   p.ProductID = 750;';


EXEC dbo.spAddressByCity
    @City = N'Mentor'; 

SELECT  deps.plan_handle
FROM    sys.dm_exec_procedure_stats AS deps
WHERE   deps.object_id = OBJECT_ID('dbo.spAddressByCity');






--Worked Example #9


SELECT  tha.ProductID,
        COUNT(tha.ProductID) AS CountProductID,
        SUM(tha.Quantity) AS SumQuantity,
        AVG(tha.ActualCost) AS AvgActualCost
FROM    Production.TransactionHistoryArchive AS tha
GROUP BY tha.ProductID;







27,628
27,49


CREATE NONCLUSTERED COLUMNSTORE INDEX ix_csTest
ON Production.TransactionHistoryArchive
(ProductID,
Quantity,
ActualCost);


DROP INDEX ix_csTest
ON Production.TransactionHistoryArchive







SELECT  tha.ProductID,
        COUNT(tha.ProductID) AS CountProductID,
        SUM(tha.Quantity) AS SumQuantity,
        AVG(tha.ActualCost) AS AvgActualCost
FROM    Production.TransactionHistoryArchive AS tha
GROUP BY tha.ProductID;







SELECT  tha.ProductID,
        COUNT(tha.ProductID) AS CountProductID,
        SUM(tha.Quantity) AS SumQuantity,
        AVG(tha.ActualCost) AS AvgActualCost
FROM    Production.TransactionHistoryArchive AS tha
GROUP BY tha.ProductID
OPTION (QUERYTRACEON 8649);










--do this so we don't break the existing table
SELECT  *
INTO    dbo.TransactionHistoryArchive
FROM    Production.TransactionHistoryArchive;





CREATE CLUSTERED INDEX ClusteredColumnStoreTest
ON dbo.TransactionHistoryArchive
(TransactionID);




CREATE CLUSTERED COLUMNSTORE INDEX ClusteredColumnStoreTest
ON dbo.TransactionHistoryArchive
WITH (DROP_EXISTING = ON);




SELECT  tha.ProductID,
        COUNT(tha.ProductID) AS CountProductID,
        SUM(tha.Quantity) AS SumQuantity,
        AVG(tha.ActualCost) AS AvgActualCost
FROM    dbo.TransactionHistoryArchive AS tha
GROUP BY tha.ProductID;








SELECT  tha.ProductID,
        COUNT(tha.ProductID) AS CountProductID,
        SUM(tha.Quantity) AS SumQuantity,
        AVG(tha.ActualCost) AS AvgActualCost
FROM    dbo.TransactionHistoryArchive AS tha
GROUP BY tha.ProductID
OPTION (QUERYTRACEON 8649);






DROP TABLE dbo.TransactionHistoryArchive;
DROP INDEX Production.TransactionHistoryArchive.ix_csTest;



















--Worked Example #10

USE master;
GO
CREATE DATABASE PerfTuning;
GO
ALTER DATABASE PerfTuning 
ADD FILEGROUP PerfTuning_InMemoryData
CONTAINS MEMORY_OPTIMIZED_DATA;
ALTER DATABASE PerfTuning 
ADD FILE (NAME='PerfTuning_InMemoryData', 
FILENAME='C:\Data\PerfTuning_InMemoryData2.ndf') 
TO FILEGROUP PerfTuning_InMemoryData;
GO
USE PerfTuning;
GO
DISABLE TRIGGER RG_SQLLighthouse_DDLTrigger ON ALL SERVER
GO
CREATE TABLE dbo.Address(
	AddressID int IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=50000),
	AddressLine1 nvarchar(60) NOT NULL,
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(30) COLLATE Latin1_General_100_BIN2 NOT NULL ,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL,
	--[SpatialLocation geography NULL,
	--rowguid uniqueidentifier ROWGUIDCOL  NOT NULL CONSTRAINT DF_Address_rowguid  DEFAULT (newid()),
	ModifiedDate datetime NOT NULL CONSTRAINT DF_Address_ModifiedDate  DEFAULT (getdate())
) WITH (MEMORY_OPTIMIZED=ON);

CREATE TABLE dbo.AddressStaging(
	AddressLine1 nvarchar(60) NOT NULL,
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(30) NOT NULL,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL
);




--Pause to show insert speeds
INSERT  dbo.AddressStaging
        (AddressLine1,
         AddressLine2,
         City,
         StateProvinceID,
         PostalCode
        )
SELECT  a.AddressLine1,
        a.AddressLine2,
        a.City,
        a.StateProvinceID,
        a.PostalCode
FROM    AdventureWorks2014.Person.Address AS a;



INSERT  dbo.Address
        (AddressLine1,
         AddressLine2,
         City,
         StateProvinceID,
         PostalCode
        )
SELECT  a.AddressLine1,
        a.AddressLine2,
        a.City,
        a.StateProvinceID,
        a.PostalCode
FROM    dbo.AddressStaging AS a;

DROP TABLE dbo.AddressStaging;




--Next set up
CREATE TABLE dbo.StateProvince (
     StateProvinceID INT
        IDENTITY(1, 1)
        NOT NULL
        PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
     StateProvinceCode NCHAR(3) NOT NULL,
     CountryRegionCode NVARCHAR(3) COLLATE Latin1_General_100_BIN2
                                   NOT NULL,
     Name VARCHAR(50) NOT NULL,
     TerritoryID INT NOT NULL,
     ModifiedDate DATETIME
        NOT NULL
        CONSTRAINT DF_StateProvince_ModifiedDate DEFAULT (GETDATE())
    )
    WITH (
         MEMORY_OPTIMIZED=
         ON);


CREATE TABLE dbo.CountryRegion (
     CountryRegionCode NVARCHAR(3) COLLATE Latin1_General_100_BIN2 NOT NULL,
     Name VARCHAR(50) NOT NULL,
     ModifiedDate DATETIME NOT NULL,
     CONSTRAINT PK_CountryRegion_CountryRegionCodes PRIMARY KEY CLUSTERED
        (CountryRegionCode ASC)
    );

SELECT  sp.StateProvinceCode,
        sp.CountryRegionCode,
        sp.Name,
        sp.TerritoryID
INTO    dbo.StateProvinceStaging
FROM    AdventureWorks2014.Person.StateProvince AS sp;

INSERT  dbo.StateProvince
        (StateProvinceCode,
         CountryRegionCode,
         Name,
         TerritoryID
        )
SELECT  stateprovincecode,
        countryregioncode,
        name,
        territoryid
FROM    dbo.stateprovincestaging;

DROP TABLE dbo.StateProvinceStaging;

INSERT  dbo.CountryRegion
        (CountryRegionCode,
         Name,
         ModifiedDate
        )
SELECT  cr.CountryRegionCode,
        cr.Name,
        GETUTCDATE()
FROM    AdventureWorks2014.Person.CountryRegion AS cr;







--mixed table queries
USE PerfTuning;

SELECT  a.AddressLine1,
        a.City,
        a.PostalCode,
        sp.Name AS StateProvinceName,
        cr.Name AS CountryName
FROM    dbo.Address AS a
        JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
        JOIN dbo.CountryRegion cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID = 882;


USE AdventureWorks2014;

SELECT  a.AddressLine1,
        a.City,
        a.PostalCode,
        sp.Name AS StateProvinceName,
        cr.Name AS CountryName
FROM    Person.Address AS a
        JOIN Person.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
        JOIN Person.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE   a.AddressID = 882;

















-- All in-memory
USE PerfTuning;
GO

DROP TABLE dbo.CountryRegion;

CREATE TABLE dbo.CountryRegion (
     CountryRegionCode NVARCHAR(3)
        COLLATE Latin1_General_100_BIN2
        NOT NULL
        PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1000),
     Name VARCHAR(50) COLLATE Latin1_General_100_BIN2
                      NOT NULL,
     ModifiedDate DATETIME
        NOT NULL
        CONSTRAINT DF_CountryRegion_ModifiedDate DEFAULT (GETDATE()),
    )
    WITH (
         MEMORY_OPTIMIZED=
         ON);

CREATE TABLE dbo.CountryRegionStaging (
     CountryRegionCode NVARCHAR(3) COLLATE Latin1_General_100_BIN2
                                   NOT NULL,
     Name VARCHAR(50) NOT NULL,
     ModifiedDate DATETIME NOT NULL,
     CONSTRAINT PK_CountryRegion_CountryRegionCodes PRIMARY KEY CLUSTERED
        (CountryRegionCode ASC)
    );

INSERT  dbo.CountryRegionStaging
        (CountryRegionCode,
         Name,
         ModifiedDate
        )
SELECT  cr.CountryRegionCode,
        cr.Name,
        GETUTCDATE()
FROM    AdventureWorks2014.Person.CountryRegion AS cr;

INSERT  dbo.CountryRegion
        (CountryRegionCode,
         Name,
         ModifiedDate
        )
SELECT  crs.CountryRegionCode,
        crs.Name,
        crs.ModifiedDate
FROM    dbo.CountryRegionStaging AS crs;






SELECT  a.AddressLine1,
        a.City,
        a.PostalCode,
        sp.Name AS StateProvinceName,
        cr.Name AS CountryName
FROM    dbo.Address AS a
        JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
        JOIN dbo.CountryRegion cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID = 882;














CREATE PROC dbo.AddressDetails @City NVARCHAR(30)
    WITH NATIVE_COMPILATION,
         SCHEMABINDING,
         EXECUTE AS OWNER
AS
    BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
        SELECT  a.AddressLine1,
                a.City,
                a.PostalCode,
                sp.Name AS StateProvinceName,
                cr.Name AS CountryName
        FROM    dbo.Address AS a
                JOIN dbo.StateProvince AS sp
                ON sp.StateProvinceID = a.StateProvinceID
                JOIN dbo.CountryRegion AS cr
                ON cr.CountryRegionCode = sp.CountryRegionCode
        WHERE   a.City = @City;
    END








EXEC dbo.AddressDetails @City = N'Walla Walla';






EXEC dbo.AddressDetails N'Walla Walla';










--Clean up
USE master;
GO
DROP DATABASE PerfTuning;
GO
ENABLE TRIGGER RG_SQLLighthouse_DDLTrigger ON ALL SERVER
GO




--Worked Example #11
--Remember, get the Azure connection first

CREATE PROC dbo.ProductTransactionHistoryByReference (
     @ReferenceOrderID int
    )
AS
BEGIN
    SELECT  p.Name,
            p.ProductNumber,
            th.ReferenceOrderID
    FROM    Production.Product AS p
    JOIN    Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE   th.ReferenceOrderID = @ReferenceOrderID;
END
GO


EXEC dbo.ProductTransactionHistoryByReference
    @ReferenceOrderID = 41798 WITH RECOMPILE;




DECLARE @PlanHandle VARBINARY(64);

SELECT  @PlanHandle = deps.plan_handle
FROM    sys.dm_exec_procedure_stats AS deps
WHERE   deps.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.ProductTransactionHistoryByReference
    @referenceorderid = 53465 WITH RECOMPILE;



SELECT  OBJECT_NAME(qsq.object_id),
        qsrs.count_executions,
        CAST(qsp.query_plan AS XML) AS xmlplan,
        qsrs.avg_duration,
        qsrs.avg_cpu_time,
        qsrs.avg_logical_io_reads
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
JOIN    sys.query_store_runtime_stats AS qsrs
        ON qsrs.plan_id = qsp.plan_id
WHERE   qsq.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');
