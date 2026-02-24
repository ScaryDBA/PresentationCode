--parameter sensitive plan optimization testing
CREATE OR ALTER PROCEDURE dbo.OptionalParameter @ReferenceOrderID
INT = NULL
AS
BEGIN
    SELECT p.ProductNumber
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID
          OR @ReferenceOrderID IS NULL;
END;


--Make a copy of the bigTransactionHistory table for testing
SELECT * INTO dbo.bigTransactionHistory2
FROM dbo.bigTransactionHistory;
GO

--shape the data
UPDATE dbo.bigTransactionHistory2
SET ProductID = 1319
WHERE ProductID IN ( 28417, 28729, 11953, 35521, 11993, 29719, 20431, 29531, 29749, 7913, 29947, 10739, 26921, 20941,4497,3480,48453,30733,17393,47981,10397,44819,
5737,
6449,
27767, 27941, 47431, 31847, 32411, 39383, 39511, 35531, 28829, 35759, 29713, 29819, 16001, 29951, 10453, 34967, 16363, 41347, 39719, 39443, 39829, 38917, 41759, 16453, 16963, 17453, 16417, 17473, 17713, 10729, 21319, 21433, 21473, 29927, 21859, 16477
);
GO
--Add a single row to both tables
INSERT INTO dbo.bigProduct
(
    ProductID,
    Name,
    ProductNumber,
    SafetyStockLevel,
    ReorderPoint,
    DaysToManufacture,
    SellStartDate,
    MakeFlag,
    FinishedGoodsFlag,
    StandardCost,
    ListPrice
)
VALUES
(42, 'FarbleDing', 'CA-2222-1000', 0, 0, 0, GETDATE(), 1, 1, 42, 54);
INSERT INTO dbo.bigTransactionHistory2
(
    TransactionID,
    ProductID,
    TransactionDate,
    Quantity,
    ActualCost
)
VALUES
(31263602, 42, GETDATE(), 42, 42);
GO
--Create an index for testing
CREATE INDEX ProductIDTransactionDate
ON dbo.bigTransactionHistory2 (
                                 ProductID,
                                 TransactionDate
                             );
GO


--Let's see the procedure in action
EXEC dbo.TransactionInfo @ProductID = 1319;
EXEC dbo.TransactionInfo @ProductID = 42;


--Let's look at the meta data about the plans
SELECT deqs.query_hash,
       deqs.query_plan_hash,
       deqs.plan_handle,
       dest.text,
       deqp.query_plan
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE '%SELECT bp.Name,
           bp.ProductNumber,
           bth.TransactionDate
    FROM dbo.bigTransactionHistory2 AS bth%';


--to disable
--I'm not running this, because I need it for the demo
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_
OPTIMIZATION = OFF;




--You can look at Query Store too
SELECT qsqv.*,
       CAST(qsp.query_plan AS XML) AS query_plan,
       qsqt.query_sql_text AS variant_query_text,
       qsqt2.query_sql_text AS parent_query_text
FROM sys.query_store_query_variant AS qsqv
    JOIN sys.query_store_plan AS qsp
        ON qsqv.dispatcher_plan_id = qsp.plan_id
    JOIN sys.query_store_query AS qsq
        ON qsqv.query_variant_query_id = qsq.query_id
    JOIN sys.query_store_query_text AS qsqt
        ON qsq.query_text_id = qsqt.query_text_id
    JOIN sys.query_store_query AS qsq2
        ON qsqv.parent_query_id = qsq2.query_id
    JOIN sys.query_store_query_text AS qsqt2
        ON qsq2.query_text_id = qsqt2.query_text_id;




--Procedure with an optional parameter
CREATE OR ALTER PROC dbo.TransactionInfo
(@ProductID INT)
AS
BEGIN
    SELECT bp.Name,
           bp.ProductNumber,
           bth.TransactionDate
    FROM dbo.bigTransactionHistory2 AS bth
        JOIN dbo.bigProduct AS bp
            ON bp.ProductID = bth.ProductID
    WHERE bth.ProductID = @ProductID;
END;



--optional parameter testing
EXEC dbo.OptionalParameter @ReferenceOrderID = 1319;
EXEC dbo.OptionalParameter;



--To disable Optional Parameter Plan Optimization
ALTER DATABASE SCOPED CONFIGURATION SET OPTIONAL_PARAMETER_OPTIMIZATION = OFF;




--To observe Cardinality Estimation Feedback
CREATE EVENT SESSION [CardinalityFeedback]
ON SERVER
    ADD EVENT sqlserver.query_ce_feedback_telemetry(),
    ADD EVENT sqlserver.query_feedback_analysis(),
    ADD EVENT sqlserver.query_feedback_validation(),
    ADD EVENT sqlserver.sql_batch_completed();
GO
ALTER EVENT SESSION CardinalityFeedback ON SERVER STATE = START;




--Query that needs feedback
SELECT AddressID,
       AddressLine1,
       AddressLine2
FROM Person.ADDRESS
WHERE StateProvinceID = 79
      AND City = N'Redmond';
GO 18


--is feedback even on
SELECT name, value
FROM sys.database_scoped_configurations
WHERE name IN ('CE_FEEDBACK', 'CE_FEEDBACK_FOR_EXPRESSIONS');




SELECT TOP (1500)
       bp.Name,
       bp.ProductNumber,
       bth.Quantity,
       bth.ActualCost
FROM dbo.bigProduct AS bp
    JOIN dbo.bigTransactionHistory2 AS bth
        ON bth.ProductID = bp.ProductID
WHERE bth.Quantity = 10
      AND bth.ActualCost > 357
        ORDER BY bp.Name;
Go 18



--intentionally using SELECT *
SELECT *
FROM dbo.bigTransactionHistory2 AS bth
    JOIN dbo.bigProduct AS bp
        ON bp.ProductID = bth.ProductID
WHERE bth.Quantity = 10
      AND bth.ActualCost > 357;
GO 18


--querying the feedback information
select qspf.*,cast(qsp.query_plan as XML),qsqt.query_sql_text, qsq.query_id
from sys.query_store_plan_feedback as qspf
join sys.query_store_plan as qsp
    on qspf.plan_id = qsp.plan_id
join sys.query_store_query as qsq
    on qsp.query_id = qsq.query_id
join sys.query_store_query_text as qsqt
on qsq.query_text_id = qsqt.query_text_id



--to disable it
ALTER DATABASE SCOPED CONFIGURATION SET
CE_FEEDBACK = OFF;



--to clean them out
--528
--531
--532
DECLARE @query_id bigint = 532;

EXEC sys.sp_query_store_clear_hints @query_id = @query_id;
exec sys.sp_query_store_remove_query @query_id = @query_id;





--Optimized locking
--Key locking
use master;
GO
ALTER DATABASE AdventureWorks SET ACCELERATED_DATABASE_RECOVERY = ON;
ALTER DATABASE AdventureWorks SET OPTIMIZED_LOCKING = ON;
use AdventureWorks;
go  



BEGIN TRAN;
DELETE Production.ProductCostHistory
WHERE StandardCost < 50;
SELECT dtl.request_session_id,
       dtl.resource_database_id,
       dtl.resource_associated_entity_id,
       dtl.resource_type,
       dtl.resource_description,
       dtl.request_mode,
       dtl.request_status
FROM sys.dm_tran_locks AS dtl
WHERE dtl.request_session_id = @@SPID;
ROLLBACK;




--lock if qualified
--if needed, run from a different session connected to master db
--kill it all
ALTER DATABASE AdventureWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AdventureWorks SET OPTIMIZED_LOCKING = OFF;
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT OFF;
ALTER DATABASE AdventureWorks SET MULTI_USER;
--turn it all back on
ALTER DATABASE AdventureWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AdventureWorks SET OPTIMIZED_LOCKING = ON;
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE AdventureWorks SET MULTI_USER;



--Setup
DROP TABLE IF EXISTS dbo.LAQTest;
GO
CREATE TABLE dbo.LAQTest
(
    LAQID INT,
    LAQValue VARCHAR(25)
);
GO
INSERT INTO dbo.LAQTest
(
    LAQID,
    LAQValue
)
VALUES
(1, 'Value 1'),
(2, 'Value 2'),
(3, 'Value 3');

--Run from 1st connection
BEGIN TRAN
UPDATE dbo.LAQTest
SET LAQValue = 'Value 1a'
WHERE LAQID = 1;
--rollback

--Run from 2nd connection
BEGIN TRAN
UPDATE dbo.LAQTest
SET LAQValue = 'Value 2a'
WHERE LAQID = 2;


--don't forget, rolllback before proceeding to the next step


--Time boxed extended events
CREATE EVENT SESSION [TimeBoxedSession] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    WHERE ([sqlserver].[database_name]=N'AdventureWorks'))
with (MAX_DURATION=1 MINUTES);
GO
ALTER EVENT SESSION [TimeBoxedSession] ON SERVER STATE = START;




--clean up
drop event session [TimeBoxedSession] on server;




--ABORT_QUERY_EXECUTION 


select * from sales.SalesOrderHeader;



select qsq.query_id from sys.query_store_query as qsq
join sys.query_store_query_text as qsqt
on qsq.query_text_id = qsqt.query_text_id
where qsqt.query_sql_text like '%select * from sales.SalesOrderHeader%';


exec sys.sp_query_store_set_hints @query_id = 545, @hints = N'OPTION (USE HINT (''ABORT_QUERY_EXECUTION''))';

exec sys.sp_query_store_clear_hints @query_id = 545;


