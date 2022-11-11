
CREATE EVENT SESSION [BlockedProcess] ON SERVER 
ADD EVENT sqlserver.blocked_process_report
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [Deadlock] ON SERVER 
ADD EVENT sqlserver.database_xml_deadlock_report,
ADD EVENT sqlserver.database_xml_deadlock_report_mdm,
ADD EVENT sqlserver.xml_deadlock_report,
ADD EVENT sqlserver.xml_deadlock_report_filtered
ADD TARGET package0.event_file(SET filename=N'Deadlock')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [MemoryGrant] ON SERVER 
ADD EVENT sqlserver.memory_grant_feedback_loop_disabled(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks')),
ADD EVENT sqlserver.memory_grant_updated_by_feedback(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks')),
ADD EVENT sqlserver.sql_batch_completed(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks'))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [Objects Changed] ON SERVER 
ADD EVENT sqlserver.object_altered(
    ACTION(sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.object_created(
    ACTION(sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.object_deleted(
    ACTION(sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'Objects Changed')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [ProcedureCacheBehavior] ON SERVER 
ADD EVENT sqlserver.sp_cache_hit(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks')),
ADD EVENT sqlserver.sp_cache_insert(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks')),
ADD EVENT sqlserver.sp_cache_miss(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks')),
ADD EVENT sqlserver.sp_cache_remove(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks')),
ADD EVENT sqlserver.sql_batch_completed(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks'))
ADD TARGET package0.event_file(SET filename=N'ProcedureCacheBehavior')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [Query Performance] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'AdventureWorks') OR [sqlserver].[database_name]=N'RadioGraph')),
ADD EVENT sqlserver.sql_batch_completed(
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'AdventureWorks') OR [sqlserver].[database_name]=N'RadioGraph'))
ADD TARGET package0.event_file(SET filename=N'Query Performance')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [UniqueConstraintViolation] ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.database_name,sqlserver.sql_text)
    WHERE ([error_number]=(2627)))
ADD TARGET package0.histogram(SET source=N'sqlserver.database_name')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [CardinalityFeedback] ON SERVER 
ADD EVENT sqlserver.query_ce_feedback_telemetry,
ADD EVENT sqlserver.query_feedback_analysis,
ADD EVENT sqlserver.query_feedback_validation,
ADD EVENT sqlserver.sql_batch_completed
ADD TARGET package0.event_file(SET filename=N'CardinalityFeedback')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [DOPFeedback]
ON SERVER
    ADD EVENT sqlserver.dop_feedback_eligible_query(),
    ADD EVENT sqlserver.dop_feedback_provided(),
    ADD EVENT sqlserver.dop_feedback_reverted(),
    ADD EVENT sqlserver.dop_feedback_validation(),
    ADD EVENT sqlserver.sql_batch_completed()
WITH
(
    TRACK_CAUSALITY = ON
);
GO
