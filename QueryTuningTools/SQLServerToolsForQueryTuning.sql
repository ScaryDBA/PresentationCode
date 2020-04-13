--Extended Events
--start at powershell
USE AdventureWorks2014;
GO


--Recompiles
BEGIN TRAN

UPDATE Person.Address
SET City = 'Louisville';

EXEC dbo.AddressByCity @City = N'Louisville' -- nvarchar(30)

ROLLBACK TRAN




DBCC SHOW_STATISTICS('Person.Address',_WA_Sys_00000004_164452B1)

UPDATE STATISTICS Person.Address










--Multiple statements in a procedure
DECLARE @date DATETIME
SET @date = GETUTCDATE()

EXEC HumanResources.uspUpdateEmployeeHireInfo @BusinessEntityID = 23,               -- int
                                              @JobTitle = N'Lord High Executioner', -- nvarchar(50)
                                              @HireDate = '1922-08-02 18:20:54',    -- datetime
                                              @RateChangeDate = @date,              -- datetime
                                              @Rate = .5,                           -- money
                                              @PayFrequency = 1,                    -- tinyint
                                              @CurrentFlag = NULL                   -- Flag

--then powershell




--deadlocks

BEGIN TRANSACTION
UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 2
WHERE ProductID = 448
      AND PurchaseOrderID = 1255;

--ROLLBACK TRANSACTION


--copy this to a second connection
--run the first statement
BEGIN TRANSACTION
UPDATE Purchasing.PurchaseOrderHeader
SET Freight = Freight * 0.9 --9% discount on shipping
WHERE PurchaseOrderID = 1255;

--run the second separately
UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 4
WHERE ProductID = 448
      AND PurchaseOrderID = 1255;

--probably not needed
--ROLLBACK




--extended event execution plan
SELECT  c.CustomerID,
        a.City,
        s.Name,
        st.Name
FROM    Sales.Customer AS c
JOIN    Sales.Store AS s
        ON c.StoreID = s.BusinessEntityID
JOIN    Sales.SalesTerritory AS st
        ON c.TerritoryID = st.TerritoryID
JOIN    Person.BusinessEntityAddress AS bea
        ON c.CustomerID = bea.BusinessEntityID
JOIN    Person.Address AS a
        ON bea.AddressID = a.AddressID
JOIN    Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   st.Name = 'Northeast'
        AND sp.Name = 'New York';










--reading the file
SELECT *,
       CAST(fx.event_data AS XML)
FROM sys.fn_xe_file_target_read_file('c:\perfdata\QueryPerformance_*.xel', NULL, NULL, NULL) AS fx;








WITH fxd
AS (SELECT CAST(fx.event_data AS XML) AS Event_Data
    FROM sys.fn_xe_file_target_read_file('c:\perfdata\QueryPerformance_*.xel', NULL, NULL, NULL) AS fx
   )
SELECT *
FROM fxd










--QUERY STORE
USE AdventureWorks2014;
GO

ALTER DATABASE AdventureWorks2014 SET QUERY_STORE = ON;






GO
CREATE OR ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
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







SELECT qsqt.query_sql_text,
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
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
    JOIN sys.query_store_runtime_stats AS qsrs
        ON qsrs.plan_id = qsp.plan_id
    JOIN sys.query_store_wait_stats AS qsws
        ON qsws.plan_id = qsp.plan_id
WHERE qsq.object_id = OBJECT_ID('dbo.AddressByCity');









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
		--dbcc freeproccache()
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
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
		JOIN sys.query_store_plan AS qsp
		ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.AddressByCity');














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


--EXEC sys.sp_query_store_remove_query 15




DECLARE @PlanID INT;

SELECT TOP 1
        @PlanID = qsp.plan_id
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsq.object_id = OBJECT_ID('dbo.AddressByCity');

EXEC sys.sp_query_store_remove_plan @plan_id =@PlanID;













--Monitoring Query Store Behavior
SELECT  *
FROM    sys.dm_os_wait_stats AS dows
WHERE   dows.wait_type LIKE '%qds%';



--Extended Events




























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







EXEC sys.sp_query_store_force_plan 3,13;








SELECT  qsq.query_id,
        qsp.plan_id--,
        --CAST(qsp.query_plan AS XML) AS sqlplan
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsq.object_id = OBJECT_ID('dbo.AddressByCity');








--undoing plan forcing
EXEC sys.sp_query_store_unforce_plan 3,13;



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



























--DMVs
--Transaction related
--Maybe restart the load generator

SELECT *
FROM sys.dm_tran_locks AS dtlo






















SELECT *
FROM sys.dm_tran_active_transactions AS dtat











SELECT *
FROM sys.dm_tran_database_transactions AS dtdt





--blocking



BEGIN TRANSACTION
UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 2
WHERE ProductID = 448
      AND PurchaseOrderID = 1255;



UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 4
WHERE ProductID = 448
      AND PurchaseOrderID = 1255;
	  ROLLBACK TRAN





SELECT dtl.resource_type,
       dtl.resource_database_id,
       DB_NAME(dtl.resource_database_id),
       dowt.session_id,
       dowt.blocking_session_id,
	   dtl.request_mode,
	   dtl.resource_description
FROM sys.dm_tran_locks AS dtl
    JOIN sys.dm_os_waiting_tasks AS dowt
        ON dtl.lock_owner_address = dowt.waiting_task_address;









SELECT dtat.name,
       dtat.transaction_id,
       dtat.transaction_begin_time,
       dtat.transaction_type,
       dtat.transaction_state,
       dtat.transaction_status
FROM sys.dm_tran_active_transactions dtat
    INNER JOIN sys.dm_tran_session_transactions dtst
        ON dtat.transaction_id = dtat.transaction_id
WHERE dtst.is_user_transaction = 1;












--index related

SELECT * FROM sys.dm_db_index_usage_stats AS ddius





SELECT *
FROM sys.dm_db_index_operational_stats(
                                          DB_ID('AdventureWorks2014'),
                                          OBJECT_ID('Purchasing.PurchaseOrderDetail'),
                                          NULL, --IndexID
                                          NULL  --PartitionID
                                      ) AS ddios


BEGIN TRAN
UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 4
WHERE ProductID = 448
      AND PurchaseOrderID = 1255;

ROLLBACK TRAN 


SELECT *
FROM sys.dm_db_index_physical_stats(
                                       DB_ID('AdventureWorks2014'),
                                       OBJECT_ID('Purchasing.PurchaseOrderDetail'),
                                       NULL,
                                       NULL,
                                       'LIMITED'
                                   ) AS ddips




SELECT ddius.user_lookups,
       ddius.user_scans,
       ddius.user_seeks,
       ddius.user_updates,
       ddius.index_id
FROM sys.dm_db_index_usage_stats AS ddius
WHERE ddius.database_id = DB_ID(N'AdventureWorks2014')
      AND ddius.object_id = OBJECT_ID('Purchasing.PurchaseOrderDetail')
      AND ddius.index_id = 1;




SELECT *
FROM Production.TransactionHistory AS th
WHERE th.TransactionDate > '7/31/2014'
      AND th.TransactionDate < '8/2/2014'
ORDER BY th.TransactionDate DESC;


--straight out of Books Online
SELECT mig.*,
       mid.statement AS table_name,
       column_id,
       column_name,
       column_usage
FROM sys.dm_db_missing_index_details AS mid
    CROSS APPLY sys.dm_db_missing_index_columns(mid.index_handle)
    INNER JOIN sys.dm_db_missing_index_groups AS mig
        ON mig.index_handle = mid.index_handle
ORDER BY mig.index_group_handle,
         mig.index_handle,
         column_id;

























--Execution related
SELECT	*
FROM	sys.dm_exec_requests AS der;





















SELECT	*
FROM	sys.dm_exec_query_stats AS deqs;


















SELECT	*
FROM	sys.dm_exec_procedure_stats AS deps;










SELECT	*
FROM	sys.dm_exec_query_stats AS deqs
		CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
		CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest;








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











--missing indexes with a query and query plan

WITH XMLNAMESPACES
(
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT deqp.query_plan.value(
                             N'(//MissingIndex/@Database)[1]',
                             'NVARCHAR(256)'
                         ) AS DatabaseName,
       dest.text AS QueryText,
       deqs.total_elapsed_time,
       deqs.last_execution_time,
       deqs.execution_count,
       deqs.total_logical_writes,
       deqs.total_logical_reads,
       deqs.min_elapsed_time,
       deqs.max_elapsed_time,
       deqp.query_plan,
       deqp.query_plan.value(
                             N'(//MissingIndex/@Table)[1]',
                             'NVARCHAR(256)'
                         ) AS TableName,
       deqp.query_plan.value(
                             N'(//MissingIndex/@Schema)[1]',
                             'NVARCHAR(256)'
                         ) AS SchemaName,
       deqp.query_plan.value(
                             N'(//MissingIndexGroup/@Impact)[1]',
                             'DECIMAL(6,4)'
                         ) AS ProjectedImpact,
       ColumnGroup.value('./@Usage', 'NVARCHAR(256)') AS ColumnGroupUsage,
       ColumnGroupColumn.value('./@Name', 'NVARCHAR(256)') AS ColumnName
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
CROSS APPLY deqp.query_plan.nodes('//MissingIndexes/MissingIndexGroup/MissingIndex/ColumnGroup') AS t1(ColumnGroup)
CROSS APPLY t1.ColumnGroup.nodes('./Column') AS t2(ColumnGroupColumn)
    







--querying the plan directly
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
ORDER BY EstimatedCost DESC







--Combining all the fun
BEGIN TRANSACTION
UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 2
WHERE ProductID = 448
      AND PurchaseOrderID = 1255;
--rollback transaction

--run in a separate window
UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 4
WHERE ProductID = 448;
--rollback transaction



SELECT dtl.request_session_id AS session_id,
       DB_NAME(dtl.resource_database_id) AS DatabaseName,
       dtl.resource_type,
       CASE
           WHEN dtl.resource_type IN ( 'DATABASE', 'FILE', 'METADATA' ) THEN
               dtl.resource_type
           WHEN dtl.resource_type = 'OBJECT' THEN
               OBJECT_NAME(dtl.resource_associated_entity_id, dtl.resource_database_id)
           WHEN dtl.resource_type IN ( 'KEY', 'PAGE', 'RID' ) THEN
           (
               SELECT OBJECT_NAME(object_id)
               FROM sys.partitions
               WHERE hobt_id = dtl.resource_associated_entity_id
           )
           ELSE
               'Unidentified'
       END AS [Parent Object],
       dtl.request_mode AS [Lock Type],
       dtl.request_status AS [Request Status],
       der.blocking_session_id,
       des.login_name,
       CASE dtl.request_lifetime
           WHEN 0 THEN
               destr.text
           ELSE
               dest.text
       END AS Statement
FROM sys.dm_tran_locks AS dtl
    LEFT JOIN sys.dm_exec_requests der
        ON dtl.request_session_id = der.session_id
    INNER JOIN sys.dm_exec_sessions des
        ON dtl.request_session_id = des.session_id
    INNER JOIN sys.dm_exec_connections dec
        ON dtl.request_session_id = dec.most_recent_session_id
    OUTER APPLY sys.dm_exec_sql_text(dec.most_recent_sql_handle) AS dest
    OUTER APPLY sys.dm_exec_sql_text(der.sql_handle) AS destr
WHERE dtl.resource_database_id = DB_ID()
      AND dtl.resource_type NOT IN ( 'DATABASE', 'METADATA' )
ORDER BY dtl.request_session_id;

















--SSMS Tools
SELECT p.Name,
       p.ProductNumber,
       pc.Name AS SubCategoryName,
       pi.Shelf,
       pi.Bin,
       pi.Quantity
FROM Production.Product AS p
    JOIN Production.ProductInventory AS pi
        ON pi.ProductID = p.ProductID
    JOIN Production.ProductCategory AS pc
        ON p.ProductSubcategoryID = pc.ProductCategoryID
WHERE p.ListPrice > 200;




SELECT p.Name,
       p.ProductNumber,
       pc.Name AS SubCategoryName,
       pi.Shelf,
       pi.Bin,
       pi.Quantity
FROM Production.Product AS p
    JOIN Production.ProductInventory AS pi
        ON pi.ProductID = p.ProductID
    JOIN Production.ProductCategory AS pc
        ON p.ProductSubcategoryID = pc.ProductCategoryID
WHERE p.ListPrice > 3000;





SELECT *
FROM Production.Product AS p
WHERE p.ProductID = 356;









--shortcomings of I/O


--Badly formed ORM query
--No, not picking on ORM tools
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





--simulating the query
DECLARE @p1 INT,
    @p2 INT,
    @p3 INT,
    @p4 INT,
    @p5 INT,
    @p6 INT,
    @p7 INT,
    @p8 INT,
    @p9 INT,
    @p10 INT,
    @p11 INT,
    @p12 INT,
    @p13 INT,
    @p14 INT,
    @p15 INT,
    @p16 INT,
    @p17 INT,
    @p18 INT,
    @p19 INT,
    @p20 INT,
    @p21 INT,
    @p22 INT,
    @p23 INT,
    @p24 INT,
    @p25 INT,
    @p26 INT,
    @p27 INT,
    @p28 INT,
    @p29 INT,
    @p30 INT,
    @p31 INT,
    @p32 INT,
    @p33 INT,
    @p34 INT,
    @p35 INT,
    @p36 INT,
    @p37 INT,
    @p38 INT,
    @p39 INT,
    @p40 INT,
    @p41 INT,
    @p42 INT,
    @p43 INT,
    @p44 INT,
    @p45 INT,
    @p46 INT,
    @p47 INT,
    @p48 INT,
    @p49 INT,
    @p50 INT,
    @p51 INT,
    @p52 INT,
    @p53 INT,
    @p54 INT,
    @p55 INT,
    @p56 INT,
    @p57 INT,
    @p58 INT,
    @p59 INT,
    @p60 INT,
    @p61 INT,
    @p62 INT,
    @p63 INT,
    @p64 INT,
    @p65 INT,
    @p66 INT,
    @p67 INT,
    @p68 INT,
    @p69 INT,
    @p70 INT,
    @p71 INT,
    @p72 INT,
    @p73 INT,
    @p74 INT,
    @p75 INT,
    @p76 INT,
    @p77 INT,
    @p78 INT,
    @p79 INT,
    @p80 INT,
    @p81 INT,
    @p82 INT,
    @p83 INT,
    @p84 INT,
    @p85 INT,
    @p86 INT,
    @p87 INT,
    @p88 INT,
    @p89 INT,
    @p90 INT,
    @p91 INT,
    @p92 INT,
    @p93 INT,
    @p94 INT,
    @p95 INT,
    @p96 INT,
    @p97 INT,
    @p98 INT,
    @p99 INT


SELECT  @p1 = 62125,
        @p2 = 62138,
        @p3 = 62137,
        @p4 = 62136,
        @p5 = 62126,
        @p6 = 62127,
        @p7 = 62128,
        @p8 = 62135,
        @p9 = 62134,
        @p10 = 62132,
        @p11 = 62129,
        @p12 = 62130,
        @p13 = 62131,
        @p14 = 62133,
        @p15 = 62170,
        @p16 = 62171,
        @p17 = 62172,
        @p18 = 62173,
        @p19 = 62174,
        @p20 = 62175,
        @p21 = 62179,
        @p22 = 62178,
        @p23 = 62176,
        @p24 = 62177,
        @p25 = 71651,
        @p26 = 71667,
        @p27 = 71666,
        @p28 = 71652,
        @p29 = 71653,
        @p30 = 71665,
        @p31 = 71664,
        @p32 = 71659,
        @p33 = 71658,
        @p34 = 71654,
        @p35 = 71657,
        @p36 = 71655,
        @p37 = 71656,
        @p38 = 71660,
        @p39 = 71663,
        @p40 = 71661,
        @p41 = 71662,
        @p42 = 71734,
        @p43 = 71755,
        @p44 = 71754,
        @p45 = 71753,
        @p46 = 71752,
        @p47 = 71735,
        @p48 = 71736,
        @p49 = 71737,
        @p50 = 71738,
        @p51 = 71739,
        @p52 = 71740,
        @p53 = 71751,
        @p54 = 71750,
        @p55 = 71749,
        @p56 = 71748,
        @p57 = 71747,
        @p58 = 71746,
        @p59 = 71745,
        @p60 = 71744,
        @p61 = 71743,
        @p62 = 71742,
        @p63 = 71741,
        @p64 = 72264,
        @p65 = 72279,
        @p66 = 72278,
        @p67 = 72277,
        @p68 = 72276,
        @p69 = 72265,
        @p70 = 72266,
        @p71 = 72267,
        @p72 = 72268,
        @p73 = 72269,
        @p74 = 72275,
        @p75 = 72274,
        @p76 = 72273,
        @p77 = 72272,
        @p78 = 72271,
        @p79 = 72270,
        @p80 = 72858,
        @p81 = 72870,
        @p82 = 72868,
        @p83 = 72859,
        @p84 = 72866,
        @p85 = 72861,
        @p86 = 72864,
        @p87 = 50308,
        @p88 = 50660,
        @p89 = 50667,
        @p90 = 50664,
        @p91 = 50668,
        @p92 = 72863,
        @p93 = 72862,
        @p94 = 72865,
        @p95 = 72860,
        @p96 = 72867,
        @p97 = 72869,
        @p98 = 72871,
        @p99 = 72872

--SET STATISTICS IO ON;
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
--SET STATISTICS IO OFF













--Database scoped configuration
ALTER DATABASE SCOPED CONFIGURATION  
 CLEAR PROCEDURE_CACHE  
















ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON;



ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;











ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = ON;





ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;














ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = OFF;


ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;




















--execution plans

SELECT  c.CustomerID,
        a.City,
        s.Name,
        st.Name
FROM    Sales.Customer AS c
JOIN    Sales.Store AS s
        ON c.StoreID = s.BusinessEntityID
JOIN    Sales.SalesTerritory AS st
        ON c.TerritoryID = st.TerritoryID
JOIN    Person.BusinessEntityAddress AS bea
        ON c.CustomerID = bea.BusinessEntityID
JOIN    Person.Address AS a
        ON bea.AddressID = a.AddressID
JOIN    Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   st.Name = 'Northeast'
        AND sp.Name = 'New York';




--exploring alternative plans
SELECT  p.Name,
        p.ProductNumber,
        ph.ListPrice
FROM    Production.Product p
INNER JOIN Production.ProductListPriceHistory ph
        ON p.ProductID = ph.ProductID
           AND ph.StartDate = (SELECT TOP (1)
                                        ph2.StartDate
                               FROM     Production.ProductListPriceHistory ph2
                               WHERE    ph2.ProductID = p.ProductID
                               ORDER BY ph2.StartDate DESC
                              );




-- run 'em once at the same time as well as separate.
SELECT  p.Name,
        p.ProductNumber,
        ph.ListPrice
FROM    Production.Product p
CROSS APPLY (SELECT TOP (1)
                    ph2.ProductID,
                    ph2.ListPrice
             FROM   Production.ProductListPriceHistory ph2
             WHERE  ph2.ProductID = p.ProductID
             ORDER BY ph2.StartDate DESC
            ) ph;


-- part 2, with a WHERE clause
SELECT  p.Name,
        p.ProductNumber,
        ph.ListPrice
FROM    Production.Product p
INNER JOIN Production.ProductListPriceHistory ph
        ON p.ProductID = ph.ProductID
           AND ph.StartDate = (SELECT TOP (1)
                                        ph2.StartDate
                               FROM     Production.ProductListPriceHistory ph2
                               WHERE    ph2.ProductID = p.ProductID
                               ORDER BY ph2.StartDate DESC
                              )
WHERE   p.ProductID = '839';


SELECT  p.Name,
        p.ProductNumber,
        ph.ListPrice
FROM    Production.Product p
CROSS APPLY (SELECT TOP (1)
                    ph2.ProductID,
                    ph2.ListPrice
             FROM   Production.ProductListPriceHistory ph2
             WHERE  ph2.ProductID = p.ProductID
             ORDER BY ph2.StartDate DESC
            ) ph
WHERE   p.ProductID = '839';


















-- Tracing the behavior of spool operators

GO
CREATE OR ALTER PROCEDURE dbo.uspGetManagerEmployees
    @BusinessEntityID int
AS
BEGIN
    SET NOCOUNT ON;
    WITH    EMP_cte(BusinessEntityID, OrganizationNode, FirstName, LastName, RecursionLevel)
              -- CTE name and columns
              AS (SELECT    e.BusinessEntityID,
                            e.OrganizationNode,
                            p.FirstName,
                            p.LastName,
                            0 -- Get the initial list of Employees
                              -- for Manager n
                  FROM      HumanResources.Employee e
                  INNER JOIN Person.Person p
                            ON p.BusinessEntityID = e.BusinessEntityID
                  WHERE     e.BusinessEntityID = @BusinessEntityID
                  UNION ALL
                  SELECT    e.BusinessEntityID,
                            e.OrganizationNode,
                            p.FirstName,
                            p.LastName,
                            EMP_cte.RecursionLevel + 1 -- Join recursive
                                                 -- member to anchor
                  FROM      HumanResources.Employee e
                  INNER JOIN EMP_cte
                            ON e.OrganizationNode.GetAncestor(1) = EMP_cte.OrganizationNode
                  INNER JOIN Person.Person p
                            ON p.BusinessEntityID = e.BusinessEntityID
                 )
        SELECT  EMP_cte.RecursionLevel,
                EMP_cte.OrganizationNode.ToString() AS OrganizationNode,
                p.FirstName AS 'ManagerFirstName',
                p.LastName AS 'ManagerLastName',
                EMP_cte.BusinessEntityID,
                EMP_cte.FirstName,
                EMP_cte.LastName -- Outer select from the CTE
        FROM    EMP_cte
        INNER JOIN HumanResources.Employee e
                ON EMP_cte.OrganizationNode.GetAncestor(1) = e.OrganizationNode
        INNER JOIN Person.Person p
                ON p.BusinessEntityID = e.BusinessEntityID
        ORDER BY EMP_cte.RecursionLevel,
                EMP_cte.OrganizationNode.ToString()
    OPTION  (MAXRECURSION 25); 
END;

GO

EXEC dbo.uspGetEmployeeManagers
    @BusinessEntityID = 9;





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
OPTION  (QUERYTRACEON 8649);




-- Part 2 clustered columnstore
SELECT  *
INTO    dbo.TransactionHistory
FROM    Production.TransactionHistory AS th;


CREATE CLUSTERED COLUMNSTORE INDEX ClusteredColumnStoreTest
ON dbo.TransactionHistory;



SELECT  p.Name,
        COUNT(th.ProductID) AS CountProductID,
        SUM(th.Quantity) AS SumQuantity,
        AVG(th.ActualCost) AS AvgActualCost
FROM    dbo.TransactionHistory AS th
JOIN    Production.Product AS p
        ON p.ProductID = th.ProductID
GROUP BY th.ProductID,
        p.Name
OPTION  (QUERYTRACEON 8649);




--cleanup
DROP TABLE dbo.TransactionHistory;
DROP INDEX Production.TransactionHistory.ix_csTest;














--parameter sniffing
GO
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference (
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
    @referenceorderid = 53465;


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
    @ReferenceOrderID = 41798;







-- Exploring Windows functions
SELECT soh.CustomerID,
       soh.SubTotal,
       ROW_NUMBER() OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate ASC) AS RowNum
       soh.OrderDate
FROM Sales.SalesOrderHeader AS soh
WHERE soh.OrderDate
BETWEEN '1/1/2013' AND '7/1/2013'
ORDER BY RowNum DESC, soh.OrderDate;




-- part 2
SELECT soh.CustomerID,
       soh.SubTotal,
       AVG(soh.SubTotal) OVER (PARTITION BY soh.CustomerID) AS AverageSubTotal,
	   ROW_NUMBER() OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate ASC) AS RowNum
FROM Sales.SalesOrderHeader AS soh
WHERE soh.OrderDate
BETWEEN '1/1/2013' AND '7/1/2013';








--imagination
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













--dealing with adversity
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
WHERE   l.Name = @LocationName;
GO




DROP INDEX productionlocation ON Production.ProductInventory















--using the tools to expose SQL Server functionality
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







--automation
--regressed execution plans
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE; 
EXEC dbo.AddressByCity @City = N'Mentor' 
GO
EXEC dbo.AddressByCity @City = N'Mentor' -- nvarchar(30)
GO 50
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE; 
EXEC dbo.AddressByCity @City = N'London' 
GO
EXEC dbo.AddressByCity @City = N'Mentor' -- nvarchar(30)
GO 50






SELECT * FROM sys.dm_db_tuning_recommendations AS ddtr






DROP TABLE IF EXISTS flgp;
CREATE TABLE flgp
(
    type INT,
    name NVARCHAR(200),
    INDEX ncci NONCLUSTERED COLUMNSTORE (TYPE),
    INDEX ix_type (type)
);
INSERT INTO flgp
(
    type,
    name
)
VALUES
(1, 'Single');
INSERT INTO flgp
(
    type,
    name
)
SELECT TOP 9999999
    2 AS type,
    o.name
FROM sys.objects,
     sys.all_columns o;




--ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE; 
EXECUTE sys.sp_executesql @stmt = N'SELECT COUNT(*) FROM flgp WHERE type = @type',
                          @params = N'@type int',
                          @type = 2
GO 30



ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXECUTE sys.sp_executesql @stmt = N'SELECT COUNT(*) FROM flgp WHERE type = @type',
                          @params = N'@type int',
                          @type = 1





SELECT reason,
       score,
       script = JSON_VALUE(details, '$.implementationDetails.script'),
       planForceDetails.*,
       estimated_gain = (planForceDetails.regressedPlanExecutionCount + planForceDetails.recommendedPlanExecutionCount)
                        * (planForceDetails.regressedPlanCpuTimeAverage
                           - planForceDetails.recommendedPlanCpuTimeAverage
                          ) / 1000000,
       error_prone = IIF(planForceDetails.regressedPlanErrorCount > planForceDetails.recommendedPlanErrorCount,
                         'YES',
                         'NO')
FROM sys.dm_db_tuning_recommendations
    CROSS APPLY
    OPENJSON(details, '$.planForceDetails')
    WITH
    (
        query_id INT '$.queryId',
        [current plan_id] INT '$.regressedPlanId',
        [recommended plan_id] INT '$.recommendedPlanId',
        regressedPlanErrorCount INT,
        recommendedPlanErrorCount INT,
        regressedPlanExecutionCount INT,
        regressedPlanCpuTimeAverage FLOAT,
        recommendedPlanExecutionCount INT,
        recommendedPlanCpuTimeAverage FLOAT
    ) AS planForceDetails;



ALTER DATABASE AdventureWorks2014 
SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);


SELECT *
FROM sys.database_automatic_tuning_mode AS datm




SELECT *
FROM sys.database_automatic_tuning_options AS dato



ALTER DATABASE AdventureWorks2014
SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = OFF);






--adaptive query tuning
CREATE OR ALTER FUNCTION dbo.SalesInfo ( )
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

CREATE OR ALTER FUNCTION dbo.SalesDetails ( )
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


CREATE OR ALTER FUNCTION dbo.CombinedSalesInfo ( )
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