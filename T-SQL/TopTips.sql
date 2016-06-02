Select * from Person.Address a where City = 'Somevalue'



















select  a.SalesOrderID,SalesOrderDetailID,CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount,LineTotal,a.rowguid,a.ModifiedDate,b.SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,OnlineOrderFlag,SalesOrderNumber,PurchaseOrderNumber,AccountNumber,CustomerID,SalesPersonID,TerritoryID,BillToAddressID,ShipToAddressID,ShipMethodID,CreditCardID,CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,Freight,TotalDue,Comment,b.rowguid,b.ModifiedDate
FROM Sales.SalesOrderDetail a Inner join Sales.SalesOrderHeader AS b ON a.SalesOrderID = b.SalesOrderID
order by 8, 11


















CREATE PROCEDURE sp_mybadproc (@id1 int, @id2 int, @id3 int) AS
SELECT  a.SalesOrderID,SalesOrderDetailID,CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount,LineTotal,a.rowguid,a.ModifiedDate,b.SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,OnlineOrderFlag,SalesOrderNumber,PurchaseOrderNumber,AccountNumber,CustomerID,SalesPersonID,TerritoryID,BillToAddressID,ShipToAddressID,ShipMethodID,CreditCardID,CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,Freight,TotalDue,Comment,b.rowguid,b.ModifiedDate
FROM Sales.SalesOrderDetail AS a JOIN Sales.SalesOrderHeader AS b ON a.SalesOrderID = b.SalesOrderID
WHERE a.ProductID = @id1 AND b.CreditCardID = @id2 AND a.SpecialOfferID = @id3
















CREATE PROCEDURE dbo.SalesOrderInfoByProductCreditCardSpecial (
     @ProductID INT,
     @CreditCardID INT,
     @SpecialOfferID INT
    )
AS /*Query uses productid, creditcardid & specialofferid
to retrieve a few pieces of information important for
CEO reports
*/
    BEGIN TRY
        SELECT  sod.OrderQty,
                sod.UnitPrice,
                soh.Comment,
                soh.AccountNumber
        FROM    Sales.SalesOrderDetail AS sod
                JOIN Sales.SalesOrderHeader AS soh
                ON sod.SalesOrderID = soh.SalesOrderID
        WHERE   sod.ProductID = @ProductID
                AND soh.CreditCardID = @CredCardID
                AND sod.SpecialOfferID = @SpecialOfferID ;
    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR) ; 
        PRINT 'Error Message: ' + ERROR_MESSAGE() ; 
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR) ; 
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR) ; 
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR) ; 
        PRINT 'Error Proc: ' + ERROR_PROCEDURE() ; 

    END CATCH


	


--performance



--Data type conversions

SELECT  e.BusinessEntityID,
        e.NationalIDNumber
FROM    HumanResources.Employee AS e
WHERE   e.NationalIDNumber = 112457891;












SELECT  e.BusinessEntityID,
        e.NationalIDNumber
FROM    HumanResources.Employee AS e
WHERE   e.NationalIDNumber = '112457891';











--functions in comparisons
SELECT  a.AddressLine1,
        a.AddressLine2,
        a.City,
        a.StateProvinceID
FROM    Person.Address AS a
WHERE   '4444' = LEFT(a.AddressLine1, 4) ;






--instead
SELECT  a.AddressLine1,
        a.AddressLine2,
        a.City,
        a.StateProvinceID
FROM    Person.Address AS a
WHERE   a.AddressLine1 LIKE '4444%' ;









--improper use of functions
CREATE FUNCTION dbo.SalesInfo ()
RETURNS @return_variable TABLE
    (
     SalesOrderID INT,
     OrderDate DATETIME,
     SalesPersonID INT,
     PurchaseOrderNumber dbo.OrderNumber,
     AccountNumber dbo.AccountNumber,
     ShippingCity NVARCHAR(30)
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                (SalesOrderID,
                 OrderDate,
                 SalesPersonID,
                 PurchaseOrderNumber,
                 AccountNumber,
                 ShippingCity
                )
                SELECT  soh.SalesOrderID,
                        soh.OrderDate,
                        soh.SalesPersonID,
                        soh.PurchaseOrderNumber,
                        soh.AccountNumber,
                        a.City
                FROM    Sales.SalesOrderHeader AS soh
                        JOIN Person.Address AS a
                        ON soh.ShipToAddressID = a.AddressID ;
        RETURN ;
    END ;
GO

CREATE FUNCTION dbo.SalesDetails ()
RETURNS @return_variable TABLE
    (
     SalesOrderID INT,
     SalesOrderDetailID INT,
     OrderQty SMALLINT,
     UnitPrice MONEY
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                (SalesOrderID,
                 SalesOrderDetailId,
                 OrderQty,
                 UnitPrice
                )
                SELECT  sod.SalesOrderID,
                        sod.SalesOrderDetailID,
                        sod.OrderQty,
                        sod.UnitPrice
                FROM    Sales.SalesOrderDetail AS sod ;
        RETURN ;
    END ;
GO


CREATE FUNCTION dbo.CombinedSalesInfo ()
RETURNS @return_variable TABLE
    (
     SalesPersonID INT,
     ShippingCity NVARCHAR(30),
     OrderDate DATETIME,
     PurchaseOrderNumber dbo.OrderNumber,
     AccountNumber dbo.AccountNumber,
     OrderQty SMALLINT,
     UnitPrice MONEY
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                (SalesPersonId,
                 ShippingCity,
                 OrderDate,
                 PurchaseOrderNumber,
                 AccountNumber,
                 OrderQty,
                 UnitPrice
                )
                SELECT  si.SalesPersonID,
                        si.ShippingCity,
                        si.OrderDate,
                        si.PurchaseOrderNumber,
                        si.AccountNumber,
                        sd.OrderQty,
                        sd.UnitPrice
                FROM    dbo.SalesInfo() AS si
                        JOIN dbo.SalesDetails() AS sd
                        ON si.SalesOrderID = sd.SalesOrderID ;
        RETURN ;
    END ;
GO


SELECT  csi.OrderDate,
        csi.PurchaseOrderNumber,
        csi.AccountNumber,
        csi.OrderQty,
        csi.UnitPrice
FROM    dbo.CombinedSalesInfo() AS csi
WHERE   csi.SalesPersonID = 277
        AND csi.ShippingCity = 'Odessa' ;




--what's the plan look like
SELECT  deqp.query_plan,
        dest.text,
        SUBSTRING(dest.text, (deqs.statement_start_offset / 2) + 1,
                  (deqs.statement_end_offset - deqs.statement_start_offset)
                  / 2 + 1) AS actualstatement
FROM    sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE   deqp.objectid = OBJECT_ID('dbo.CombinedSalesInfo')
        OR deqp.objectid = OBJECT_ID('dbo.SalesDetails')
        OR deqp.objectid = OBJECT_ID('dbo.SalesInfo');











--instead
SELECT  soh.OrderDate,
        soh.PurchaseOrderNumber,
        soh.AccountNumber,
        sod.OrderQty,
        sod.UnitPrice
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Person.Address AS ba
        ON soh.BillToAddressID = ba.AddressID
        JOIN Person.Address AS sa
        ON soh.ShipToAddressID = sa.AddressID
WHERE   soh.SalesPersonID = 277
        AND sa.City = 'Odessa' ;
        
        
        



--getting the UDF execution plan
SELECT	deqp.query_plan,
	dest.text,
	SUBSTRING(dest.text, (deqs.statement_start_offset / 2) + 1,
				(deqs.statement_end_offset - deqs.statement_start_offset)
				/ 2 + 1) AS actualstatement
FROM	sys.dm_exec_query_stats AS deqs
	CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
	CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE	deqp.objectid = OBJECT_ID('dbo.SalesDetails');








--Query hints

SELECT  s.[Name] AS StoreName,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
        JOIN HumanResources.Employee AS e
        ON sp.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID
OPTION  (LOOP JOIN);











SELECT  s.[Name] AS StoreName,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN sales.SalesPerson AS sp
        ON s.SalesPersonID = sp.BusinessEntityID
        JOIN HumanResources.Employee AS e
        ON sp.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID;







--query hints 2
SELECT  *
FROM    Purchasing.PurchaseOrderHeader AS poh
WHERE   poh.PurchaseOrderID * 2 = 3400;






SELECT  *
FROM    Purchasing.PurchaseOrderHeader AS poh WITH (INDEX (PK_PurchaseOrderHeader_PurchaseOrderID))
WHERE   poh.PurchaseOrderID * 2 = 3400;








SELECT  *
FROM    Purchasing.PurchaseOrderHeader poh
WHERE   PurchaseOrderID = 3400 / 2;












--recompiles
CREATE PROCEDURE dbo.Interleaved
AS 
    SELECT  *
    INTO    #myTemp
    FROM    Person.AddressType AS at

    SELECT  *
    FROM    #MyTemp ;

    ALTER TABLE #MyTemp ADD ExtraColumn VARCHAR(30) ;

    SELECT  *
    FROM    #MyTemp ;






CREATE PROCEDURE dbo.NonInterleaved
AS 
    SELECT  *
    INTO    #myTemp
    FROM    Person.AddressType AS at

    ALTER TABLE #MyTemp ADD ExtraColumn VARCHAR(30) ;

    SELECT  *
    FROM    #MyTemp ;

	SELECT  *
	FROM    #myTemp AS mt





EXEC dbo.Interleaved ;

EXEC dbo.NonInterleaved ;










--NULLs
SELECT  *
FROM    Person.Address AS a
WHERE   a.AddressLine2 = NULL ;



SELECT  *
FROM    Person.Address AS a
WHERE   a.AddressLine2 IS NULL ;



SELECT  *
FROM    Person.Address AS a
WHERE   a.AddressLine2 IS NOT NULL ;









--RBAR
BEGIN TRANSACTION
DECLARE @Name NVARCHAR(50) ,
    @Color NVARCHAR(15) ,
    @Weight DECIMAL(8, 2) 
DECLARE BigUpdate CURSOR
FOR SELECT  p.[Name]
,p.Color
,p.[Weight]
FROM    Production.Product AS p ;
OPEN BigUpdate ;

FETCH NEXT FROM BigUpdate INTO @Name, @Color, @Weight ;

WHILE @@FETCH_STATUS = 0 
    BEGIN
        IF @Weight < 3 
            BEGIN
                UPDATE  Production.Product
                SET     Color = 'Blue'
                WHERE CURRENT OF BigUpdate
            END

        FETCH NEXT FROM BigUpdate INTO @Name, @Color, @Weight ;

    END
CLOSE BigUpdate ;
DEALLOCATE BigUpdate ;

SELECT  *
FROM    Production.Product AS p
WHERE   Color = 'Blue' ;

ROLLBACK TRANSACTION









BEGIN TRANSACTION
	  
UPDATE  Production.Product
SET     Color = 'BLUE'
WHERE   [Weight] < 3 ;

ROLLBACK TRANSACTION










--Nesting views

CREATE VIEW dbo.SalesInfoView
AS
    SELECT  soh.SalesOrderID,
            soh.OrderDate,
            soh.SalesPersonID,
            soh.PurchaseOrderNumber,
            soh.AccountNumber,
            a.City AS ShippingCity
    FROM    Sales.SalesOrderHeader AS soh
            JOIN Person.Address AS a
            ON soh.ShipToAddressID = a.AddressID ;
GO

CREATE VIEW dbo.SalesDetailsView
AS
    SELECT  sod.SalesOrderID,
            sod.SalesOrderDetailID,
            sod.OrderQty,
            sod.UnitPrice
    FROM    Sales.SalesOrderDetail AS sod ;
GO

CREATE VIEW dbo.CombinedSalesInfoView
AS
    SELECT  si.SalesPersonID,
            si.ShippingCity,
            si.OrderDate,
            si.PurchaseOrderNumber,
            si.AccountNumber,
            sd.OrderQty,
            sd.UnitPrice
    FROM    dbo.SalesInfoView AS si
            JOIN dbo.SalesDetailsView AS sd
            ON si.SalesOrderID = sd.SalesOrderID ;

GO


SELECT  csiv.OrderDate
FROM    CombinedSalesInfoView csiv
WHERE   csiv.SalesPersonID = 277 ;




--instead
SELECT  soh.OrderDate
FROM    Sales.SalesOrderHeader AS soh
WHERE   soh.SalesPersonID = 277 ;















