


DBCC SHOW_STATISTICS('Sales.SalesOrderDetail',[PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID]);





DBCC SHOW_STATISTICS('Person.Address',[_WA_Sys_00000004_164452B1]);















SELECT  th.TransactionID ,
        th.ProductID ,
        p.Name
FROM    Production.TransactionHistory AS th
        JOIN Production.Product AS p ON p.ProductID = th.ProductID
WHERE   th.ProductID BETWEEN 400 AND 405;



ALTER DATABASE AdventureWorks2014
SET AUTO_UPDATE_STATISTICS OFF;
GO

BEGIN TRAN

UPDATE  Production.TransactionHistory
SET     ProductID = 404
WHERE   ProductID NOT BETWEEN 400 AND 405;

SELECT  th.TransactionID ,
        th.ProductID ,
        p.Name
FROM    Production.TransactionHistory AS th
        JOIN Production.Product AS p ON p.ProductID = th.ProductID
WHERE   th.ProductID BETWEEN 400 AND 405;

UPDATE STATISTICS Production.TransactionHistory;

SELECT  th.TransactionID ,
        th.ProductID ,
        p.Name
FROM    Production.TransactionHistory AS th
        JOIN Production.Product AS p ON p.ProductID = th.ProductID
WHERE   th.ProductID BETWEEN 400 AND 405;

ROLLBACK TRAN
GO

ALTER DATABASE AdventureWorks2014 
SET AUTO_UPDATE_STATISTICS ON;
GO

