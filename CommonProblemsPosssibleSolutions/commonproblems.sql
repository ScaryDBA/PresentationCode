--foreign keys
SELECT p.LastName + ',' + p.FirstName AS PersonName
FROM Person.Address AS a
    JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
    JOIN Person.BusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
    JOIN Person.Person AS p
        ON be.BusinessEntityID = p.BusinessEntityID;
--GO 50


SELECT p.LastName + ',' + p.FirstName AS PersonName
FROM dbo.MyAddress AS a
    JOIN dbo.MyBusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
    JOIN dbo.MyBusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
    JOIN dbo.MyPerson AS p
        ON be.BusinessEntityID = p.BusinessEntityID;
--GO 50




SELECT  *
INTO    dbo.MyAddress
FROM    Person.Address;

SELECT  *
INTO    dbo.MyBusinessEntityAddress
FROM    Person.BusinessEntityAddress;

SELECT  *
INTO    dbo.MyBusinessEntity
FROM    Person.BusinessEntity;

SELECT  *
INTO    dbo.MyPerson
FROM    Person.Person;


--check constraints
SELECT soh.OrderDate,
       soh.ShipDate,
       sod.OrderQty,
       sod.UnitPrice,
       p.Name AS ProductName
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE p.Name = 'Water Bottle - 30 oz.';


SELECT soh.OrderDate,
       soh.ShipDate,
       sod.OrderQty,
       sod.UnitPrice,
       p.Name AS ProductName
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE p.Name = 'Water Bottle - 30 oz.'
      AND sod.UnitPrice < $0.0;




--unique constraint
CREATE NONCLUSTERED INDEX AK_Product_Name
ON Production.Product (Name ASC)
WITH (DROP_EXISTING = ON)
ON [PRIMARY];


SELECT DISTINCT
       p.Name
FROM Production.Product AS p;



CREATE UNIQUE NONCLUSTERED INDEX AK_Product_Name
ON Production.Product (Name ASC)
WITH (DROP_EXISTING = ON)
ON [PRIMARY];






--Execution plan cost
WITH XMLNAMESPACES
(
    DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
, TextPlans
AS (SELECT CAST(detqp.query_plan AS XML) AS QueryPlan,
           detqp.dbid
    FROM sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_text_query_plan(
                                                   deqs.plan_handle,
                                                   deqs.statement_start_offset,
                                                   deqs.statement_end_offset
                                               ) AS detqp ),
  QueryPlans
AS (SELECT RelOp.pln.value(N'@EstimatedTotalSubtreeCost', N'float') AS EstimatedCost,
           RelOp.pln.value(N'@NodeId', N'integer') AS NodeId,
           tp.dbid,
           tp.QueryPlan
    FROM TextPlans AS tp
        CROSS APPLY tp.queryplan.nodes(N'//RelOp') AS RelOp(pln) )
SELECT qp.EstimatedCost
FROM QueryPlans AS qp
WHERE qp.NodeId = 0;




WITH XMLNAMESPACES
(
    DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
, QueryStore
AS (SELECT CAST(qsp.query_plan AS XML) AS QueryPlan
    FROM sys.query_store_plan AS qsp),
  QueryPlans
AS (SELECT RelOp.pln.value(N'@EstimatedTotalSubtreeCost', N'float') AS EstimatedCost,
           RelOp.pln.value(N'@NodeId', N'integer') AS NodeId,
           qs.QueryPlan
    FROM QueryStore AS qs
        CROSS APPLY qs.queryplan.nodes(N'//RelOp') AS RelOp(pln) )
SELECT qp.EstimatedCost
FROM QueryPlans AS qp
WHERE qp.NodeId = 0;










--statistics

DBCC SHOW_STATISTICS('Person.Address', [_WA_Sys_00000004_3D5E1FD2]);









SELECT ddsp.stats_id,
       s.name,
       s.filter_definition,
       ddsp.last_updated,
       ddsp.rows,
       ddsp.rows_sampled,
       ddsp.steps,
       ddsp.unfiltered_rows,
       ddsp.modification_counter
FROM sys.stats AS s
    CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS ddsp
WHERE s.object_id = OBJECT_ID('Person.Address');












SELECT *
FROM sys.dm_db_stats_histogram(OBJECT_ID('Person.Address'), 5) AS ddsh;






WITH histo
AS (SELECT ddsh.step_number,
           ddsh.range_high_key,
           ddsh.range_rows,
           ddsh.equal_rows,
           ddsh.average_range_rows
    FROM sys.dm_db_stats_histogram(OBJECT_ID('HumanResources.Employee'),
                                   1) AS ddsh ),
     histojoin
AS (SELECT h1.step_number,
           h1.range_high_key,
           h2.range_high_key AS range_high_key_step1,
           h1.range_rows,
           h1.equal_rows,
           h1.average_range_rows
    FROM histo AS h1
        LEFT JOIN histo AS h2
            ON h1.step_number = h2.step_number + 1)
SELECT hj.range_high_key,
       hj.equal_rows,
       hj.average_range_rows
FROM histojoin AS hj
WHERE hj.range_high_key >= 17
      AND (   hj.range_high_key_step1 < 17
              OR hj.range_high_key_step1 IS NULL);