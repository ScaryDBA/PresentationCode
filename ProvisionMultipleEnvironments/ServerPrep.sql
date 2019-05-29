USE master;
GO

--check for the existence of linked server
DECLARE @Servers TABLE (srv_name sysname,
                        srv_providerName NVARCHAR(128),
                        srv_product NVARCHAR(128),
                        srv_datasource NVARCHAR(128),
                        srv_providerstring NVARCHAR(128),
                        srv_location NVARCHAR(128),
                        srv_cat NVARCHAR(128));

INSERT @Servers
EXEC sys.sp_linkedservers;

--if it's not there, create it
IF NOT EXISTS (SELECT * FROM @Servers WHERE srv_name = 'EXTERNALSALES')
BEGIN
    EXEC master.sys.sp_addlinkedserver @server = N'EXTERNALSALES',
                                       @srvproduct = N'',
                                       @provider = N'SQLNCLI11',
                                       @datasrc = N'10.0.0.6',
                                       @catalog = N'Sales';
    EXEC master.sys.sp_addlinkedsrvlogin @rmtsrvname = N'EXTERNALSALES',
                                         @useself = N'False',
                                         @locallogin = NULL,
                                         @rmtuser = N'SalesDataLoad',
                                         @rmtpassword = '$cthulhu1988';
END;

USE Sales;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CreditCard')
BEGIN
    CREATE TABLE dbo.CreditCard (CardNumber NVARCHAR(25) NOT NULL);
END;
GO

--check to see if the job exists, if not, create it
USE msdb;
GO

IF NOT EXISTS (SELECT * FROM dbo.sysjobs WHERE name = 'DataLoad')
BEGIN

    BEGIN TRANSACTION;
    DECLARE @ReturnCode INT;
    SELECT @ReturnCode = 0;

    IF NOT EXISTS (SELECT name
                   FROM msdb.dbo.syscategories
                   WHERE name = N'[Uncategorized (Local)]'
                         AND category_class = 1)
    BEGIN
        EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB',
                                                    @type = N'LOCAL',
                                                    @name = N'[Uncategorized (Local)]';
        IF (@@ERROR <> 0 OR @ReturnCode <> 0)
            GOTO QuitWithRollback;

    END;

    DECLARE @jobId BINARY(16);
    EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'DataLoad',
                                           @enabled = 1,
                                           @notify_level_eventlog = 0,
                                           @notify_level_email = 0,
                                           @notify_level_netsend = 0,
                                           @notify_level_page = 0,
                                           @delete_level = 0,
                                           @description = N'For moving linked server data into sales db.',
                                           @category_name = N'[Uncategorized (Local)]',
                                           @job_id = @jobId OUTPUT;
    IF (@@ERROR <> 0 OR @ReturnCode <> 0)
        GOTO QuitWithRollback;
    /****** Object:  Step [CopyData]    Script Date: 5/28/2019 3:54:35 PM ******/
    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId,
                                               @step_name = N'CopyData',
                                               @step_id = 1,
                                               @cmdexec_success_code = 0,
                                               @on_success_action = 1,
                                               @on_success_step_id = 0,
                                               @on_fail_action = 2,
                                               @on_fail_step_id = 0,
                                               @retry_attempts = 0,
                                               @retry_interval = 0,
                                               @os_run_priority = 0,
                                               @subsystem = N'TSQL',
                                               @command = N'TRUNCATE TABLE dbo.CreditCard;

INSERT INTO dbo.CreditCard
select CardNumber 
FROM EXTERNALSALES.Sales.Sales.CreditCard;',
                                               @database_name = N'Sales',
                                               @flags = 0;
    IF (@@ERROR <> 0 OR @ReturnCode <> 0)
        GOTO QuitWithRollback;
    EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId,
                                              @start_step_id = 1;
    IF (@@ERROR <> 0 OR @ReturnCode <> 0)
        GOTO QuitWithRollback;
    EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                                   @name = N'DailyDataLoad',
                                                   @enabled = 1,
                                                   @freq_type = 4,
                                                   @freq_interval = 1,
                                                   @freq_subday_type = 1,
                                                   @freq_subday_interval = 0,
                                                   @freq_relative_interval = 0,
                                                   @freq_recurrence_factor = 0,
                                                   @active_start_date = 20190528,
                                                   @active_end_date = 99991231,
                                                   @active_start_time = 0,
                                                   @active_end_time = 235959,
                                                   @schedule_uid = N'670b09d9-918a-4f97-81df-5351e272733a';
    IF (@@ERROR <> 0 OR @ReturnCode <> 0)
        GOTO QuitWithRollback;
    EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId,
                                                 @server_name = N'(local)';
    IF (@@ERROR <> 0 OR @ReturnCode <> 0)
        GOTO QuitWithRollback;
    COMMIT TRANSACTION;
    GOTO EndSave;
    QuitWithRollback:
    IF (@@TRANCOUNT > 0)
        ROLLBACK TRANSACTION;
    EndSave:

END;
GO


--if the server login doesn't exist, create it
USE master;
GO
IF NOT EXISTS (SELECT * FROM sys.syslogins WHERE name = 'SalesProd')
BEGIN
    CREATE LOGIN SalesProd
    WITH PASSWORD = N'$cthulhu1988',
         DEFAULT_DATABASE = master,
         DEFAULT_LANGUAGE = us_english,
         CHECK_EXPIRATION = OFF,
         CHECK_POLICY = OFF;
END;
GO

--ensure that the sid in the database matches the server
USE Sales;
GO

ALTER USER SalesProd WITH LOGIN = SalesProd;
GO