USE AdventureWorks2014;
GO


ALTER DATABASE AdventureWorks2014 SET QUERY_STORE = ON;


EXEC dbo.spAddressByCity
    @City = N'London';



SELECT  qsq.query_id,
        qsqt.query_text_id,
        qsqt.query_sql_text
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;









ALTER DATABASE AdventureWorks2014 SET QUERY_STORE = OFF;



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



ALTER DATABASE AdventureWorks2014 SET QUERY_STORE CLEAR;



SELECT  qsq.query_id,
        qsqt.query_text_id,
        qsqt.query_sql_text
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;




ALTER DATABASE AdventureWorks2014 SET QUERY_STORE = ON;










--gather data about query store
SELECT * FROM sys.database_query_store_options AS dqso



--modify query store behavior

ALTER DATABASE AdventureWorks2014 SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 200);
 


ALTER DATABASE AdventureWorks2014 SET QUERY_STORE (MAX_PLANS_PER_QUERY = 20);





--before a planned reboot
--writes in-memory information to disk
EXEC sys.sp_query_store_flush_db;





--back to slides











--query stats
EXEC dbo.spAddressByCity
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














SELECT  qsqt.query_sql_text,
        qsq.avg_compile_duration,
        CAST(qsp.query_plan AS XML),
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
WHERE   qsq.object_id = OBJECT_ID('dbo.spAddressByCity');


EXEC dbo.spAddressByCity
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
WHERE   p.LastName = ''Hamilton''';





SELECT  *
FROM    Production.BillOfMaterials AS bom
WHERE   bom.BillOfMaterialsID = 2363;




SELECT  *
FROM    sys.query_store_query_text AS qsqt
WHERE   qsqt.query_sql_text = 'SELECT  *
FROM    Production.BillOfMaterials AS bom
WHERE   bom.BillOfMaterialsID = 2363';






SELECT  qsqt.*
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
WHERE   qsq.object_id = OBJECT_ID('dbo.spAddressByCity');




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













--seeing different plans for a query
EXEC dbo.spAddressByCity
    @City = N'London';



DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROC dbo.spAddressByCity%'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.spAddressByCity
    @City = N'Mentor';



SELECT  qsq.query_id,
        qsqt.query_text_id,
        qsqt.query_sql_text,
		CAST(qsp.query_plan AS XML),
		qsp.last_execution_time,
		qsq.avg_compile_duration
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
		JOIN sys.query_store_plan AS qsp
		ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.spAddressByCity');











-- take control of query store
DECLARE @PlanID INT;

SELECT TOP 1
        @PlanID = qsp.plan_id
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsq.object_id = OBJECT_ID('dbo.spAddressByCity');

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
WHERE   qsq.object_id = OBJECT_ID('dbo.spAddressByCity');

EXEC sys.sp_query_store_remove_plan @plan_id =@PlanID;








--GUI
--back to slides







SELECT  *
FROM    sys.dm_os_wait_stats AS dows
WHERE   dows.wait_type LIKE '%qds%';













--GUI & ex events
--back to slides







--in memory
sys.sp_xtp_control_query_exec_stats 


SELECT  qsp.force_failure_count,
        qsp.last_force_failure_reason_desc
FROM    sys.query_store_plan AS qsp





--back to slides






--plan forcing
EXEC dbo.spAddressByCity
    @City = N'London';



DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROC dbo.spAddressByCity%'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.spAddressByCity
    @City = N'Mentor';



EXEC dbo.spAddressByCity
    @City = N'London';






SELECT  qsq.query_id,
        qsqt.query_text_id,
		qsp.plan_id,
        qsqt.query_sql_text,
		CAST(qsp.query_plan AS XML),
		qsp.last_execution_time,
		qsq.avg_compile_duration
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
		JOIN sys.query_store_plan AS qsp
		ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.spAddressByCity');





DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROC dbo.spAddressByCity%'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.spAddressByCity
    @City = N'Mentor';



EXEC dbo.spAddressByCity
    @City = N'London';







EXEC sys.sp_query_store_force_plan 2,420;








SELECT  qsq.query_id,
        qsp.plan_id,
        CAST(qsp.query_plan AS XML) AS sqlplan
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsq.object_id = OBJECT_ID('dbo.spAddressByCity');








--undoing plan forcing
EXEC sys.sp_query_store_unforce_plan 2,420;



DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROC dbo.spAddressByCity%'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


EXEC dbo.spAddressByCity
    @City = N'London';




--gui




