-- EXECUTION PLAN BASICS

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

SELECT * FROM Person.Address AS a










-- T-SQL Code Smells

--Functions on predicates
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










SELECT  *
FROM    Sales.SalesOrderDetail AS sod
WHERE   sod.SalesOrderID BETWEEN 51825 AND 51828 ;







--Data Conversion, Implicit & Explicit
--explicit example
SELECT  *
FROM    Production.WorkOrder AS wo
JOIN    Production.Product AS p
        ON p.ProductID = wo.ProductID
JOIN    Production.ScrapReason AS sr
        ON sr.ScrapReasonID = wo.ScrapReasonID
WHERE   wo.ScrapReasonID = '3';







SELECT  *
FROM    Production.WorkOrder AS wo
JOIN    Production.Product AS p
        ON p.ProductID = wo.ProductID
JOIN    Production.ScrapReason AS sr
        ON sr.ScrapReasonID = wo.ScrapReasonID
WHERE   CAST(wo.ScrapReasonID AS VARCHAR(5)) = '3';





--implicit example
--false positive
SELECT  *
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   p.ProductID = 765;










SELECT  *
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   soh.SalesOrderNumber = N'SO44770';






--positive
SELECT  p.FirstName,
        p.LastName,
        p.Title,
        e.NationalIDNumber,
        e.JobTitle
FROM    HumanResources.Employee AS e
JOIN    Person.Person AS p
        ON p.BusinessEntityID = e.BusinessEntityID
WHERE   e.NationalIDNumber = 948320468;









SELECT  p.FirstName,
        p.LastName,
        p.Title,
        e.NationalIDNumber,
        e.JobTitle
FROM    HumanResources.Employee AS e
JOIN    Person.Person AS p
        ON p.BusinessEntityID = e.BusinessEntityID
WHERE   e.NationalIDNumber = '948320468';


SELECT  p.FirstName,
        p.LastName,
        p.Title,
        e.NationalIDNumber,
        e.JobTitle
FROM    HumanResources.Employee AS e
JOIN    Person.Person AS p
        ON p.BusinessEntityID = e.BusinessEntityID
and   e.NationalIDNumber = '948320468';






--RBAR
BEGIN TRANSACTION
DECLARE @Name NVARCHAR(50) ,
    @Color NVARCHAR(15) ,
    @Weight DECIMAL(8, 2) 
DECLARE BigUpdate CURSOR
FOR SELECT  p.[Name]
,p.Color
,p.[Weight]
FROM    Production.Product AS p ;
OPEN BigUpdate ;

FETCH NEXT FROM BigUpdate INTO @Name, @Color, @Weight ;

WHILE @@FETCH_STATUS = 0 
    BEGIN
        IF @Weight < 3 
            BEGIN
                UPDATE  Production.Product
                SET     Color = 'Blue'
                WHERE CURRENT OF BigUpdate
            END

        FETCH NEXT FROM BigUpdate INTO @Name, @Color, @Weight ;

    END
CLOSE BigUpdate ;
DEALLOCATE BigUpdate ;

SELECT  *
FROM    Production.Product AS p
WHERE   Color = 'Blue' ;

ROLLBACK TRANSACTION









BEGIN TRANSACTION
	  
UPDATE  Production.Product
SET     Color = 'BLUE'
WHERE   [Weight] < 3 ;

ROLLBACK TRANSACTION





--Nested views

SELECT  pa.PersonName,
        pa.City,
        cea.EmailAddress,
        cs.DueDate
FROM    dbo.PersonAddress AS pa
JOIN    dbo.CustomerSales AS cs
        ON cs.CustomerPersonID = pa.PersonID
LEFT JOIN dbo.ContactEmailAddress AS cea
        ON cea.ContactPersonID = pa.PersonID
WHERE   pa.City = 'Redmond';
GO







CREATE VIEW dbo.PersonAddress
AS
SELECT  p.BusinessEntityID AS PersonID,
        bea.AddressTypeID,
        at.Name AS AddressTypeName,
        a.City,
        a.StateProvinceID,
        sp.Name AS StateProvinceName,
		a.AddressLine1,
		p.LastName + ', ' + p.FirstName AS PersonName
FROM    Person.Person AS p
JOIN    Person.BusinessEntityAddress AS bea
        ON bea.BusinessEntityID = p.BusinessEntityID
JOIN    Person.Address AS a
        ON a.AddressID = bea.AddressID
JOIN    Person.AddressType AS at
        ON at.AddressTypeID = bea.AddressTypeID
JOIN    Person.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID;
GO



create VIEW dbo.CustomerSales
AS
SELECT  c.CustomerID,
        c.StoreID,
        c.TerritoryID,
        c.AccountNumber,
        p.FirstName,
        p.LastName,
		p.BusinessEntityID AS CustomerPersonID,
		soh.DueDate,
		soh.SalesOrderID,
		soh.OrderDate
FROM    Sales.Customer AS c
JOIN    Sales.SalesOrderHeader AS soh
        ON soh.CustomerID = c.CustomerID
JOIN    Person.Person AS p
        ON p.BusinessEntityID = c.PersonID;
GO


CREATE VIEW dbo.ContactEmailAddress
AS
SELECT  p.FirstName,
        p.LastName,
        ea.EmailAddress,
		p.BusinessEntityID AS ContactPersonID
FROM    Person.Person AS p
JOIN    Person.EmailAddress AS ea
        ON ea.BusinessEntityID = p.BusinessEntityID
GO









SELECT  p.LastName + ', ' + p.FirstName AS PersonName ,
        a.City ,
        ea.EmailAddress ,
        soh.DueDate
FROM    Person.Person AS p
        JOIN Person.EmailAddress AS ea
              ON ea.BusinessEntityID = p.BusinessEntityID
        JOIN Person.BusinessEntityAddress AS bea
              ON bea.BusinessEntityID = p.BusinessEntityID
        JOIN Person.Address AS a
              ON a.AddressID = bea.AddressID
        LEFT JOIN Person.BusinessEntityContact AS bec
              ON bec.PersonID = p.BusinessEntityID
        JOIN Sales.Customer AS c
              ON c.PersonID = p.BusinessEntityID
        JOIN Sales.SalesOrderHeader AS soh
              ON soh.CustomerID = c.CustomerID
WHERE   a.City = 'Redmond';





SELECT  pa.PersonName,
        pa.City,
        cea.EmailAddress,
        cs.DueDate
FROM    dbo.PersonAddress AS pa
JOIN    dbo.CustomerSales AS cs
        ON cs.CustomerPersonID = pa.PersonID
LEFT JOIN dbo.ContactEmailAddress AS cea
        ON cea.ContactPersonID = pa.PersonID
WHERE   pa.City = 'Redmond';







--IF Logic


CREATE PROC dbo.MultiFunction (
     @City nvarchar(30),
     @PersonLastName nvarchar(50) = NULL
    )
AS
IF @PersonLastName IS NOT NULL
    BEGIN
        SELECT  a.AddressID,
                a.AddressLine1,
                a.AddressLine2,
                a.City,
                sp.Name AS StateProvinceName,
                a.PostalCode,
				p.LastName
        FROM    Person.Address AS a
        JOIN    Person.StateProvince AS sp
                ON a.StateProvinceID = sp.StateProvinceID
        JOIN    Person.BusinessEntityAddress AS bea
                ON bea.AddressID = a.AddressID
        JOIN    Person.Person AS p
                ON p.BusinessEntityID = bea.BusinessEntityID
        WHERE   a.City = @City
                AND p.LastName = @PersonLastName;
    END
ELSE
    BEGIN
        SELECT  a.AddressID,
                a.AddressLine1,
                a.AddressLine2,
                a.City,
                sp.Name AS StateProvinceName,
                a.PostalCode
        FROM    Person.Address AS a
        JOIN    Person.StateProvince AS sp
                ON a.StateProvinceID = sp.StateProvinceID
        WHERE   a.City = @City;
    END
GO



EXEC dbo.MultiFunction @City = 'London', @PersonLastName = 'Navarro';



EXEC dbo.multifunction @city = 'Mentor';





--remove this from cache
DECLARE @PlanHandle VARBINARY(64);

SELECT  @PlanHandle = deps.plan_handle
FROM    sys.dm_exec_procedure_stats AS deps
WHERE   deps.object_id = OBJECT_ID('dbo.MultiFunction');

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO




CREATE PROC dbo.AddressByCityAndName (
     @City nvarchar(30),
     @PersonLastName nvarchar(50) = NULL
    )
AS
BEGIN
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.Name AS StateProvinceName,
            a.PostalCode,
			p.LastName
    FROM    Person.Address AS a
    JOIN    Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    JOIN    Person.BusinessEntityAddress AS bea
            ON bea.AddressID = a.AddressID
    JOIN    Person.Person AS p
            ON p.BusinessEntityID = bea.BusinessEntityID
    WHERE   a.City = @City
            AND p.LastName = @PersonLastName;
END





--Make it a wrapper proc
alter PROC dbo.MultiFunction (
     @City nvarchar(30),
     @PersonLastName nvarchar(50) = NULL
    )
AS
IF @PersonLastName IS NOT NULL
    BEGIN
        EXEC dbo.AddressByCityAndName
            @City = @City, -- nvarchar(30)
            @PersonLastName = PersonLastName -- nvarchar(50)
        
    END
ELSE
    BEGIN
        EXEC dbo.spAddressByCity
            @City = @City;
    END
GO






EXEC dbo.MultiFunction @City = 'London', @PersonLastName = 'Navarro';



EXEC dbo.multifunction @city = 'Mentor';








-- Multi-statement table valued user defined functions

--EXAMPLE #1




CREATE FUNCTION dbo.SalesInfo ( )
RETURNS @return_variable TABLE
    (
      SalesOrderID INT ,
      OrderDate DATETIME ,
      SalesPersonID INT ,
      PurchaseOrderNumber dbo.OrderNumber ,
      AccountNumber dbo.AccountNumber ,
      ShippingCity NVARCHAR(30)
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                ( SalesOrderID ,
                  OrderDate ,
                  SalesPersonID ,
                  PurchaseOrderNumber ,
                  AccountNumber ,
                  ShippingCity
                )
                SELECT  soh.SalesOrderID ,
                        soh.OrderDate ,
                        soh.SalesPersonID ,
                        soh.PurchaseOrderNumber ,
                        soh.AccountNumber ,
                        a.City
                FROM    Sales.SalesOrderHeader AS soh
                        JOIN Person.Address AS a ON soh.ShipToAddressID = a.AddressID ;
        RETURN ;
    END ;
GO

CREATE FUNCTION dbo.SalesDetails ( )
RETURNS @return_variable TABLE
    (
      SalesOrderID INT ,
      SalesOrderDetailID INT ,
      OrderQty SMALLINT ,
      UnitPrice MONEY
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                ( SalesOrderID ,
                  SalesOrderDetailId ,
                  OrderQty ,
                  UnitPrice
                )
                SELECT  sod.SalesOrderID ,
                        sod.SalesOrderDetailID ,
                        sod.OrderQty ,
                        sod.UnitPrice
                FROM    Sales.SalesOrderDetail AS sod ;
        RETURN ;
    END ;
GO


CREATE FUNCTION dbo.CombinedSalesInfo ( )
RETURNS @return_variable TABLE
    (
      SalesPersonID INT ,
      ShippingCity NVARCHAR(30) ,
      OrderDate DATETIME ,
      PurchaseOrderNumber dbo.OrderNumber ,
      AccountNumber dbo.AccountNumber ,
      OrderQty SMALLINT ,
      UnitPrice MONEY
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                ( SalesPersonId ,
                  ShippingCity ,
                  OrderDate ,
                  PurchaseOrderNumber ,
                  AccountNumber ,
                  OrderQty ,
                  UnitPrice
                )
                SELECT  si.SalesPersonID ,
                        si.ShippingCity ,
                        si.OrderDate ,
                        si.PurchaseOrderNumber ,
                        si.AccountNumber ,
                        sd.OrderQty ,
                        sd.UnitPrice
                FROM    dbo.SalesInfo() AS si
                        JOIN dbo.SalesDetails() AS sd 
                        ON si.SalesOrderID = sd.SalesOrderID ;
        RETURN ;
    END ;
GO


SELECT  csi.OrderDate ,
        csi.PurchaseOrderNumber ,
        csi.AccountNumber ,
        csi.OrderQty ,
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
        AND sa.City = 'Odessa';










--Example #2 UDF
SELECT * FROM dbo.ufnGetContactInformation(42) AS ugci;








--Example #3 UDF
DROP FUNCTION dbo.ProductList;
GO

CREATE FUNCTION dbo.ProductList (@ProductCategory INT)
RETURNS @ProductList TABLE (
     ProductId INT,
     Name NVARCHAR(50),
     Color NVARCHAR(15),
     CategoryName NVARCHAR(50),
     SubCategoryName NVARCHAR(50)
    )
AS 
    BEGIN
        IF EXISTS ( SELECT  *
                    FROM    Production.ProductSubcategory AS ps
                    WHERE   ps.ProductCategoryID = @productCategory ) 
            BEGIN
                INSERT  @ProductList
                        SELECT  p.ProductId,
                                p.NAME,
                                p.Color,
                                pc.Name,
                                ps.Name
                        FROM    Production.Product AS p
                                JOIN Production.ProductSubcategory AS ps
                                ON p.ProductSubcategoryID = ps.ProductSubcategoryID
                                JOIN Production.ProductCategory AS pc
                                ON ps.ProductCategoryID = pc.ProductCategoryID
                        WHERE   pc.ProductCategoryID = @ProductCategory
                RETURN ;
            END
        RETURN 
    END
GO






-- remember to run these seperately
SELECT  *
FROM    Sales.SalesOrderDetail AS sod
        JOIN dbo.ProductList (3) AS pl
        ON sod.ProductID = pl.ProductId
WHERE   sod.SalesOrderID = 43676;








SELECT  sod.*,
        p.productId,
        p.Name,
        p.Color,
        pc.Name AS CategoryName,
        ps.Name AS SubCategoryName
FROM    Sales.SalesOrderDetail AS SOD
        JOIN Production.Product AS p
        ON SOD.ProductID = p.ProductID
        JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE   pc.ProductCategoryID = 3
        AND SOD.SalesOrderID = 43676;


























--querying execution plans

--Information about how the optimizer works, apart from execution plans
SELECT  *
FROM    sys.dm_exec_query_optimizer_info AS deqoi ;
















--pause any automated tasks at this point
DBCC freeproccache;
GO
SELECT  *
INTO    OpInfoAfter
FROM    sys.dm_exec_query_optimizer_info AS deqoi
GO
DROP TABLE OpInfoAfter
GO
--gather the existing optimizer information
SELECT  *
INTO    OpInfoBefore
FROM    sys.dm_exec_query_optimizer_info AS deqoi ;
GO

--run a query
SELECT  pp.PhoneNumber,
        pnt.Name AS PhoneType
FROM    Person.PersonPhone AS pp
        JOIN Person.PhoneNumberType AS pnt
        ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
WHERE   pp.BusinessEntityID = 6571 ;


GO 
SELECT  *
INTO    OpInfoAfter
FROM    sys.dm_exec_query_optimizer_info AS deqoi
GO
--display the data that has changed
SELECT  oia.counter,
        (oia.occurrence - oib.occurrence) AS ActualOccurence,
        (oia.occurrence * oia.value - oib.occurrence * oib.value) AS ActualValue
FROM    OpInfoBefore AS oib
        JOIN OpInfoAfter AS oia
        ON oib.counter = oia.counter
WHERE   oia.occurrence <> oib.occurrence ;
GO

DROP TABLE OpInfoBefore ;
DROP TABLE OpInfoAfter ;
GO
















--Getting information from Plan Cache
SELECT TOP 10
		SUBSTRING(dest.text, (deqs.statement_start_offset / 2) + 1,
				  (CASE deqs.statement_end_offset
					 WHEN -1 THEN DATALENGTH(dest.text)
					 ELSE deqs.statement_end_offset
						  - deqs.statement_start_offset
				   END) / 2 + 1) AS querystatement,
		deqp.query_plan,
		deqs.query_hash,
		deqs.execution_count,
		deqs.last_elapsed_time,
		deqs.last_logical_reads,
		deqs.last_logical_writes,
		deqs.last_worker_time,
		deqs.max_elapsed_time,
		deqs.max_logical_reads,
		deqs.max_logical_writes,
		deqs.max_worker_time,
		deqs.total_elapsed_time,
		deqs.total_logical_reads,
		deqs.total_logical_writes,
		deqs.total_worker_time
FROM	sys.dm_exec_query_stats AS deqs
		CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
		CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY deqs.total_elapsed_time DESC;
--ORDER BY deqs.creation_time DESC;















--Getting information from XML

--Missing Indexes
SELECT  mig.*,
        mid.statement AS table_name,
        column_id,
        column_name,
        column_usage
FROM    sys.dm_db_missing_index_details AS mid
        CROSS APPLY sys.dm_db_missing_index_columns(mid.index_handle)
        INNER JOIN sys.dm_db_missing_index_groups AS mig
        ON mig.index_handle = mid.index_handle
WHERE   mid.database_id = DB_ID('AdventureWorks2014')
ORDER BY mig.index_group_handle,
        mig.index_handle,
        column_id ;





--Not from BOL
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan'
    AS sp), MissingIndex AS (
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
WHERE   p.query_plan.exist(N'/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan//sp:MissingIndexes') = 1 )

SELECT * FROM MissingIndex
WHERE MissingIndex.DatabaseName = 'AdventureWorks2014';




-- Other information

SELECT * FROM HumanResources.vEmployee AS ve;



WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
QueryPlans AS
(
SELECT RelOp.pln.value(N'@PhysicalOp', N'varchar(50)') AS OperatorName,
RelOp.pln.value(N'@NodeId',N'integer') AS NodeId,
RelOp.pln.value(N'@EstimateCPU', N'decimal(10,9)') AS CPUCost,
RelOp.pln.value(N'@EstimateIO', N'decimal(10,9)') AS IOCost,
dest.text
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
CROSS APPLY deqp.query_plan.nodes(N'//RelOp') RelOp (pln)
)

SELECT  qp.OperatorName,
        qp.NodeId,
        qp.CPUCost,
        qp.IOCost,
        qp.CPUCost + qp.IOCost AS EstimatedCost
FROM    QueryPlans AS qp
WHERE   qp.text = 'SELECT * FROM HumanResources.vEmployee AS ve;'
ORDER BY EstimatedCost DESC;











--TIMEOUT
WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),  QueryPlans 
AS  (  
SELECT  RelOp.pln.value(N'@StatementOptmEarlyAbortReason', N'varchar(50)') AS TerminationReason, 
        RelOp.pln.value(N'@StatementOptmLevel', N'varchar(50)') AS OptimizationLevel, 
        --dest.text, 
        SUBSTRING(dest.text, (deqs.statement_start_offset / 2) + 1, 
                  (deqs.statement_end_offset - deqs.statement_start_offset) 
                  / 2 + 1) AS StatementText, 
        deqp.query_plan, 
        deqp.dbid, 
        deqs.execution_count, 
        deqs.total_elapsed_time, 
        deqs.total_logical_reads, 
        deqs.total_logical_writes 
FROM    sys.dm_exec_query_stats AS deqs 
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest 
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp 
        CROSS APPLY deqp.query_plan.nodes(N'//StmtSimple') RelOp (pln) 
WHERE   deqs.statement_end_offset > -1         
)    
SELECT  DB_NAME(qp.dbid), 
        * 
FROM    QueryPlans AS qp 
WHERE   (qp.dbid = 13 OR qp.dbid IS NULL) 
        AND qp.optimizationlevel = 'Timeout' 
ORDER BY qp.execution_count DESC ;





SELECT  DB_NAME(deqp.dbid), 
        SUBSTRING(dest.text, (deqs.statement_start_offset / 2) + 1, 
                  (CASE deqs.statement_end_offset 
                     WHEN -1 THEN DATALENGTH(dest.text) 
                     ELSE deqs.statement_end_offset 
                   END - deqs.statement_start_offset) / 2 + 1) AS StatementText, 
        deqs.statement_end_offset, 
        deqs.statement_start_offset, 
        deqp.query_plan, 
        deqs.execution_count, 
        deqs.total_elapsed_time, 
        deqs.total_logical_reads, 
        deqs.total_logical_writes 
FROM    sys.dm_exec_query_stats AS deqs 
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp 
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest 
WHERE   CAST(deqp.query_plan AS NVARCHAR(MAX)) LIKE '%StatementOptmEarlyAbortReason="TimeOut"%';



SELECT  DB_NAME(detqp.dbid),  
        SUBSTRING(dest.text, (deqs.statement_start_offset / 2) + 1, 
                  (CASE deqs.statement_end_offset 
                     WHEN -1 THEN DATALENGTH(dest.text) 
                     ELSE deqs.statement_end_offset 
                   END - deqs.statement_start_offset) / 2 + 1) AS StatementText, 
        CAST(detqp.query_plan AS XML), 
        deqs.execution_count, 
        deqs.total_elapsed_time, 
        deqs.total_logical_reads, 
        deqs.total_logical_writes 
FROM    sys.dm_exec_query_stats AS deqs 
        CROSS APPLY sys.dm_exec_text_query_plan(deqs.plan_handle, 
                                                deqs.statement_start_offset, 
                                                deqs.statement_end_offset) AS detqp 
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest 
WHERE   detqp.query_plan LIKE '%StatementOptmEarlyAbortReason="TimeOut"%';









--going after specific operators
SELECT  *
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   p.ProductID = 765;






WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
QueryPlans AS
(
SELECT RelOp.pln.value(N'@PhysicalOp', N'varchar(50)') AS OperatorName,
RelOp.pln.value(N'@NodeId',N'integer') AS NodeId,
RelOp.pln.value(N'(ComputeScalar/DefinedValues/DefinedValue/ScalarOperator/@ScalarString)[1]',N'varchar(250)') AS DefinedValue,
dest.text
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
CROSS APPLY deqp.query_plan.nodes(N'//RelOp') RelOp (pln)
)

SELECT  qp.OperatorName,
        qp.NodeId,
        qp.DefinedValue
FROM    QueryPlans AS qp
WHERE   qp.text LIKE 'SELECT  *
FROM    Sales.SalesOrderHeader AS soh%'
AND qp.DefinedValue LIKE '%CONVERT(nvarchar(23)%';










--live plans
SELECT * FROM sys.dm_exec_query_profiles AS deqp






--Run in seperate connection
SET STATISTICS XML ON;

SELECT  *
FROM    Production.TransactionHistory AS th
        INNER JOIN Production.TransactionHistoryArchive AS tha
        ON th.Quantity = tha.Quantity
WHERE   ISNUMERIC(th.Quantity) = 1;

SET STATISTICS XML OFF;






SELECT  deqp.cpu_time_ms,
        deqp.database_id,
        deqp.estimate_row_count,
		deqp.logical_read_count,
		deqp.node_id,
		deqp.physical_operator_name,
		deqp.row_count,
        deqp2.query_plan,
		dest.text
FROM    sys.dm_exec_query_profiles AS deqp
        CROSS APPLY sys.dm_exec_query_plan(deqp.plan_handle) AS deqp2
        CROSS APPLY sys.dm_exec_sql_text(deqp.sql_handle) AS dest












-- Parameter Sniffing

DROP PROCEDURE dbo.AddressByCity;
GO
--CREATE NONCLUSTERED INDEX ixCity ON Person.Address 
--(
--	City ASC
--)










CREATE PROC dbo.AddressByCity @City NVARCHAR(30)
AS
SELECT  a.AddressID,
        a.AddressLine1,
        a.AddressLine2,
        a.City,
        sp.Name AS StateProvinceName,
        a.PostalCode
FROM    Person.Address AS a
JOIN    Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   a.City = @City;






EXEC dbo.AddressByCity 'London'














-- showing that parameter sniffing helps
DECLARE @city NVARCHAR(30) = 'London' ;

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













--it's just statistics
DBCC SHOW_STATISTICS('Person.Address',_WA_Sys_00000004_164452B1);
















-- showing that parameter sniffing hurts

-- to get the plan_handle	
    SELECT  decp.plan_handle
    FROM    sys.dm_exec_cached_plans AS decp
            CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest
    WHERE   dest.[text] LIKE 'CREATE PROC dbo.AddressByCity%' ;


--to just remove the one plan from cache
    DBCC freeproccache(0x050005008946820F10C744980400000001000000000000000000000000000000000000000000000000000000) ;



EXEC dbo.AddressByCity 'Mentor';


EXEC dbo.AddressByCity 'London';










-- #1 Local variables
ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
AS 
-- I am not stupid, this is for parameter sniffing
DECLARE @LocalCity NVARCHAR(30) = @city;

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






EXEC dbo.AddressByCity 'London';








--#1a Variable Sniffing
ALTER PROC dbo.AddressByCity 
AS 
-- I am not stupid, this is for parameter sniffing
DECLARE @LocalCity NVARCHAR(30) = 'Mentor';

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

--again, setting the variable differently
SET @LocalCity = 'London';

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
GO


EXEC dbo.AddressByCity;



ALTER PROC dbo.AddressByCity 
AS 
-- I am not stupid, this is for parameter sniffing
DECLARE @LocalCity NVARCHAR(30) = 'Mentor';

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

--again, setting the variable differently
SET @LocalCity = 'London';

    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @LocalCity 
	OPTION (RECOMPILE);
GO


EXEC dbo.AddressByCity;



--#2 OPTIMIZE FOR <Value>

ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
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
    OPTION  (OPTIMIZE FOR (@City = 'Mentor')) ;



EXEC dbo.AddressByCity 'London';


















--#3 OPTIMIZE FOR UNKNOWN
ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
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
    OPTION  (OPTIMIZE FOR (@City UNKNOWN)) ;



EXEC dbo.AddressByCity 'London';

















--#4 WITH RECOMPILE
ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
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
    OPTION  (RECOMPILE) ;
    
    


EXEC dbo.AddressByCity 'London';





EXEC dbo.AddressByCity 'Mentor';














-- #5 STATS
ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
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


ALTER DATABASE AdventureWorks2014
SET AUTO_UPDATE_STATISTICS OFF;




BEGIN TRAN

UPDATE Person.Address
SET City = 'Mentor'
WHERE City = 'London'

EXEC dbo.AddressByCity @City = N'Mentor'


ROLLBACK TRAN

ALTER DATABASE AdventureWorks2014
SET AUTO_UPDATE_STATISTICS ON;













-- #6 Plan Guides
IF (SELECT  OBJECT_ID('AddressByCity')
   ) IS NOT NULL 
    DROP PROCEDURE dbo.AddressByCity ;
GO
CREATE PROC dbo.AddressByCity @City NVARCHAR(30)
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
    WHERE   a.City = @City;
    

EXEC sys.sp_create_plan_guide @name = 'SniffFix', -- sysname
    @stmt = N'SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City;', -- nvarchar(max)
    @type = N'Object', -- nvarchar(60)
    @module_or_batch = N'dbo.AddressByCity', -- nvarchar(max)
    @params = NULL, -- nvarchar(max)
    @hints = N'OPTION(OPTIMIZE FOR(@City = ''Mentor''))' -- nvarchar(max)





EXEC dbo.AddressByCity @City = N'London'




--clean up
EXEC sys.sp_control_plan_guide  @operation = N'DROP', -- nvarchar(60)
    @name = SniffFix -- sysname
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
--#7 Turn off parameter sniffing

DBCC TRACEON (4136,-1)


ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
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






EXEC dbo.AddressByCity 'London'



DBCC TRACEOFF (4136,-1)
