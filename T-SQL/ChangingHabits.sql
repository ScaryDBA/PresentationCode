--ORM
--Repeating, nothing wrong with ORMs, just with some code smells


SELECT  soh.OrderDate,
        sod.OrderQty,
        sod.LineTotal
FROM    Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
WHERE   soh.SalesOrderID IN (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10,
                             @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18,
                             @p19, @p20, @p21, @p22, @p23, @p24, @p25, @p26,
                             @p27, @p28, @p29, @p30, @p31, @p32, @p33, @p34,
                             @p35, @p36, @p37, @p38, @p39, @p40, @p41, @p42,
                             @p43, @p44, @p45, @p46, @p47, @p48, @p49, @p50,
                             @p51, @p52, @p53, @p54, @p55, @p56, @p57, @p58,
                             @p59, @p60, @p61, @p62, @p63, @p64, @p65, @p66,
                             @p67, @p68, @p69, @p70, @p71, @p72, @p73, @p74,
                             @p75, @p76, @p77, @p78, @p79, @p80, @p81, @p82,
                             @p83, @p84, @p85, @p86, @p87, @p88, @p89, @p90,
                             @p91, @p92, @p93, @p94, @p95, @p96, @p97, @p98,
                             @p99);




DECLARE @p1 INT = 1, @p2 INT = 2,@p3 INT = 3,@p4 INT = 4,@p5 INT = 5,
    @p6 INT = 6,@p7 INT = 7,@p8 INT = 8,@p9 INT = 9,
    @p10 INT = 10,@p11 INT = 11,@p12 INT = 12,@p13 INT = 13,
    @p14 INT = 14,@p15 INT = 15,@p16 INT = 16,@p17 INT = 17,
    @p18 INT = 18,@p19 INT = 19,@p20 INT = 20,@p21 INT = 21,
    @p22 INT = 22,@p23 INT = 23,@p24 INT = 24,@p25 INT = 25,
    @p26 INT = 26,@p27 INT = 27,@p28 INT = 28,@p29 INT = 29,
    @p30 INT = 30,@p31 INT = 31,@p32 INT = 32,@p33 INT = 33,
    @p34 INT = 34,@p35 INT = 35,@p36 INT = 36,@p37 INT = 37,
    @p38 INT = 38,@p39 INT = 39,@p40 INT = 40,@p41 INT = 41,
    @p42 INT = 42,@p43 INT = 43,@p44 INT = 44,@p45 INT = 45,
    @p46 INT = 46,@p47 INT = 47,@p48 INT = 48,@p49 INT = 49,
	@p50 INT = 50,@p51 INT = 51,@p52 INT = 52,@p53 INT = 53,
	@p54 INT = 54,@p55 INT = 55,@p56 INT = 56,@p57 INT = 57,
    @p58 INT = 58,@p59 INT = 59,@p60 INT = 60,@p61 INT = 61,
    @p62 INT = 62,@p63 INT = 63,@p64 INT = 64,@p65 INT = 65,
    @p66 INT = 66,@p67 INT = 67,@p68 INT = 68,@p69 INT = 69,
    @p70 INT = 70,@p71 INT = 71,@p72 INT = 72,@p73 INT = 73,
    @p74 INT = 74,@p75 INT = 75,@p76 INT = 76,@p77 INT = 77,
    @p78 INT = 78,@p79 INT = 79,@p80 INT = 80,@p81 INT = 81,
    @p82 INT = 82,@p83 INT = 83,@p84 INT = 84,@p85 INT = 85,
    @p86 INT = 86,@p87 INT = 87,@p88 INT = 88,@p89 INT = 89,
    @p90 INT = 90,@p91 INT = 91,@p92 INT = 92,@p93 INT = 93,
    @p94 INT = 94,@p95 INT = 95,@p96 INT = 96,@p97 INT = 97,
    @p98 INT = 98,@p99 INT = 99;

SELECT  soh.OrderDate,
        sod.OrderQty,
        sod.LineTotal
FROM    Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
WHERE   soh.SalesOrderID IN (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10,
                             @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18,
                             @p19, @p20, @p21, @p22, @p23, @p24, @p25, @p26,
                             @p27, @p28, @p29, @p30, @p31, @p32, @p33, @p34,
                             @p35, @p36, @p37, @p38, @p39, @p40, @p41, @p42,
                             @p43, @p44, @p45, @p46, @p47, @p48, @p49, @p50,
                             @p51, @p52, @p53, @p54, @p55, @p56, @p57, @p58,
                             @p59, @p60, @p61, @p62, @p63, @p64, @p65, @p66,
                             @p67, @p68, @p69, @p70, @p71, @p72, @p73, @p74,
                             @p75, @p76, @p77, @p78, @p79, @p80, @p81, @p82,
                             @p83, @p84, @p85, @p86, @p87, @p88, @p89, @p90,
                             @p91, @p92, @p93, @p94, @p95, @p96, @p97, @p98,
                             @p99);







CREATE TYPE SalesOrderList AS TABLE
(SalesOrderID INT);

CREATE PROCEDURE dbo.SalesOrderList (
     @SalesOrderList dbo.SalesOrderList READONLY
    )
AS
SELECT  soh.OrderDate,
        sod.OrderQty,
        sod.LineTotal
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    @SalesOrderList AS sol
        ON sod.SalesOrderID = sol.SalesOrderID;
GO




DECLARE @MySalesOrderList AS dbo.SalesOrderList

WITH    Nums
          AS (SELECT TOP (99)
                        ROW_NUMBER() OVER (ORDER BY (SELECT 1
                                                    )) AS n
              FROM      master.sys.All_Columns ac1
                        CROSS JOIN master.sys.All_Columns ac2
             )
INSERT @MySalesOrderList
        (SalesOrderID)
SELECT n FROM Nums;


EXEC dbo.SalesOrderList @SalesOrderList = @MySalesOrderList;












--readability
SELECT * from Person.Address a where City = 'Somevalue'



















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
AS 
/*Query uses productid, creditcardid & specialofferid
to retrieve a few pieces of information important for
CEO reports
*/

--TRY/CATCH is here as an example, not needed for a SELECT statement normally
BEGIN TRY
    SELECT  sod.OrderQty,
            sod.UnitPrice,
            soh.Comment,
            soh.AccountNumber
    FROM    Sales.SalesOrderDetail AS sod
    JOIN    Sales.SalesOrderHeader AS soh
            ON sod.SalesOrderID = soh.SalesOrderID
    WHERE   sod.ProductID = @ProductID
            AND soh.CreditCardID = @CredCardID
            AND sod.SpecialOfferID = @SpecialOfferID;
END TRY
BEGIN CATCH
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR); 
    PRINT 'Error Message: ' + ERROR_MESSAGE(); 
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR); 
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR); 
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR); 
    PRINT 'Error Proc: ' + ERROR_PROCEDURE(); 
END CATCH


	













--Data type conversions

SELECT  e.BusinessEntityID,
        e.NationalIDNumber
FROM    HumanResources.Employee AS e
WHERE   e.NationalIDNumber = 112457891;












SELECT  e.BusinessEntityID,
        e.NationalIDNumber
FROM    HumanResources.Employee AS e
WHERE   e.NationalIDNumber = '112457891';











--commands in comparisons
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















