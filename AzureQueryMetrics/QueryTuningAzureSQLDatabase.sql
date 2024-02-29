--Existing tools

--run for results
SET STATISTICS TIME ON 
SET STATISTICS IO ON
SELECT  *
FROM    Person.Address AS a
WHERE   a.City = 'Peoria';

--add client statistics
--generate execution plan

--expand ssms
--show mising Management Folder


--remember PowerShell!!!












--Gathering Metrics
--DBCC

DBCC SHOW_STATISTICS('Person.Address', PK_Address_AddressID);




DBCC SQLPERF(LOGSPACE);



DBCC SQLPERF ("sys.dm_os_wait_stats", CLEAR);










--DMV and System views
--common DMVs
SELECT	*
FROM	sys.dm_exec_requests AS der;








SELECT	SUBSTRING(dest.text, ( der.statement_start_offset / 2 ) + 1,
				  ( ( CASE WHEN der.statement_end_offset = -1
						   THEN DATALENGTH(dest.text)
						   ELSE der.statement_end_offset
					  END ) - der.statement_start_offset ) / 2 + 1) AS StatementText ,
		deqp.query_plan ,
		der.start_time ,
		der.database_id ,
		der.blocking_session_id ,
		der.wait_type ,
		der.wait_time ,
		der.last_wait_type ,
		der.cpu_time ,
		der.total_elapsed_time ,
		der.reads ,
		der.writes ,
		der.logical_reads
FROM	sys.dm_exec_requests AS der
		CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp
		CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest;







SELECT  dest.text,
        deqp.query_plan,
        deqs.creation_time,
        deqs.last_execution_time,
        deqs.execution_count
FROM    sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
WHERE   dest.text = 'SELECT  *
FROM    Person.Address AS a
WHERE   a.City = ''Peoria'';';






--can we do this with a premier

DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text = 'SELECT  *
FROM    Person.Address AS a
WHERE   a.City = ''Peoria'';'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO









SELECT  *
FROM    sys.dm_os_wait_stats AS dows
ORDER BY dows.max_wait_time_ms DESC;






--unique DMVs
SELECT  *
FROM    sys.dm_db_wait_stats AS ddws
ORDER BY ddws.max_wait_time_ms DESC;












--QUERY STORE



ALTER DATABASE AdventureWorks SET QUERY_STORE = ON;



ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
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



EXEC dbo.spAddressByCity 
	@City = N'London'
	WITH RECOMPILE;

EXEC dbo.spAddressByCity
    @City = N'Mentor'
	WITH RECOMPILE;

EXEC dbo.spAddressByCity
    @City = N'Newton';

EXEC dbo.spAddressByCity 'London'
WITH RECOMPILE;




SELECT  *
FROM    sys.query_store_runtime_stats AS qsrs

SELECT  *
FROM    sys.query_store_runtime_stats_interval AS qsrsi

SELECT  *
FROM    sys.query_store_plan AS qsp;

SELECT  *
FROM    sys.query_store_query AS qsq;

SELECT  *
FROM    sys.query_store_query_text AS qsqt;






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
WHERE   qsq.object_id > 0;





SELECT * FROM sys.database_query_store_options




CREATE PROC dbo.spAddressByCity @City NVARCHAR(30)
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



EXEC dbo.spAddressByCity 
	@City = N'London';

EXEC dbo.spAddressByCity
    @City = N'Mentor'
	WITH RECOMPILE;

EXEC dbo.spAddressByCity
    @City = N'Newton';

EXEC dbo.spAddressByCity 'London'
WITH RECOMPILE;

EXEC dbo.spAddressByCity 'London' WITH RECOMPILE;



DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROC dbo.spAddressByCity%'

SELECT @PlanHandle

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO




SELECT  p.name,
        qsq.object_id,
		qsrs.count_executions,
		qsp.*,
		qsrs.*
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
		JOIN sys.procedures AS p
		ON p.object_id = qsq.object_id
		JOIN sys.query_store_plan AS qsp
		ON qsp.query_id = qsq.query_id
		JOIN sys.query_store_runtime_stats AS qsrs
		ON qsrs.plan_id = qsp.plan_id
WHERE   qsq.object_id > 0;




SELECT  qsq.query_id,
        qsp.plan_id
FROM    sys.query_store_query AS qsq
JOIN    sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE   qsq.object_id = OBJECT_ID('dbo.spAddressByCity')


EXEC sys.sp_query_store_force_plan
    @query_id = 313,
    @pland_id = 42;

--add way to clear forced plan


SELECT * FROM sys.query_store_runtime_stats 



--Extended Events
IF NOT EXISTS
    (SELECT * FROM sys.symmetric_keys
        WHERE symmetric_key_id = 101)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '0C34C960-6621-4682-A123-C7EA08E3FC46';
END
GO






IF EXISTS
    (SELECT * FROM sys.database_scoped_credentials
        WHERE name = 'https://sqlcruising.blob.core.windows.net/xevents')
BEGIN
    DROP DATABASE SCOPED CREDENTIAL
        [https://sqlcruising.blob.core.windows.net/xevents];
END
GO

CREATE DATABASE SCOPED 
CREDENTIAL [https://exeventsoutput.blob.core.windows.net/xevents] 
WITH IDENTITY='Shared Access Signature', 
SECRET='sv=2014-02-14&sr=c&si=xeventspolicy&sig=viWlkmXgQHjgGYIMDYaLvAwiyhZWCvVW81ReLMl4%2FjQ%3D';





CREATE EVENT SESSION QueryPerformanceMetrics ON DATABASE 
ADD EVENT sqlserver.rpc_completed,
ADD EVENT sqlserver.sql_batch_completed
ADD TARGET package0.event_file
( SET FILENAME =  'https://exeventsoutput.blob.core.windows.net/xevents/queryperformancemetrics.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=2 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION QueryPerformanceMetrics ON DATABASE 
STATE = START; 


--DROP EVENT SESSION QueryPerf ON DATABASE




SELECT  *
FROM    sys.fn_xe_file_target_read_file('https://exeventsoutput.blob.core.windows.net/xevents/queryperf*.xel',
                                        NULL, NULL, NULL);



