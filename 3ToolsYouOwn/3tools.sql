--DMVs

--Active Queries
SELECT dest.text,
       deqp.query_plan,
       der.cpu_time,
       der.logical_reads,
       der.writes
FROM sys.dm_exec_requests AS der
    CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest;


--Past Queries
SELECT dest.text,
       deqp.query_plan,
       deqs.min_logical_reads,
       deqs.max_logical_reads,
       deqs.total_logical_reads,
       deqs.total_elapsed_time,
       deqs.last_elapsed_time
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest;




--Extended Events
CREATE EVENT SESSION [QueryPerformance]
ON SERVER
    ADD EVENT sqlserver.rpc_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks'));





--Query Store
ALTER DATABASE AdventureWorks SET QUERY_STORE = ON;



SELECT qsq.query_id,
       qsqt.query_text_id,
       qsqt.query_sql_text
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;


ALTER DATABASE AdventureWorks SET QUERY_STORE CLEAR;


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



EXEC dbo.AddressByCity @City = N'London' -- nvarchar(30)


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




