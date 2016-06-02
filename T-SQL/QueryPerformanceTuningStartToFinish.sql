--Part 1: Gathering metrics
--Memory queries
SELECT  *
FROM    sys.dm_os_performance_counters AS dopc
WHERE dopc.counter_name = 'Page Life Expectancy'
--AND dopc.object_name = 'MSSQL$RANDORI:Buffer Manager';








--Ring buffers
WITH	RingBuffer
		  AS (SELECT	CAST(dorb.record AS XML) AS xRecord,
						dorb.timestamp
			  FROM		sys.dm_os_ring_buffers AS dorb
			  WHERE		dorb.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
			 )
	SELECT	xr.value('(ResourceMonitor/Notification)[1]', 'varchar(75)') AS RmNotification,
			xr.value('(ResourceMonitor/IndicatorsProcess)[1]', 'tinyint') AS IndicatorsProcess,
			xr.value('(ResourceMonitor/IndicatorsSystem)[1]', 'tinyint') AS IndicatorsSystem,
			DATEADD(ss,
					(-1 * ((dosi.cpu_ticks / CONVERT (FLOAT, (dosi.cpu_ticks
															  / dosi.ms_ticks)))
						   - rb.timestamp) / 1000), GETDATE()) AS RmDateTime,
			xr.value('(MemoryNode/TargetMemory)[1]', 'bigint') AS TargetMemory,
			xr.value('(MemoryNode/ReserveMemory)[1]', 'bigint') AS ReserveMemory,
			xr.value('(MemoryNode/CommittedMemory)[1]', 'bigint') AS CommitedMemory,
			xr.value('(MemoryNode/SharedMemory)[1]', 'bigint') AS SharedMemory,
			xr.value('(MemoryNode/PagesMemory)[1]', 'bigint') AS PagesMemory,
			xr.value('(MemoryRecord/MemoryUtilization)[1]', 'bigint') AS MemoryUtilization,
			xr.value('(MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') AS TotalPhysicalMemory,
			xr.value('(MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS AvailablePhysicalMemory,
			xr.value('(MemoryRecord/TotalPageFile)[1]', 'bigint') AS TotalPageFile,
			xr.value('(MemoryRecord/AvailablePageFile)[1]', 'bigint') AS AvailablePageFile,
			xr.value('(MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') AS TotalVirtualAddressSpace,
			xr.value('(MemoryRecord/AvailableVirtualAddressSpace)[1]',
					 'bigint') AS AvailableVirtualAddressSpace,
			xr.value('(MemoryRecord/AvailableExtendedVirtualAddressSpace)[1]',
					 'bigint') AS AvailableExtendedVirtualAddressSpace
	FROM	RingBuffer AS rb
			CROSS APPLY rb.xRecord.nodes('Record') record (xr)
			CROSS JOIN sys.dm_os_sys_info AS dosi
	ORDER BY RmDateTime DESC;










--brokers
SELECT * FROM sys.dm_os_memory_brokers AS domb;











--DBCC MEMORYSTATUS
DECLARE	@MemStat TABLE (
	ValueName SYSNAME,
	Val BIGINT);

INSERT	INTO @MemStat
		EXEC ('DBCC memorystatus() WITH tableresults'
			);

WITH	Measures
		  AS (SELECT TOP 2
						CurrentValue,
						ROW_NUMBER() OVER (ORDER BY OrderColumn) AS RowOrder
			  FROM		(SELECT	CASE WHEN (ms.ValueName = 'Target Committed')
									 THEN ms.Val
									 WHEN (ms.ValueName = 'Current Committed')
									 THEN ms.Val
								END AS 'CurrentValue',
								0 AS 'OrderColumn'
						 FROM	@MemStat AS ms
						) AS MemStatus
			  WHERE		CurrentValue IS NOT NULL
			 )
	SELECT	TargetMem.CurrentValue - CurrentMem.CurrentValue
	FROM	Measures AS TargetMem
			JOIN Measures AS CurrentMem
			ON TargetMem.RowOrder + 1 = CurrentMem.RowOrder;










--clerks

SELECT * FROM sys.dm_os_memory_clerks AS domc;










--Disk queries


SELECT *
FROM sys.dm_io_virtual_file_stats(DB_ID('AdventureWorks2012'),2) AS divfs;










SELECT *
FROM sys.dm_os_wait_stats AS dows
--ORDER BY dows.wait_time_ms DESC;

WHERE dows.wait_type LIKE 'PAGEIOLATCH%';

















--memory


SELECT * FROM sys.dm_os_workers AS dow;





SELECT * FROM sys.dm_os_schedulers AS dos;










SELECT  *
FROM    Sys.dm_exec_requests AS der
WHERE   session_id > 50 ;















SELECT  *
FROM    Sys.dm_os_waiting_tasks AS dowt ;

















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






























--Part 2: Optimizer

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









--sys.dm_exec_query_profiles



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


















--dbcc showstatistics
DBCC SHOW_STATISTICS ("Production.TransactionHistoryArchive",IX_TransactionHistoryArchive_ProductID) ;








DBCC SHOW_STATISTICS ("Production.TransactionHistoryArchive",IX_TransactionHistoryArchive_ProductID)
WITH HISTOGRAM ;






DBCC SHOW_STATISTICS ("Production.TransactionHistoryArchive",IX_TransactionHistoryArchive_ProductID)
WITH STAT_HEADER ;















--Indexes
SELECT  *
FROM    sys.dm_db_index_physical_stats(DB_ID('AdventureWorks2012'), NULL,
                                       NULL, NULL, 'Limited') AS ddips









SELECT  *
FROM    sys.dm_db_index_physical_stats(DB_ID('AdventureWorks2012'),
                                       OBJECT_ID('Sales.SalesOrderDetail'), 1,
                                       NULL, 'Sampled') AS ddips










--Constraints

SELECT  p.LastName + ', ' + p.FirstName AS 'PersonName'
FROM    Person.Address AS a
        JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN Person.BusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
        JOIN Person.Person AS p
        ON be.BusinessEntityID = p.BusinessEntityID ; 

--create some dummy tables
SELECT  *
INTO    dbo.MyAddress
FROM    Person.Address ;

SELECT  *
INTO    dbo.MyBusinessEntityAddress
FROM    Person.BusinessEntityAddress ;

SELECT  *
INTO    dbo.MyBusinessEntity
FROM    Person.BusinessEntity ;

SELECT  *
INTO    dbo.MyPerson
FROM    Person.Person ;

DROP TABLE dbo.myaddress
DROP TABLE dbo.mybusinessentityaddress
DROP TABLE dbo.mybusinessentity
DROP TABLE dbo.myperson


---new query
SELECT  p.LastName + ', ' + p.FirstName AS 'PersonName'
FROM    dbo.MyAddress AS a
        JOIN dbo.MyBusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN dbo.MyBusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
        JOIN dbo.MyPerson AS p
        ON be.BusinessEntityID = p.BusinessEntityID








--add clustered indexes

ALTER TABLE dbo.MyAddress ADD CONSTRAINT PK_MyAddress_AddressID PRIMARY KEY CLUSTERED
(
AddressID ASC
)

CREATE NONCLUSTERED INDEX IX_MyBusinessEntityAddress_AddressID ON dbo.MyBusinessEntityAddress
(
AddressID ASC
)

ALTER TABLE dbo.MyBusinessEntityAddress ADD CONSTRAINT PK_MyBusinessEntityAddress_BusinessEntityID_AddressID_AddressTypeID PRIMARY KEY CLUSTERED
(
BusinessEntityID ASC,
AddressID ASC,
AddressTypeID ASC
)

ALTER TABLE dbo.MyBusinessEntity ADD CONSTRAINT PK_MyBusinessEntity_BusinessEntityID PRIMARY KEY CLUSTERED
(
BusinessEntityID ASC
)
GO

ALTER TABLE dbo.MyPerson ADD CONSTRAINT PK_Person_BusinessEntityID PRIMARY KEY CLUSTERED
(
BusinessEntityID ASC
)







SELECT  p.LastName + ', ' + p.FirstName AS 'PersonName'
FROM    Person.Address AS a
        JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN Person.BusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
        JOIN Person.Person AS p
        ON be.BusinessEntityID = p.BusinessEntityID
WHERE   p.LastName LIKE 'Ran%'

SELECT  p.LastName + ', ' + p.FirstName AS 'PersonName'
FROM    dbo.MyAddress AS a
        JOIN dbo.MyBusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN dbo.MyBusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
        JOIN dbo.MyPerson AS p
        ON be.BusinessEntityID = p.BusinessEntityID
WHERE   p.LastName LIKE 'Ran%'












--Part 3: Execution Plans

--Simple Select
SELECT  *
FROM    [dbo].[DatabaseLog] ;
GO












--Join
SELECT  e.JobTitle,
        a.City,
        p.LastName + ',' + p.FirstName AS EmployeeName
FROM    HumanResources.Employee e
        JOIN Person.BusinessEntityAddress bea
        ON e.BusinessEntityId = bea.BusinessEntityId
        JOIN Person.Address a
        ON bea.AddressID = a.AddressID
        JOIN Person.Person p
        ON e.BusinessEntityId = p.BusinessEntityId ;












--Update
BEGIN TRAN ;
UPDATE  [Person].[Address]
SET     [City] = 'Munro',
        [ModifiedDate] = GETDATE()
WHERE   [City] = 'Monroe' ;
ROLLBACK TRAN ;


















--Delete
BEGIN TRAN ;
DELETE  FROM [Person].[PersonPhone]
WHERE   [BusinessEntityId] = 5695 ;
ROLLBACK TRAN ;


BEGIN TRAN 
DELETE FROM Production.Product
WHERE ProductID = 42;
ROLLBACK TRAN



















--Insert
BEGIN TRAN ;
INSERT  INTO [Person].[Address]
        ([AddressLine1],
         [AddressLine2],
         [City],
         [StateProvinceID],
         [PostalCode],
         [rowguid],
         [ModifiedDate]
        )
VALUES  ('1313 Mockingbird Lane',
         'Basement',
         'Springfield',
         24,
         '02134',
         NEWID(),
         GETDATE()
        ) ;
ROLLBACK TRAN ;

























--Sub-select
SELECT  [p].[Name],
        [p].[ProductNumber],
        [ph].[ListPrice]
FROM    [Production].[Product] p
        INNER JOIN [Production].[ProductListPriceHistory] ph
        ON [p].[ProductID] = ph.[ProductID]
           AND ph.[StartDate] = (SELECT TOP (1)
                                        [ph2].[StartDate]
                                 FROM   [Production].[ProductListPriceHistory] ph2
                                 WHERE  [ph2].[ProductID] = [p].[ProductID]
                                 ORDER BY [ph2].[StartDate] DESC
                                )
WHERE   p.ProductID = 839 ;


















--Views
SELECT  *
FROM    [Sales].[vIndividualCustomer]
WHERE   [BusinessEntityID] = 3456 ;










--XML Plans
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
WHERE   --(qp.dbid = 13 OR qp.dbid IS NULL) 
        --AND 
		qp.optimizationlevel = 'Timeout' 
ORDER BY qp.execution_count DESC ;












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
WHERE   qp.TerminationReason = 'Timeout'
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






--statistics in execution plans
SELECT p.BusinessEntityID,
p.FirstName
FROM Person.Person AS p
WHERE p.FirstName LIKE 'Toni%';





sp_helpstats N'Person.Person', 'ALL';






--Part 4




--Fixing a query
DROP INDEX [Sales].[SalesOrderDetail].[IX_SalesOrderDetail_ProductID];



SELECT  [sod].[ProductID],
        [sod].[OrderQty],
        [sod].[UnitPrice]
FROM    [Sales].[SalesOrderDetail] sod
WHERE   [sod].[ProductID] = 897;













CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail] ([ProductID] ASC)
ON  [PRIMARY] ;

SELECT  [sod].[ProductID],
        [sod].[OrderQty],
        [sod].[UnitPrice]
FROM    [Sales].[SalesOrderDetail] sod
WHERE   [sod].[ProductID] = 897













--Fixing the bookmark lookup
CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail] ([ProductID] ASC)
INCLUDE ([OrderQty], [UnitPrice])
WITH DROP_EXISTING
ON  [PRIMARY] ;


SELECT  [sod].[ProductID],
        [sod].[OrderQty],
        [sod].[UnitPrice]--,SpecialOfferID
FROM    [Sales].[SalesOrderDetail] sod
WHERE   [sod].[ProductID] = 897;





















--Part 5: Common Problems
-- 1. Query is just running too slow
SELECT  p.[Name],
        p.ProductNumber,
        plph.ListPrice
FROM    Production.Product AS p
        JOIN Production.ProductListPriceHistory AS plph
        ON p.ProductID = plph.ProductID
           AND plph.StartDate = (SELECT TOP (1)
                                        plph2.StartDate
                                 FROM   Production.ProductListPriceHistory plph2
                                 WHERE  plph2.ProductID = p.ProductID
                                 ORDER BY plph2.StartDate DESC
                                )
WHERE   p.ProductID = 839 ;







-- Better query
SELECT  p.[Name],
        p.ProductNumber,
        plph.ListPrice
FROM    Production.Product AS p
        CROSS APPLY (SELECT TOP (1)
                            plph2.ProductId,
                            plph2.ListPrice
                     FROM   Production.ProductListPriceHistory AS plph2
                     WHERE  plph2.ProductID = p.ProductID
                     ORDER BY plph2.StartDate DESC
                    ) AS plph
WHERE   p.ProductID = 839 ;








-- 2. Key Lookup
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







-- 3. Parameter Sniffing
--a procedure that could lead to sniffing
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
    DBCC freeproccache(0x05000E00825C6D53D006CCDB0200000001000000000000000000000000000000000000000000000000000000) ;





--running in the reverse order leads to a different plan for both
    EXEC dbo.spAddressByCity @City = N'Mentor' ;



    EXEC dbo.spAddressByCity @City = N'London' ;
	

	
	
	

--one way  to get a more generic plan	
    ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
    AS 
	--I am not an idiot. This is for parameter sniffing.
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
				--option ((optimize for unknown));


                EXEC dbo.spAddressByCity @City = N'London' ;





--4. effective index use
                SELECT  *
                FROM    Sales.SalesOrderDetail AS sod
                WHERE   sod.SalesOrderID IN (51825, 51826, 51827, 51828) ;










                SELECT  *
                FROM    Sales.SalesOrderDetail AS sod
                WHERE   sod.SalesOrderID BETWEEN 51825 AND 51828 ;










-- force the index where the query won't choose the right one
                SELECT  *
                FROM    Purchasing.PurchaseOrderHeader AS poh
                WHERE   poh.PurchaseOrderID * 2 = 3400 ;

                SELECT  *
                FROM    Purchasing.PurchaseOrderHeader AS poh
                WHERE   poh.PurchaseOrderID = 3400 / 2 ;

                SELECT  *
                FROM    Purchasing.PurchaseOrderHeader AS poh WITH (INDEX (PK_PurchaseOrderHeader_PurchaseOrderID))
                WHERE   poh.PurchaseOrderID * 2 = 3400 ;










-- 5. UDF's


                DROP FUNCTION dbo.ProductList
GO

CREATE FUNCTION dbo.ProductList (@ProductCategory INT)
RETURNS @ProductList TABLE (
     ProductId INT,
     [Name] NVARCHAR(50),
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
                                pc.[Name],
                                ps.[Name]
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




-- remember to run these seperately
SELECT  *
FROM    Sales.SalesOrderDetail AS sod
        JOIN dbo.ProductList (3) AS pl
        ON sod.ProductID = pl.ProductId
WHERE   sod.SalesOrderID = 43676

SELECT * FROM dbo.productlist(3)


SELECT * FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
WHERE dest.text LIKE '%CREATE FUNCTION dbo.ProductList%'


SELECT  sod.*,
        p.productId,
        p.[Name],
        p.Color,
        pc.[Name] AS CategoryName,
        ps.[Name] AS SubCategoryName
FROM    Sales.SalesOrderDetail AS SOD
        JOIN Production.Product AS p
        ON SOD.ProductID = p.ProductID
        JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE   pc.ProductCategoryID = 3
        AND SOD.SalesOrderID = 43676









--6. Triggers
--pre-run
CREATE TRIGGER Person.uPerson ON Person.Person
    AFTER UPDATE
AS
    BEGIN
        SET NOCOUNT ON ;
	
        UPDATE  Person.Person
        SET     ModifiedDate = GETDATE()
        FROM    inserted i
        WHERE   i.BusinessEntityID = Person.BusinessEntityID ;
    END ;







    BEGIN TRAN
    UPDATE  Person.Person
    SET     FirstName = 'Herman'
    WHERE   FirstName = 'Howard' ;
    ROLLBACK TRAN













--7. REBAR as example of individual statements

    DECLARE @ProductId INT ;
    DECLARE @SuccessList TABLE (
         ProductId INT,
         TransactionId INT
        ) ;

    DECLARE SillyCursor CURSOR
    FOR
        SELECT  p.ProductId
        FROM    Production.Product AS p
        WHERE   p.ProductID % 6 = 0 ;

    OPEN SillyCursor ;

    FETCH NEXT FROM SillyCursor INTO @ProductId ;

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            INSERT  INTO @SuccessList
                    (ProductId,
                     TransactionId
                    )
                    SELECT  @productId,
                            th.TransactionID
                    FROM    Production.TransactionHistory AS th
                    WHERE   th.ProductID = @ProductId 
	
            IF @ProductId % 48 = 0 
                BEGIN
--                SET STATISTICS XML ON ;
                    SELECT  sod.SalesOrderDetailID,
                            sod.ProductId
                    FROM    Sales.SalesOrderDetail AS sod
                    WHERE   sod.ProductID = @ProductId
  --              SET STATISTICS XML OFF ;

                END
	
            FETCH NEXT FROM SillyCursor INTO @ProductId ;

        END


    CLOSE SillyCursor ;
    DEALLOCATE SillyCursor ;












--8. Extended Events
--generate a little workload, after setting up Extended events
    EXEC dbo.spr_ShoppingCart '20621' ;
GO
EXEC dbo.spr_ProductBySalesOrder 43867 ;
GO
EXEC dbo.spr_PersonByFirstName 'Gretchen' ;
GO
EXEC dbo.spr_ProductTransactionsSinceDate @LatestDate = '9/1/2004',
    @ProductName = 'Hex Nut%' ;
GO
EXEC dbo.spr_PurchaseOrderBySalesPersonName @LastName = 'Hill%' ;
GO









--eliminate the lookup
CREATE NONCLUSTERED INDEX [ix_PurchaseOrderHeader_EmployeeId] ON
Purchasing.PurchaseOrderHeader 
(employeeid ASC) 
INCLUDE (orderdate)
WITH (
DROP_EXISTING = ON)
ON  [PRIMARY] ;




--avoid the cluster index scan
CREATE INDEX IX_Test ON 
Purchasing.PurchaseOrderDetail 
(PurchaseOrderId, ProductId, LineTotal) ;













-- 9. DMV's

--Pre-run
DECLARE @n INT
SELECT  @n = COUNT(*)
FROM    sales.SalesOrderDetail AS sod
WHERE   sod.OrderQty = 1
IF @n > 0 
    PRINT 'Record Exists'
    
    
    


--sys.dm_exec_cached_plans

SELECT  *
FROM    sys.dm_exec_cached_plans AS decp



--add in sys.dm_exec_query_plan
SELECT  *
FROM    sys.dm_exec_cached_plans AS decp
        CROSS APPLY sys.dm_exec_query_plan(decp.plan_handle) AS deqp


--large plans
SELECT  *
FROM    sys.dm_exec_cached_plans AS decp
        CROSS APPLY sys.dm_exec_text_query_plan(decp.plan_handle, 0, -1) AS detqp



--Let's find the slow query
SELECT  deqp.query_plan,
        dest.[text]
FROM    sys.dm_exec_cached_plans AS decp
        CROSS APPLY sys.dm_exec_query_plan(decp.plan_handle) AS deqp
        CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest
WHERE   dest.[text] LIKE 'declare @n INT%'



--Let's see some performance metrics
SELECT  *
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE   dest.[text] LIKE 'declare @n INT%'




--plan attributes
SELECT  depa.*
FROM    sys.dm_exec_cached_plans AS decp
        CROSS APPLY sys.dm_exec_query_plan(decp.plan_handle) AS deqp
        CROSS APPLY sys.dm_exec_plan_attributes(decp.plan_handle) AS depa




--fix for the query
IF EXISTS ( SELECT  sod.*
            FROM    Sales.SalesOrderDetail AS sod
            WHERE   sod.OrderQty = 1 ) 
    PRINT 'Record Exists'














--10. Hash


DBCC FREEPROCCACHE


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
        
0xD82929ADC1184DCF
0xD82929ADC1184DCF
    
    
SELECT  deqs.execution_count,
        deqs.query_hash,
        deqs.query_plan_hash,
        dest.[text]
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS dest
WHERE dest.text LIKE ('SELECT  *
FROM    Production.Product%')   
   
 
 
 
 
 
SELECT  p.ProductID
FROM    Production.Product AS p
        JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE   pc.[Name] = 'Bikes'
        AND ps.[Name] = 'Road Bikes'








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
		WHERE dest.text LIKE '%tha.Quantity%'










-- 11.XML


SELECT  MAX(dest.Text) AS QueryText,
        MAX(p.query_plan.value('(//@StatementSubTreeCost)[1]', 'float')) AS QueryCost
FROM    sys.dm_exec_query_stats AS s
        CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS dest
        CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) AS p
GROUP BY s.query_plan_hash
ORDER BY QueryText







WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan'
    AS sp)
SELECT  p.query_plan.value(N'(sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan/sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex/@Database)[1]',
                           'NVARCHAR(256)') AS DatabaseName
       ,s.sql_handle
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
WHERE   p.query_plan.exist(N'/sp:ShowPlanXML/sp:BatchSequence/sp:Batch/sp:Statements/sp:StmtSimple/sp:QueryPlan//sp:MissingIndexes') = 1
ORDER BY s.total_elapsed_time DESC









--Part 6: Advanced Techniques
--UNION
SELECT  pm.Name,
        pm.ModifiedDate
FROM    Production.ProductModel AS pm
UNION
SELECT  pm.Name,
        pm.ModifiedDate
FROM    Production.ProductModel AS pm






SELECT  pm.Name,
        pm.ModifiedDate
FROM    Production.ProductModel AS pm
UNION
SELECT  pm.Name,
        pm.ModifiedDate
FROM    Production.ProductModel AS pm
OPTION  (MERGE UNION)






SELECT  pm.Name,
        pm.ModifiedDate
FROM    Production.ProductModel AS pm
UNION
SELECT  pm.Name,
        pm.ModifiedDate
FROM    Production.ProductModel AS pm
OPTION  (HASH UNION)










--Joins
SELECT  s.Name AS StoreName,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN Sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
        JOIN Person.Person AS p
        ON sp.BusinessEntityID = p.BusinessEntityID






SELECT  s.Name AS StoreName,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN Sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
        JOIN Person.Person AS p
        ON sp.BusinessEntityID = p.BusinessEntityID
OPTION  (LOOP JOIN)







SELECT  s.Name AS StoreName,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN Sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
        JOIN Person.Person AS p
        ON sp.BusinessEntityID = p.BusinessEntityID
OPTION  (HASH JOIN)













SELECT  s.Name AS StoreName,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN Sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
        JOIN Person.Person AS p
        ON sp.BusinessEntityID = p.BusinessEntityID
OPTION  (MERGE JOIN)










--Force Order
SELECT  pc.Name AS ProductCategoryName,
        ps.Name AS ProductSubCategoryName,
        p.Name AS ProductName,
        pdr.Description,
        pm.Name AS ProductModelName,
        c.Name AS CultureName,
        d.FileName,
        pri.Quantity,
        pr.Rating,
        pr.Comments
FROM    Production.Product AS p
        LEFT JOIN Production.ProductModel AS pm
        ON p.ProductModelID = pm.ProductModelID
        LEFT JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        LEFT JOIN Production.ProductInventory AS pri
        ON p.ProductID = pri.ProductID
        LEFT JOIN Production.ProductReview AS pr
        ON p.ProductID = pr.ProductID
        LEFT JOIN Production.ProductDocument AS pd
        ON p.ProductID = pd.ProductID
        LEFT JOIN Production.Document AS d
        ON pd.DocumentNode = d.DocumentNode
        LEFT JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
        LEFT JOIN Production.ProductModelProductDescriptionCulture AS pmpdc
        ON pm.ProductModelID = pmpdc.ProductModelID
        LEFT JOIN Production.ProductDescription AS pdr
        ON pmpdc.ProductDescriptionID = pdr.ProductDescriptionID
        LEFT JOIN Production.Culture AS c
        ON c.CultureID = pmpdc.CultureID







SELECT  pc.Name AS ProductCategoryName,
        ps.Name AS ProductSubCategoryName,
        p.Name AS ProductName,
        pdr.Description,
        pm.Name AS ProductModelName,
        c.Name AS CultureName,
        d.FileName,
        pri.Quantity,
        pr.Rating,
        pr.Comments
FROM    Production.Product AS p
        LEFT JOIN Production.ProductModel AS pm
        ON p.ProductModelID = pm.ProductModelID
        LEFT JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        LEFT JOIN Production.ProductInventory AS pri
        ON p.ProductID = pri.ProductID
        LEFT JOIN Production.ProductReview AS pr
        ON p.ProductID = pr.ProductID
        LEFT JOIN Production.ProductDocument AS pd
        ON p.ProductID = pd.ProductID
        LEFT JOIN Production.Document AS d
        ON pd.DocumentNode = d.DocumentNode
        LEFT JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
        LEFT JOIN Production.ProductModelProductDescriptionCulture AS pmpdc
        ON pm.ProductModelID = pmpdc.ProductModelID
        LEFT JOIN Production.ProductDescription AS pdr
        ON pmpdc.ProductDescriptionID = pdr.ProductDescriptionID
        LEFT JOIN Production.Culture AS c
        ON c.CultureID = pmpdc.CultureID
        
OPTION (FORCE ORDER)








--MAXDOP
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'cost threshold for parallelism', 1;
go
RECONFIGURE WITH override;
go

SELECT  wo.DueDate,
		p.class,
        MIN(wo.OrderQty) AS MinOrderQty,
        MIN(wo.StockedQty) AS MinStockedQty,
        MIN(wo.ScrappedQty) AS MinScrappedQty,
        MAX(wo.OrderQty) AS MaxOrderQty,
        MAX(wo.StockedQty) AS MaxStockedQty,
        MAX(wo.ScrappedQty) AS MaxScrappedQty
FROM    Production.WorkOrder AS wo
JOIN Production.Product AS p
ON wo.ProductID = p.ProductID
GROUP BY wo.DueDate,p.Class
ORDER BY wo.DueDate ;



SELECT  wo.DueDate,
		p.class,
        MIN(wo.OrderQty) AS MinOrderQty,
        MIN(wo.StockedQty) AS MinStockedQty,
        MIN(wo.ScrappedQty) AS MinScrappedQty,
        MAX(wo.OrderQty) AS MaxOrderQty,
        MAX(wo.StockedQty) AS MaxStockedQty,
        MAX(wo.ScrappedQty) AS MaxScrappedQty
FROM    Production.WorkOrder AS wo
JOIN Production.Product AS p
ON wo.ProductID = p.ProductID
GROUP BY wo.DueDate,p.Class
ORDER BY wo.DueDate  
OPTION (MAXDOP 1);


sp_configure 'cost threshold for parallelism', 50;
go
RECONFIGURE WITH override;
go



--OPTIMIZE FOR
--already did one
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
    DBCC freeproccache(0x050008009BF9DC35402109B0000000000000000000000000) ;





--running in the reverse order leads to a different plan for both
    EXEC dbo.spAddressByCity @City = N'Mentor' ;



    EXEC dbo.spAddressByCity @City = N'London' ;
	









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


--JOIN HINTS

SELECT  pm.Name,
        pm.CatalogDescription,
        p.Name AS ProductName,
        i.Diagram
FROM    Production.ProductModel AS pm
        LEFT JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
        LEFT JOIN Production.ProductModelIllustration AS pmi
        ON p.ProductModelID = pmi.ProductModelID
        LEFT JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE   pm.Name LIKE '%Mountain%'
ORDER BY pm.Name


--Loop
SELECT  pm.Name,
        pm.CatalogDescription,
        p.Name AS ProductName,
        i.Diagram
FROM    Production.ProductModel AS pm
        LEFT LOOP JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
        LEFT JOIN Production.ProductModelIllustration AS pmi
        ON p.ProductModelID = pmi.ProductModelID
        LEFT JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE   pm.Name LIKE '%Mountain%'
ORDER BY pm.Name


--Merge
SELECT  pm.Name,
        pm.CatalogDescription,
        p.Name AS ProductName,
        i.Diagram
FROM    Production.ProductModel AS pm
        LEFT MERGE JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
        LEFT JOIN Production.ProductModelIllustration AS pmi
        ON p.ProductModelID = pmi.ProductModelID
        LEFT JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE   pm.Name LIKE '%Mountain%'
ORDER BY pm.Name







--Table Hints
-- NOEXPAND
SELECT a.City,
vspcr.StateProvinceName,
vspcr.CountryRegionName
FROM Person.Address AS a 
JOIN Person.vStateProvinceCountryRegion AS vspcr
ON a.StateProvinceID = vspcr.StateProvinceID
WHERE a.AddressID = 22701;



SELECT a.City,
vspcr.StateProvinceName,
vspcr.CountryRegionName
FROM Person.Address AS a 
JOIN Person.vStateProvinceCountryRegion AS vspcr WITH (NOEXPAND )
ON a.StateProvinceID = vspcr.StateProvinceID
WHERE a.AddressID = 22701;









-- INDEX()
SELECT  d.Name,
        e.JobTitle,
        p.LastName + ', ' + p.FirstName
FROM    HumanResources.Department AS d
        JOIN HumanResources.EmployeeDepartmentHistory AS edh
        ON d.DepartmentID = edh.DepartmentID
        JOIN HumanResources.Employee AS e
        ON edh.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID
WHERE   d.Name LIKE 'P%'






SELECT  d.Name,
        e.JobTitle,
        p.LastName + ', ' + p.FirstName
FROM    HumanResources.Department AS d WITH (INDEX (PK_Department_DepartmentID))
        JOIN HumanResources.EmployeeDepartmentHistory AS edh
        ON d.DepartmentID = edh.DepartmentID
        JOIN HumanResources.Employee AS e
        ON edh.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID
WHERE   d.Name LIKE 'P%'



-- FAST N
SELECT  pm.Name AS ProductModelName,
        p.Name AS ProductName,
        SUM(piv.Quantity)
FROM    Production.ProductModel AS pm
        JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
        JOIN Production.ProductInventory AS piv
        ON p.ProductID = piv.ProductID
GROUP BY pm.Name,
        p.Name
        
        
        






SELECT  pm.Name AS ProductModelName,
        p.Name AS ProductName,
        SUM(piv.Quantity)
FROM    Production.ProductModel AS pm
        JOIN Production.Product AS p WITH (FASTFIRSTROW)
        ON pm.ProductModelID = p.ProductModelID
        JOIN Production.ProductInventory AS piv
        ON p.ProductID = piv.ProductID
GROUP BY pm.Name,
        p.Name







--Plan guides
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
    WHERE   a.City = @City ;', -- nvarchar(max)
    @type = N'Object', -- nvarchar(60)
    @module_or_batch = N'dbo.spAddressByCity', -- nvarchar(max)
    @params = NULL, -- nvarchar(max)
    @hints = N'OPTION(OPTIMIZE FOR(@City = ''Mentor''))' -- nvarchar(max)





EXEC dbo.spAddressByCity @City = N'London'




--clean up
EXEC sys.sp_control_plan_guide  @operation = N'DROP', -- nvarchar(60)
    @name = SniffFix -- sysname
    
    








--Plan Forcing
IF (SELECT  OBJECT_ID('Sales.uspGetCreditInfo')
   ) IS NOT NULL 
    DROP PROCEDURE Sales.UspGetCreditInfo ;
GO
CREATE PROCEDURE Sales.uspGetCreditInfo (@SalesPersonID INT)
AS 
    SELECT  soh.AccountNumber,
            soh.CreditCardApprovalCode,
            soh.CreditCardID,
            soh.OnlineOrderFlag
    FROM    Sales.SalesOrderHeader AS soh
    WHERE   soh.SalesPersonID = @SalesPersonId;


    
EXEC Sales.uspGetCreditInfo @SalesPersonID = 277


-- to get the plan_handle	
    SELECT  decp.plan_handle
    FROM    sys.dm_exec_cached_plans AS decp
            CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest
    WHERE   dest.[text] LIKE 'CREATE PROCEDURE Sales.uspGetCreditInfo%' ;


--to just remove the one plan from cache
    DBCC freeproccache(0x05000E00D6A9FB47105FB80D0200000001000000000000000000000000000000000000000000000000000000) ;
    
    
EXEC Sales.uspGetCreditInfo @SalesPersonID = 288






    
 
 SET STATISTICS XML ON
 GO
 SELECT  soh.AccountNumber,
            soh.CreditCardApprovalCode,
            soh.CreditCardID,
            soh.OnlineOrderFlag
    FROM    Sales.SalesOrderHeader AS soh
    WHERE   soh.SalesPersonID = 288;
GO
SET STATISTICS XML OFF
GO





EXEC sys.sp_create_plan_guide @name = N'UsePlanGuide', -- sysname
    @stmt = N'SELECT  soh.AccountNumber,
            soh.CreditCardApprovalCode,
            soh.CreditCardID,
            soh.OnlineOrderFlag
    FROM    Sales.SalesOrderHeader AS soh
    WHERE   soh.SalesPersonID = @SalesPersonId;', -- nvarchar(max)
    @type = N'OBJECT', -- nvarchar(60)
    @module_or_batch = N'Sales.uspGetCreditInfo', -- nvarchar(max)
    @params = NULL, -- nvarchar(max)
    @hints = N'OPTION (USE PLAN N''<ShowPlanXML xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Version="1.1" Build="10.50.1600.1" xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan">
  <BatchSequence>
    <Batch>
      <Statements>
        <StmtSimple StatementCompId="1" StatementEstRows="130" StatementId="1" StatementOptmLevel="FULL" StatementOptmEarlyAbortReason="GoodEnoughPlanFound" StatementSubTreeCost="0.39206" StatementText="SELECT [soh].[AccountNumber],[soh].[CreditCardApprovalCode],[soh].[CreditCardID],[soh].[OnlineOrderFlag] FROM [Sales].[SalesOrderHeader] [soh] WHERE [soh].[SalesPersonID]=@1" StatementType="SELECT" QueryHash="0xA12014ED981E6E4B" QueryPlanHash="0xE527A9A568F4BC33">
          <StatementSetOptions ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" NUMERIC_ROUNDABORT="false" QUOTED_IDENTIFIER="true" />
          <QueryPlan DegreeOfParallelism="1" CachedPlanSize="32" CompileTime="2" CompileCPU="2" CompileMemory="232">
            <RelOp AvgRowSize="40" EstimateCPU="0.0005434" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="130" LogicalOp="Inner Join" NodeId="0" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.39206">
              <OutputList>
                <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag" />
                <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber" />
                <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID" />
                <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode" />
              </OutputList>
              <RunTimeInformation>
                <RunTimeCountersPerThread Thread="0" ActualRows="130" ActualEndOfScans="1" ActualExecutions="1" />
              </RunTimeInformation>
              <NestedLoops Optimized="false" WithUnorderedPrefetch="true">
                <OuterReferences>
                  <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID" />
                  <ColumnReference Column="Expr1003" />
                </OuterReferences>
                <RelOp AvgRowSize="11" EstimateCPU="0.0003" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="130" LogicalOp="Index Seek" NodeId="2" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.003425" TableCardinality="31465">
                  <OutputList>
                    <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID" />
                  </OutputList>
                  <RunTimeInformation>
                    <RunTimeCountersPerThread Thread="0" ActualRows="130" ActualEndOfScans="1" ActualExecutions="1" />
                  </RunTimeInformation>
                  <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" NoExpandHint="false">
                    <DefinedValues>
                      <DefinedValue>
                        <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID" />
                      </DefinedValue>
                    </DefinedValues>
                    <Object Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Index="[IX_SalesOrderHeader_SalesPersonID]" Alias="[soh]" IndexKind="NonClustered" />
                    <SeekPredicates>
                      <SeekPredicateNew>
                        <SeekKeys>
                          <Prefix ScanType="EQ">
                            <RangeColumns>
                              <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesPersonID" />
                            </RangeColumns>
                            <RangeExpressions>
                              <ScalarOperator ScalarString="(288)">
                                <Const ConstValue="(288)" />
                              </ScalarOperator>
                            </RangeExpressions>
                          </Prefix>
                        </SeekKeys>
                      </SeekPredicateNew>
                    </SeekPredicates>
                  </IndexScan>
                </RelOp>
                <RelOp AvgRowSize="40" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="129" EstimateRewinds="0" EstimateRows="1" LogicalOp="Clustered Index Seek" NodeId="4" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.388092" TableCardinality="31465">
                  <OutputList>
                    <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag" />
                    <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber" />
                    <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID" />
                    <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode" />
                  </OutputList>
                  <RunTimeInformation>
                    <RunTimeCountersPerThread Thread="0" ActualRows="130" ActualEndOfScans="0" ActualExecutions="130" />
                  </RunTimeInformation>
                  <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" NoExpandHint="false">
                    <DefinedValues>
                      <DefinedValue>
                        <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag" />
                      </DefinedValue>
                      <DefinedValue>
                        <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber" />
                      </DefinedValue>
                      <DefinedValue>
                        <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID" />
                      </DefinedValue>
                      <DefinedValue>
                        <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode" />
                      </DefinedValue>
                    </DefinedValues>
                    <Object Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Index="[PK_SalesOrderHeader_SalesOrderID]" Alias="[soh]" TableReferenceId="-1" IndexKind="Clustered" />
                    <SeekPredicates>
                      <SeekPredicateNew>
                        <SeekKeys>
                          <Prefix ScanType="EQ">
                            <RangeColumns>
                              <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID" />
                            </RangeColumns>
                            <RangeExpressions>
                              <ScalarOperator ScalarString="[AdventureWorks2008R2].[Sales].[SalesOrderHeader].[SalesOrderID] as [soh].[SalesOrderID]">
                                <Identifier>
                                  <ColumnReference Database="[AdventureWorks2008R2]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID" />
                                </Identifier>
                              </ScalarOperator>
                            </RangeExpressions>
                          </Prefix>
                        </SeekKeys>
                      </SeekPredicateNew>
                    </SeekPredicates>
                  </IndexScan>
                </RelOp>
              </NestedLoops>
            </RelOp>
            <ParameterList>
              <ColumnReference Column="@1" ParameterCompiledValue="(288)" ParameterRuntimeValue="(288)" />
            </ParameterList>
          </QueryPlan>
        </StmtSimple>
      </Statements>
    </Batch>
  </BatchSequence>
</ShowPlanXML>'')' -- nvarchar(max)



dbcc freeproccache



EXEC Sales.uspGetCreditInfo @SalesPersonID = 277;


--cleanup
exec sp_control_plan_guide 'DROP','UsePlanGuide'




SELECT  CAST(detqp.query_plan AS XML)
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
        CROSS APPLY sys.dm_exec_text_query_plan(deqs.plan_handle,
                                                deqs.statement_start_offset,
                                                deqs.statement_end_offset) AS detqp





--CTE
WITH    cte_TestRecs
          AS ( SELECT   1000 AS TestField1 ,
                        1 AS IsEven
               UNION ALL
               SELECT   TestField1 + 1 ,
                        TestField1 % 2
               FROM     cte_TestRecs
               WHERE    TestField1 < 1100
             ),
        cte_Filter
          AS ( SELECT   TestField1 AS EvenField
               FROM     cte_TestRecs
               WHERE    IsEven = 1
             )
    SELECT  *
    FROM    cte_TestRecs
    WHERE   TestField1 NOT IN (
                                /*  This is the part that should fail because TestField1 was aliased in 
                                    the CTE. Running the query like this will NOT return any records; nor 
                                    will it give you an error stating an invalid column name. Changing 
                                    this to EvenField will return a recordset as expected.
                                */ SELECT   TestField1
                                   FROM     cte_Filter )











--columnstore
SELECT  tha.ProductID,
        COUNT(tha.ProductID) AS CountProductID,
        SUM(tha.Quantity) AS SumQuantity,
        AVG(tha.ActualCost) AS AvgActualCost
FROM    Production.TransactionHistoryArchive AS tha
GROUP BY tha.ProductID
OPTION (querytraceon 8649);

DROP INDEX production.transactionhistoryarchive.ix_cstest

CREATE NONCLUSTERED COLUMNSTORE INDEX ix_csTest
ON Production.TransactionHistoryArchive
(ProductID,
Quantity,
ActualCost);

DROP TABLE dbo.TransactionHistoryArchive


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








-- in memory
USE master
GO

CREATE DATABASE InMemoryTest ON PRIMARY 
	(NAME = N'InMemoryTest_Data',
	FILENAME = N'C:\Data\InMemoryTest_Data.mdf', 
	SIZE = 5GB)
LOG ON 
	(NAME = N'InMemoryTest_Log',
	FILENAME = N'C:\Data\InMemoryTest_Log.ldf');





ALTER DATABASE InMemoryTest 
	ADD FILEGROUP InMemoryTest_InMemoryData
	CONTAINS MEMORY_OPTIMIZED_DATA;
ALTER DATABASE InMemoryTest 
	ADD FILE (NAME='InMemoryTest_InMemoryData', 
	filename='C:\Data\InMemoryTest_InMemoryData.ndf') 
	TO FILEGROUP InMemoryTest_InMemoryData;



DROP TABLE dbo.Address;
drop procedure dbo.addressdetails

CREATE TABLE dbo.Address(
	AddressID int IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=50000),
	AddressLine1 nvarchar(60) NOT NULL,
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(30) NOT NULL,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL,
	--[SpatialLocation geography NULL,
	--rowguid uniqueidentifier ROWGUIDCOL  NOT NULL CONSTRAINT DF_Address_rowguid  DEFAULT (newid()),
	ModifiedDate datetime NOT NULL CONSTRAINT DF_Address_ModifiedDate  DEFAULT (getdate())
) WITH (MEMORY_OPTIMIZED=ON);


EXEC dbo.addressdetails 6294




SELECT  a.AddressID
FROM    dbo.Address AS a
WHERE	a.AddressID = 42;


drop table dbo.addressstaging;




CREATE TABLE dbo.AddressStaging(
	AddressLine1 nvarchar(60) NOT NULL,
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(30) NOT NULL,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL
);


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
FROM    AdventureWorks2012.Person.Address AS a;


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




DROP TABLE dbo.StateProvince;


CREATE TABLE dbo.StateProvince(
	 StateProvinceID int IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=10000),
	 StateProvinceCode nchar(3) NOT NULL,
	 CountryRegionCode nvarchar(3) COLLATE Latin1_General_100_BIN2 NOT NULL,
	 Name VARCHAR(50) NOT NULL,
	 TerritoryID int NOT NULL,
	 ModifiedDate datetime NOT NULL CONSTRAINT DF_StateProvince_ModifiedDate  DEFAULT (getdate())
) WITH (MEMORY_OPTIMIZED=ON);



CREATE TABLE dbo.CountryRegion(
	CountryRegionCode nvarchar(3) NOT NULL,
	Name VARCHAR(50) NOT NULL,
	ModifiedDate datetime NOT NULL CONSTRAINT DF_CountryRegion_ModifiedDate  DEFAULT (getdate()),
 CONSTRAINT PK_CountryRegion_CountryRegionCode PRIMARY KEY CLUSTERED 
(
	CountryRegionCode ASC
));




SELECT  sp.StateProvinceCode,
        sp.CountryRegionCode,
        sp.Name,
        sp.TerritoryID
INTO    dbo.StateProvinceStaging
FROM    AdventureWorks2012.Person.StateProvince AS sp;

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


INSERT  dbo.countryregion
        (countryregioncode,
         name
        )
        SELECT  cr.CountryRegionCode,
                cr.Name
        FROM    AdventureWorks2012.Person.CountryRegion AS cr


USE InMemoryTest;

SELECT  a.AddressLine1,
        a.City,
        a.PostalCode,
        sp.Name AS StateProvinceName--
        --cr.Name AS CountryName
FROM    dbo.Address AS a
        JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
        --JOIN dbo.CountryRegion cr
        --ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID = 882;

SELECT * FROM dbo.Address AS a



USE AdventureWorks2012;

SELECT  a.AddressLine1,
        a.City,
        a.PostalCode,
        sp.Name AS StateProvinceName--,
        --cr.Name AS CountryName
FROM    Person.Address AS a
        JOIN Person.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
        --JOIN Person.CountryRegion AS cr
        --ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE   a.AddressID = 882;





USE InMemoryTest


SELECT  i.name AS 'index name',
        hs.total_bucket_count,
        hs.empty_bucket_count,
        hs.avg_chain_length,
        hs.max_chain_length
FROM    sys.dm_db_xtp_hash_index_stats AS hs
        JOIN sys.indexes AS i
        ON hs.object_id = i.object_id AND
           hs.index_id = i.index_id
WHERE   OBJECT_NAME(hs.object_id) = 'Address';

   






SELECT * FROM sys.dm_db_xtp_hash_index_stats AS ddxhis








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
WHERE   a.City = 'Walla Walla';






DROP TABLE dbo.Address

CREATE TABLE dbo.Address(
	AddressID int IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=50000),
	AddressLine1 nvarchar(60) NOT NULL,
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(30) COLLATE Latin1_General_100_BIN2 NOT NULL,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL,
	ModifiedDate datetime NOT NULL CONSTRAINT DF_Address_ModifiedDate  DEFAULT (getdate()),
	INDEX nci NONCLUSTERED (City)
) WITH (MEMORY_OPTIMIZED=ON);



CREATE TABLE dbo.AddressStaging(
	AddressLine1 nvarchar(60) NOT NULL,
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(30) NOT NULL,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL
);


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
FROM    AdventureWorks2012.Person.Address AS a;


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
WHERE   a.City = 'Walla Walla';







DBCC SHOW_STATISTICS (Address,nci);


UPDATE STATISTICS dbo.Address WITH FULLSCAN, NORECOMPUTE;


SELECT  s.name AS TableName,
		si.name AS IndexName,
        ddxis.scans_started,
        ddxis.rows_returned,
        ddxis.rows_expiring,
        ddxis.rows_expired
FROM    sys.dm_db_xtp_index_stats AS ddxis
        JOIN sys.sysobjects AS s
        ON ddxis.object_id = s.id
		JOIN sys.sysindexes AS si
		ON ddxis.object_id = si.id
		AND ddxis.index_id = si.indid






SELECT * FROM sys.dm_db_xtp_index_stats AS ddxis




SELECT * FROM sys.dm_db_xtp_nonclustered_index_stats AS ddxnis




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




DROP TABLE dbo.CountryRegion;

CREATE TABLE dbo.CountryRegion(
	CountryRegionCode nvarchar(3) COLLATE Latin1_General_100_BIN2 NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1000) ,
	Name VARCHAR(50) COLLATE Latin1_General_100_BIN2 NOT NULL,
	ModifiedDate datetime NOT NULL CONSTRAINT DF_CountryRegion_ModifiedDate  DEFAULT (getdate()),
 )WITH (MEMORY_OPTIMIZED=ON);


SELECT  CountryRegionCode,
        Name
INTO    dbo.CountryRegionStaging
FROM    AdventureWorks2012.Person.CountryRegion AS cr;

INSERT dbo.CountryRegion
        (CountryRegionCode,
         Name
        )
SELECT CountryRegionCode,Name FROM CountryRegionStaging;






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


SELECT * FROM dbo.Address AS a


USE InMemoryTest;
GO

CREATE TABLE dbo.AddressStaging
    (
     AddressID INT NOT NULL
                   IDENTITY(1, 1)
                   PRIMARY KEY,
     AddressLine1 NVARCHAR(60) NOT NULL,
     AddressLine2 NVARCHAR(60) NULL,
     City NVARCHAR(30) NOT NULL,
     StateProvinceID INT NOT NULL,
     PostalCode NVARCHAR(15) NOT NULL
    );






CREATE PROCEDURE dbo.FailWizard (@City NVARCHAR(30))
AS
    SELECT  a.AddressLine1,
            a.City,
            a.PostalCode,
            sp.Name AS StateProvinceName,
            cr.Name AS CountryName
    FROM    dbo.Address AS a
            JOIN dbo.StateProvince AS sp
            ON sp.StateProvinceID = a.StateProvinceID
            JOIN dbo.CountryRegion AS cr WITH ( NOLOCK)
            ON cr.CountryRegionCode = sp.CountryRegionCode
    WHERE   a.City = @City;
GO

CREATE PROCEDURE dbo.PassWizard (@City NVARCHAR(30))
AS
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
GO




-- questions
EXEC sys.sp_procedure_params_100_managed
    @procedure_name = 'uspGetBillOfMaterials',
    @group_number = 1,
    @procedure_schema = 'dbo',
    @parameter_name = NULL;