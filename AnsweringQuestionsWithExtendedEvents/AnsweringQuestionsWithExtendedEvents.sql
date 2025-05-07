
USE	AdventureWorks;
GO




--database changes
CREATE DATABASE TestingAuditing;

--DROP DATABASE TestingAuditing;




--implicit conversions
SELECT soh.SalesOrderID,
       soh.TotalDue,
       sod.ProductID,
       sod.OrderQty,
	   soh.SalesOrderNumber
FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.TotalDue = 16158.6961;






--deadlock
BEGIN TRAN;
UPDATE Sales.Currency
SET Name = 'Fuji Dollar'
WHERE CurrencyCode = 'FJD';

UPDATE HumanResources.JobCandidate
SET BusinessEntityID = 212
WHERE JobCandidateID = 4;


--ROLLBACK TRAN


--retrieving deadlocks
DECLARE @path NVARCHAR(260);
--to retrieve the local path of system_health files 
SELECT @path = dosdlc.path
FROM sys.dm_os_server_diagnostics_log_configurations AS dosdlc;

SELECT @path = @path + N'system_health_*';

WITH fxd
AS (SELECT CAST(fx.event_data AS XML) AS Event_Data
    FROM sys.fn_xe_file_target_read_file(@path, NULL, NULL, NULL) AS fx )
SELECT dl.deadlockgraph
FROM
(
    SELECT dl.query('.') AS deadlockgraph
    FROM fxd
        CROSS APPLY event_data.nodes('(/event/data/value/deadlock)') AS d(dl)
) AS dl;



--waits
BEGIN TRAN
INSERT dbo.ErrorLog (ErrorTime,
                          UserName,
                          ErrorNumber,
                          ErrorSeverity,
                          ErrorState,
                          ErrorProcedure,
                          ErrorLine,
                          ErrorMessage)
VALUES (GETDATE(), -- ErrorTime - datetime
        'grant',      -- UserName - sysname
        0,         -- ErrorNumber - int
        0,         -- ErrorSeverity - int
        0,         -- ErrorState - int
        N'',       -- ErrorProcedure - nvarchar(126)
        0,         -- ErrorLine - int
        N'Hey'        -- ErrorMessage - nvarchar(4000)
    );
--run this here and in another window, wait on the rollback
--wait about 60 seconds, rollback both
--check system_health
--BEGIN TRAN
UPDATE dbo.ErrorLog
SET ErrorTime = GETDATE()
WHERE ErrorLogID = 1;

ROLLBACK
