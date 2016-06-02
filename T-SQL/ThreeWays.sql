--DMO
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








--XML

-- combining with query stats
SELECT  deqs.execution_count,
        deqs.total_worker_time,
        deqs.total_elapsed_time,
        deqs.total_logical_reads,
        deqs.total_logical_writes,
        deqs.query_plan_hash,
        deqp.query_plan
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
WHERE   deqp.dbid = 7 ;







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
WHERE   p.query_plan.exist(N'/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan//sp:MissingIndexes') = 1 ;







SELECT * FROM HumanResources.vEmployee AS ve



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
WHERE   qp.text = 'SELECT * FROM HumanResources.vEmployee AS ve'
ORDER BY EstimatedCost DESC













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
        AND qp.optimizationlevel = 'Full' 
ORDER BY qp.execution_count DESC ;








--Trace
--Trace

/****************************************************/
/* Created by: SQL Server 2012  Profiler          */
/* Date: 08/15/2012  08:08:52 AM         */
/****************************************************/


-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
declare @DateTime datetime

set @DateTime = DATEADD(HOUR,24,GETDATE())
set @maxfilesize = 50

-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 0, N'C:\PerformanceTuning\PerformanceTrace.trc', @maxfilesize, @Datetime
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 6, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 17, @on
exec sp_trace_setevent @TraceID, 10, 18, @on
exec sp_trace_setevent @TraceID, 10, 35, @on
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 3, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 6, @on
exec sp_trace_setevent @TraceID, 12, 10, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 13, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 18, @on
exec sp_trace_setevent @TraceID, 12, 35, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go









-- turning trace off
EXEC sys.sp_trace_setstatus 1,0
EXEC sys.sp_trace_setstatus 1,2







--reading from trace
SELECT * FROM ::fn_trace_gettable('C:\PerformanceTuning\PerformanceTrace.trc',DEFAULT) AS ftg









--Extended Events
CREATE EVENT SESSION [Performance] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.query_hash)),
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    ACTION(sqlserver.query_hash)) 
ADD TARGET package0.event_file(SET filename=N'C:\PerformanceTuning\Performance.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO







--start and stop extended events
ALTER EVENT SESSION Performance
ON SERVER
STATE = STOP;




ALTER EVENT SESSION Performance
ON SERVER
STATE = START;



SELECT	*
FROM	sys.dm_xe_sessions AS dxs;





DROP EVENT SESSION Performance
ON SERVER;



SELECT * FROM Person.Address AS a


--Reading from ex events
SELECT	*
FROM	sys.fn_xe_file_target_read_file('C:\PerformanceTuning\*.xel', NULL,
										NULL, NULL);
 








WITH    xEvents
          AS (SELECT    object_name AS xEventName,
                        CAST (event_data AS XML) AS xEventData
              FROM      sys.fn_xe_file_target_read_file('C:\PerformanceTuning\*.xel',
                                                        NULL, NULL, NULL)
             )
    SELECT  xEventName,
            xEventData.value('(/event/data[@name=''duration'']/value)[1]',
                             'bigint') Duration,
            xEventData.value('(/event/data[@name=''physical_reads'']/value)[1]',
                             'bigint') PhysicalReads,
            xEventData.value('(/event/data[@name=''logical_reads'']/value)[1]',
                             'bigint') LogicalReads,
            xEventData.value('(/event/data[@name=''cpu_time'']/value)[1]',
                             'bigint') CpuTime,
            xEventData.value('(/event/data[@name=''batch_text'']/value)[1]',
                             'varchar(max)') BatchText,
            xEventData.value('(/event/data[@name=''statement'']/value)[1]',
                             'varchar(max)') StatementText,
            xEventData.value('(/event/data[@name=''query_plan_hash'']/value)[1]',
                             'binary(8)') QueryPlanHash
    FROM    xEvents
    ORDER BY LogicalReads DESC ;




USE TestDB ;
GO
WITH    xEvents
          AS (SELECT    object_name AS xEventName,
                        CAST (event_data AS XML) AS xEventData
              FROM      sys.fn_xe_file_target_read_file('C:\Program Files\Microsoft SQL Server\MSSQL11.RANDORI\MSSQL\Log\Query Performance Tuning*.xel',
                                                        NULL, NULL, NULL)
             )
    SELECT  xEventName,
            xEventData.value('(/event/data[@name=''duration'']/value)[1]',
                             'bigint') Duration,
            xEventData.value('(/event/data[@name=''physical_reads'']/value)[1]',
                             'bigint') PhysicalReads,
            xEventData.value('(/event/data[@name=''logical_reads'']/value)[1]',
                             'bigint') LogicalReads,
            xEventData.value('(/event/data[@name=''cpu_time'']/value)[1]',
                             'bigint') CpuTime,
            CASE xEventName
              WHEN 'sql_batch_completed'
              THEN xEventData.value('(/event/data[@name=''batch_text'']/value)[1]',
                                    'varchar(max)')
              WHEN 'rpc_completed'
              THEN xEventData.value('(/event/data[@name=''statement'']/value)[1]',
                                    'varchar(max)')
            END AS SQLText,
            xEventData.value('(/event/data[@name=''query_plan_hash'']/value)[1]',
                             'binary(8)') QueryPlanHash
INTO Session_Table
    FROM    xEvents ;




USE TestDB ;
GO
SELECT  COUNT(*) AS TotalExecutions,
        st.xEventName,
        st.BatchText,
        SUM(st.Duration) AS DurationTotal,
        SUM(st.CpuTime) AS CpuTotal,
        SUM(st.LogicalReads) AS LogicalReadTotal,
        SUM(st.PhysicalReads) AS PhysicalReadTotal
FROM    Session_Table AS st
GROUP BY st.xEventName,
        st.BatchText
ORDER BY LogicalReadTotal DESC ;





SELECT  ss.sum_execution_count,
        t.TEXT,
        ss.sum_total_elapsed_time,
        ss.sum_total_worker_time,
        ss.sum_total_logical_reads,
        ss.sum_total_logical_writes
FROM    (SELECT s.plan_handle,
                SUM(s.execution_count) sum_execution_count,
                SUM(s.total_elapsed_time) sum_total_elapsed_time,
                SUM(s.total_worker_time) sum_total_worker_time,
                SUM(s.total_logical_reads) sum_total_logical_reads,
                SUM(s.total_logical_writes) sum_total_logical_writes
         FROM   sys.dm_exec_query_stats s
         GROUP BY s.plan_handle
        ) AS ss
CROSS APPLY sys.dm_exec_sql_text(ss.plan_handle) t
ORDER BY sum_total_logical_reads DESC



WITH    xEvents
          AS (SELECT    object_name AS xEventName,
                        CAST (event_data AS XML) AS xEventData
              FROM      sys.fn_xe_file_target_read_file('C:\Program Files\Microsoft SQL Server\MSSQL11.RANDORI\MSSQL\Log\Query Performance Tuning*.xel',
                                                        NULL, NULL, NULL)
             )
    SELECT  xEventName,
            xEventData.value('(/event/data[@name=''duration'']/value)[1]',
                             'bigint') Duration,
            xEventData.value('(/event/data[@name=''physical_reads'']/value)[1]',
                             'bigint') PhysicalReads,
            xEventData.value('(/event/data[@name=''logical_reads'']/value)[1]',
                             'bigint') LogicalReads,
            xEventData.value('(/event/data[@name=''cpu_time'']/value)[1]',
                             'bigint') CpuTime,
            xEventData.value('(/event/data[@name=''batch_text'']/value)[1]',
                             'varchar(max)') BatchText,
            xEventData.value('(/event/data[@name=''query_plan_hash'']/value)[1]',
                             'binary(8)') QueryPlanHash
    FROM    xEvents
    ORDER BY Duration DESC ;