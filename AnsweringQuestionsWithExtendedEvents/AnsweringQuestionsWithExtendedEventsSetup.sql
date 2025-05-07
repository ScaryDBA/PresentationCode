CREATE EVENT SESSION [AnswerDatabaseBehavior]
ON SERVER
    ADD EVENT sqlserver.bdc_alter_database_collation_request_completed,
    ADD EVENT sqlserver.bdc_alter_database_name_request_completed,
    ADD EVENT sqlserver.bdc_drop_database_request_completed,
    ADD EVENT sqlserver.database_attached,
    ADD EVENT sqlserver.database_cmptlevel_change,
    ADD EVENT sqlserver.database_created,
    ADD EVENT sqlserver.database_detached,
    ADD EVENT sqlserver.database_dropped,
    ADD EVENT sqlserver.database_file_size_change,
    ADD EVENT sqlserver.database_recovery_progress_report,
    ADD EVENT sqlserver.database_recovery_times,
    ADD EVENT sqlserver.database_recovery_trace,
    ADD EVENT sqlserver.database_started,
    ADD EVENT sqlserver.database_stopped,
    ADD EVENT sqlserver.databases_backup_restore_throughput,
    ADD EVENT sqlserver.databases_bulk_copy_rows,
    ADD EVENT sqlserver.databases_bulk_copy_throughput,
    ADD EVENT sqlserver.databases_bulk_insert_rows,
    ADD EVENT sqlserver.databases_bulk_insert_throughput,
    ADD EVENT sqlserver.databases_data_file_size_changed,
    ADD EVENT sqlserver.databases_log_file_size_changed,
    ADD EVENT sqlserver.databases_log_file_used_size_changed,
    ADD EVENT sqlserver.databases_log_growth,
    ADD EVENT sqlserver.databases_log_shrink,
    ADD EVENT sqlserver.databases_log_truncation
    ADD TARGET package0.event_file
    (SET filename = N'DatabaseBehavior');


CREATE EVENT SESSION AnswerImplicitConversionAlternativeOne
ON SERVER
    ADD EVENT sqlserver.plan_affecting_convert
    (WHERE (sqlserver.database_name = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE (sqlserver.database_name = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_starting
    (WHERE (sqlserver.database_name = N'AdventureWorks'))
    ADD TARGET package0.event_file
    (SET filename = N'ImplicitConversion1')
WITH (TRACK_CAUSALITY = ON);

CREATE EVENT SESSION AnswerImplicitConversionAlternativeTwo
ON SERVER
    ADD EVENT sqlserver.plan_affecting_convert
    (ACTION (sqlserver.sql_text)
     WHERE (sqlserver.equal_i_sql_unicode_string(sqlserver.database_name, N'AdventureWorks')))
    ADD TARGET package0.event_file
    (SET filename = N'ImplicitConversion2');


CREATE EVENT SESSION AnswerProcedureWaits
ON SERVER
    ADD EVENT sqlos.wait_completed
    (SET collect_wait_resource = (1)
     WHERE (sqlserver.equal_i_sql_unicode_string(sqlserver.database_name, N'AdventureWorks'))),
    ADD EVENT sqlserver.module_end
    (WHERE (   sqlserver.database_name = N'AdventureWorks'
         AND   object_name = N'ProductTransactionHistoryByReference')),
    ADD EVENT sqlserver.rpc_completed
    (WHERE (sqlserver.database_name = N'AdventureWorks')),
    ADD EVENT sqlserver.rpc_starting
    (WHERE (sqlserver.database_name = N'AdventureWorks'))
WITH (TRACK_CAUSALITY = ON);


CREATE EVENT SESSION [AnswerProcedureExecutionCount]
ON SERVER
    ADD EVENT sqlserver.rpc_completed
    (WHERE ([object_name] = N'ProductTransactionHistoryByReference'))
    ADD TARGET package0.histogram
    (SET filtering_event_name = N'sqlserver.rpc_completed', source = N'object_name', source_type = (0));
GO


CREATE EVENT SESSION [AnswerProductTransactionHistoryByReference]
ON SERVER
    ADD EVENT sqlserver.rpc_completed
    (WHERE ([object_name] = N'ProductTransactionHistoryByReference'))
    ADD TARGET package0.event_file
    (SET filename = N'AnswerProductTransactionHistoryByReference');
GO


CREATE EVENT SESSION [AnswerQueryPerformance]
ON SERVER
    ADD EVENT sqlserver.rpc_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks'))
    ADD TARGET package0.event_file
    (SET filename = N'AnswerQueryPerformance');
GO


CREATE EVENT SESSION [AnswerQueryWaits]
ON SERVER
    ADD EVENT sqlos.wait_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_starting
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks'))
    ADD TARGET package0.event_file
    (SET filename = N'AnswerQueryWaits')
WITH (TRACK_CAUSALITY = ON);
GO




