USE AdventureWorks;
GO

ALTER DATABASE AdventureWorks SET QUERY_STORE = ON;














GO

CREATE  OR ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
AS
   SELECT a.AddressID,
      a.AddressLine1,
      a.AddressLine2,
      a.City,
      sp.Name AS StateProvinceName,
      a.PostalCode
   FROM Person.Address AS a
   JOIN Person.StateProvince AS sp
      ON a.StateProvinceID = sp.StateProvinceID
   WHERE a.City = @City;




EXEC dbo.AddressByCity
    @City = N'London';



SELECT  qsq.query_id,
        qsqt.query_text_id,
        qsqt.query_sql_text
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;









ALTER DATABASE AdventureWorks SET QUERY_STORE = OFF;



SELECT  qsq.query_id,
        qsqt.query_text_id,
        qsqt.query_sql_text
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;



SELECT  *
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
WHERE   sod.SalesOrderID = 49386;




SELECT  qsq.query_id,
        qsqt.query_text_id,
        qsqt.query_sql_text
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;



ALTER DATABASE AdventureWorks SET QUERY_STORE CLEAR;



SELECT  qsq.query_id,
        qsqt.query_text_id,
        qsqt.query_sql_text
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;




ALTER DATABASE AdventureWorks SET QUERY_STORE = ON;










--gather data about query store
SELECT * FROM sys.database_query_store_options AS dqso;



--modify query store behavior

ALTER DATABASE AdventureWorks SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 2000);
 


ALTER DATABASE AdventureWorks SET QUERY_STORE (MAX_PLANS_PER_QUERY = 20);





--before a planned reboot
--writes in-memory information to disk
EXEC sys.sp_query_store_flush_db;





--back to slides











--query stats
EXEC dbo.AddressByCity
    @City = N'London';





SELECT  *
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;





SELECT  qsqt.query_sql_text,
        qsqt.statement_sql_handle,
        qsq.object_id,
        qsq.query_parameterization_type_desc,
        qsq.last_execution_time,
        qsq.count_compiles,
        qsq.avg_optimize_duration,
        qsq.avg_compile_duration
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;



SELECT  deqs.last_execution_time,
        qsqt.query_sql_text
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
JOIN    sys.dm_exec_query_stats AS deqs
        ON qsqt.statement_sql_handle = deqs.statement_sql_handle;




SELECT * FROM sys.query_store_wait_stats AS qsws









select qsqt.query_sql_text,
        qsq.avg_compile_duration,
        CAST(qsp.query_plan AS XML),
		qsp.query_plan,
        qsrs.execution_type_desc,
        qsrs.count_executions,
        qsrs.avg_duration,
        qsrs.min_duration,
        qsrs.max_duration,
        qsrs.avg_cpu_time,
        qsrs.avg_logical_io_reads,
        qsrs.avg_logical_io_writes,
        qsrs.avg_physical_io_reads,
        qsrs.avg_query_max_used_memory,
        qsrs.avg_rowcount
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
JOIN    sys.query_store_runtime_stats AS qsrs
        ON qsrs.plan_id = qsp.plan_id
WHERE   qsq.object_id = OBJECT_ID('dbo.AddressByCity');




--Workaround
--no longer needed as of 1/16
SELECT qsqt.query_sql_text,
        qsq.avg_compile_duration,
        qsp.query_plan,
        qsrs.execution_type_desc,
        qsrs.count_executions,
        qsrs.avg_duration,
        qsrs.min_duration,
        qsrs.max_duration,
        qsrs.avg_cpu_time,
        qsrs.avg_logical_io_reads,
        qsrs.avg_logical_io_writes,
        qsrs.avg_physical_io_reads,
        qsrs.avg_query_max_used_memory,
        qsrs.avg_rowcount
		INTO #Buffer
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
JOIN    sys.query_store_runtime_stats AS qsrs
        ON qsrs.plan_id = qsp.plan_id
WHERE   qsq.object_id = OBJECT_ID('dbo.AddressByCity')


SELECT CAST(b.query_plan AS XML), *
FROM #Buffer AS b


DROP TABLE #Buffer;





EXEC dbo.AddressByCity
    @City = N'Mentor'




SELECT * FROM sys.query_store_runtime_stats AS qsrs

SELECT * FROM sys.query_context_settings AS qcs




--finding a query
--sys.fn_stmt_sql_handle_from_sql_stmt
SELECT  qt.query_text_id,
        q.query_id,
        qt.query_sql_text,
        qt.statement_sql_handle,
        q.context_settings_id,
        qs.statement_context_id
FROM    sys.query_store_query_text AS qt
JOIN    sys.query_store_query AS q
        ON qt.query_text_id = q.query_id
CROSS APPLY sys.fn_stmt_sql_handle_from_sql_stmt(qt.query_sql_text, NULL) AS fn_handle_from_stmt
JOIN    sys.dm_exec_query_stats AS qs
        ON fn_handle_from_stmt.statement_sql_handle = qs.statement_sql_handle;




--these values are the same, plus I used the qsq.query_parameterization_type....
SELECT  qsqt.statement_sql_handle,
        fsshfss.statement_sql_handle,
        deqs.statement_sql_handle,
        qsqt.query_sql_text
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
LEFT JOIN sys.dm_exec_query_stats AS deqs
        ON qsqt.statement_sql_handle = deqs.statement_sql_handle
CROSS APPLY sys.fn_stmt_sql_handle_from_sql_stmt(qsqt.query_sql_text,
                                                 qsq.query_parameterization_type)
        AS fsshfss;




SELECT  e.NationalIDNumber,
        p.LastName,
        p.FirstName,
        a.City,
        bea.AddressTypeID
FROM    HumanResources.Employee AS e
JOIN    Person.BusinessEntityAddress AS bea
        ON bea.BusinessEntityID = e.BusinessEntityID
JOIN    Person.Address AS a
        ON a.AddressID = bea.AddressID
JOIN    Person.Person AS p
        ON p.BusinessEntityID = e.BusinessEntityID
WHERE   p.LastName = 'Hamilton';


SELECT * FROM sys.query_store_query_text AS qsqt
WHERE qsqt.query_sql_text = 'SELECT  e.NationalIDNumber,
        p.LastName,
        p.FirstName,
        a.City,
        bea.AddressTypeID
FROM    HumanResources.Employee AS e
JOIN    Person.BusinessEntityAddress AS bea
        ON bea.BusinessEntityID = e.BusinessEntityID
JOIN    Person.Address AS a
        ON a.AddressID = bea.AddressID
JOIN    Person.Person AS p
        ON p.BusinessEntityID = e.BusinessEntityID
WHERE   p.LastName = ''Hamilton'';';





SELECT  *
FROM    Production.BillOfMaterials AS bom
WHERE   bom.BillOfMaterialsID = 2363;




SELECT  *
FROM    sys.query_store_query_text AS qsqt
WHERE   qsqt.query_sql_text = 'SELECT  *
FROM    Production.BillOfMaterials AS bom
WHERE   bom.BillOfMaterialsID = 2363';






SELECT  *
FROM    sys.query_store_query_text AS qsqt
JOIN    sys.query_store_query AS qsq
        ON qsq.query_text_id = qsqt.query_text_id
CROSS APPLY sys.fn_stmt_sql_handle_from_sql_stmt('SELECT  *
FROM    Production.BillOfMaterials AS bom
WHERE   bom.BillOfMaterialsID = 2363;', qsq.query_parameterization_type) AS fsshfss;





SELECT  qsqt.*
FROM    sys.query_store_query_text AS qsqt
JOIN    sys.query_store_query AS qsq
        ON qsq.query_text_id = qsqt.query_text_id
WHERE   qsq.object_id = OBJECT_ID('dbo.AddressByCity');




SELECT  *
FROM    sys.query_store_query_text AS qsqt
WHERE   qsqt.query_sql_text = 'SELECT  a.AddressID,
        a.AddressLine1,
        a.AddressLine2,
        a.City,
        sp.Name AS StateProvinceName,
        a.PostalCode
FROM    Person.Address AS a
JOIN    Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   a.City = @City'




SELECT  qsqt.*
FROM    sys.query_store_query_text AS qsqt
CROSS APPLY sys.fn_stmt_sql_handle_from_sql_stmt('SELECT  a.AddressID,
        a.AddressLine1,
        a.AddressLine2,
        a.City,
        sp.Name AS StateProvinceName,
        a.PostalCode
FROM    Person.Address AS a
JOIN    Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   a.City = @City;', NULL) AS fsshfss



SELECT  qsqt.*
FROM    sys.query_store_query_text AS qsqt
WHERE qsqt.query_sql_text LIKE '%SELECT  a.AddressID,
        a.AddressLine1,
        a.AddressLine2,
        a.City,
        sp.Name AS StateProvinceName,
        a.PostalCode
FROM    Person.Address AS a
JOIN    Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   a.City = @City%';









--picking up info between two points in time
DECLARE @Basetime DATETIME, @comparetime DATETIME
SET @BaseTime = '2019-6-12 14:20';
SET @CompareTime = '2019-6-12 15:40';
 
WITH CoreQuery
AS (SELECT qsp.query_id,
       qsqt.query_sql_text,
       qsp.query_plan,
       qsrs.execution_type_desc,
       qsrs.count_executions,
       qsrs.avg_duration,
       qsrs.max_duration,
       qsrs.stdev_duration,
       qsrsi.start_time,
       qsrsi.end_time
    FROM sys.query_store_runtime_stats AS qsrs
    JOIN sys.query_store_runtime_stats_interval AS qsrsi
       ON qsrsi.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
    JOIN sys.query_store_plan AS qsp
       ON qsp.plan_id = qsrs.plan_id
	JOIN sys.query_store_wait_stats AS qsws
	ON qsws.plan_id = qsp.plan_id
    JOIN sys.query_store_query AS qsq
       ON qsq.query_id = qsp.query_id
    JOIN sys.query_store_query_text AS qsqt
       ON qsqt.query_text_id = qsq.query_text_id
   ),
BaseData
AS (SELECT *
    FROM CoreQuery AS cq
    WHERE cq.start_time < @BaseTime
          AND cq.end_time > @BaseTime
   ),
CompareData
AS (SELECT *
    FROM CoreQuery AS cq
    WHERE cq.start_time < @CompareTime
          AND cq.end_time > @CompareTime
   )
SELECT bd.query_sql_text,
   bd.query_plan,
   bd.avg_duration AS BaseAverage,
   bd.stdev_duration AS BaseStDev,
   cd.avg_duration AS CompareAvg,
   cd.stdev_duration AS CompareStDev,
   cd.count_executions AS CompareExecCount
FROM BaseData AS bd
JOIN CompareData AS cd
   ON bd.query_id = cd.query_id
WHERE cd.max_duration > bd.max_duration;



--using the wait statistics







--seeing different plans for a query
EXEC dbo.AddressByCity
    @City = N'London';


DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.objectid = OBJECT_ID('dbo.AddressByCity')

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.AddressByCity
    @City = N'Mentor';



SELECT  qsq.query_id,
        qsqt.query_text_id,
        qsqt.query_sql_text,
		qsp.query_plan,
		qsp.last_execution_time,
		qsq.avg_compile_duration
INTO #Buffer
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
		JOIN sys.query_store_plan AS qsp
		ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.AddressByCity');

SELECT CAST(b.query_plan AS XML),* 
FROM #Buffer AS b

DROP TABLE #Buffer









-- take control of query store
DECLARE @PlanID INT;

SELECT TOP 1
        @PlanID = qsp.plan_id
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsq.object_id = OBJECT_ID('dbo.AddressByCity');

EXEC sys.sp_query_store_reset_exec_stats
    @plan_id = @PlanID;



DECLARE @queryid INT 

SELECT  @queryid = qsq.query_id
FROM    sys.query_store_query_text AS qsqt
JOIN    sys.query_store_query AS qsq
        ON qsq.query_text_id = qsqt.query_text_id
WHERE   qsqt.query_sql_text = 'SELECT  e.NationalIDNumber,
        p.LastName,
        p.FirstName,
        a.City,
        bea.AddressTypeID
FROM    HumanResources.Employee AS e
JOIN    Person.BusinessEntityAddress AS bea
        ON bea.BusinessEntityID = e.BusinessEntityID
JOIN    Person.Address AS a
        ON a.AddressID = bea.AddressID
JOIN    Person.Person AS p
        ON p.BusinessEntityID = e.BusinessEntityID
WHERE   p.LastName = ''Hamilton'''

EXEC sys.sp_query_store_remove_query
    @query_id = @queryid;






DECLARE @PlanID INT;

SELECT TOP 1
        @PlanID = qsp.plan_id
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsq.object_id = OBJECT_ID('dbo.AddressByCity');

EXEC sys.sp_query_store_remove_plan @plan_id = @PlanID;








--GUI







SELECT  *
FROM    sys.dm_os_wait_stats AS dows
WHERE   dows.wait_type LIKE '%qds%';













--GUI & ex events







--in memory
--sys.sp_xtp_control_query_exec_stats 


--SELECT  qsp.force_failure_count,
--        qsp.last_force_failure_reason_desc
--FROM    sys.query_store_plan AS qsp





--back to slides




--plan forcing
EXEC dbo.AddressByCity
    @City = N'London';



DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE '%PROC dbo.AddressByCity%'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.AddressByCity
    @City = N'Mentor';



EXEC dbo.AddressByCity
    @City = N'London';






SELECT  qsq.query_id,
        qsqt.query_text_id,
		qsp.plan_id,
        qsqt.query_sql_text,
		--CAST(qsp.query_plan AS XML),
		qsp.last_execution_time,
		qsq.avg_compile_duration
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
		JOIN sys.query_store_plan AS qsp
		ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.AddressByCity');





DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE '%dbo.AddressByCity%'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.AddressByCity
    @City = N'Mentor';



EXEC dbo.AddressByCity
    @City = N'London';







EXEC sys.sp_query_store_force_plan 2,1;








SELECT  qsq.query_id,
        qsp.plan_id,
		CAST(qsp.query_plan AS XML)
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsq.object_id = OBJECT_ID('dbo.AddressByCity');






SELECT  qsq.query_id,
        qsp.plan_id,
		CAST(qsp.query_plan AS XML)
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsp.is_forced_plan = 1;




--undoing plan forcing
EXEC sys.sp_query_store_unforce_plan 1996,2122;



DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROC dbo.AddressByCity%'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.AddressByCity
    @City = N'London';




--gui










--extra script for a different database
CREATE PROCEDURE dbo.POInfo (@SupplierID INT)
AS
   SELECT s.SupplierName,
          dm.DeliveryMethodName,
          po.OrderDate,
          po.ExpectedDeliveryDate
   FROM Purchasing.PurchaseOrders AS po
   JOIN Application.DeliveryMethods AS dm
      ON dm.DeliveryMethodID = po.DeliveryMethodID
   JOIN Purchasing.Suppliers AS s
      ON s.SupplierID = po.SupplierID
   WHERE po.SupplierID = @SupplierID;
GO

--4 or 2

EXEC dbo.POInfo 
    @SupplierID = 2;



	DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deps.plan_handle 
FROM sys.dm_exec_procedure_stats AS deps
WHERE deps.object_id = OBJECT_ID('dbo.POInfo')

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO

EXEC dbo.POInfo
    @SupplierID = 4;

