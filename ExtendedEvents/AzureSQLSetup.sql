--create an encryption key
IF NOT EXISTS
    (SELECT * FROM sys.symmetric_keys
        WHERE symmetric_key_id = 101)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'gobblydyg@@k42'
END
GO

--create a database scoped credential
IF EXISTS
    (SELECT * FROM sys.database_scoped_credentials
        WHERE name = 'https://exeventsoutput.blob.core.windows.net/exevents')
BEGIN
    DROP DATABASE SCOPED CREDENTIAL
        -- TODO: Assign AzureStorageAccount name, and the associated Container name.
        [https://exeventsoutput.blob.core.windows.net/exevents] ;
END
GO

CREATE
    DATABASE SCOPED
    CREDENTIAL
        [https://exeventsoutput.blob.core.windows.net/exevents]
    WITH
        IDENTITY = 'SHARED ACCESS SIGNATURE',  -- "SAS" token.
        SECRET = 'sp=rwl&st=2021-11-30T19:36:06Z&se=2024-12-01T03:36:06Z&spr=https&sv=2020-08-04&sr=c&sig=rI9kDBvaCzbMvrjprhKNMvaAZpIdmOgq0BqlcHvUBaU%3D'
    ;
GO



--get the file name from the xml
select target_data from sys.dm_xe_database_session_targets


SELECT *,
       'CLICK_NEXT_CELL_TO_BROWSE_ITS_RESULTS!' AS [CLICK_NEXT_CELL_TO_BROWSE_ITS_RESULTS],
       CAST(event_data AS XML) AS [event_data_XML]
FROM sys.fn_xe_file_target_read_file(
                                        'https://exeventsoutput.blob.core.windows.net/exevents/queryperformancemetrics_0_132827760021230000.xel',
                                        NULL,
                                        NULL,
                                        NULL
                                    );
GO