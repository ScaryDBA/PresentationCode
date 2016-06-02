--Are you my daddy?
WITH       cte_TestRecs
                AS  (
                    SELECT      1000 AS TestField1
                    ,           1 AS IsEven
                    UNION ALL
                    SELECT      TestField1 + 1
                    ,           TestField1 % 2
                    FROM        cte_TestRecs
                    WHERE       TestField1 < 1100
                    )
,           cte_Filter
                AS  (
                    SELECT      TestField1 AS EvenField
                    FROM        cte_TestRecs
                    WHERE       IsEven = 1
                    )

SELECT      *
FROM        cte_TestRecs
WHERE       TestField1 NOT IN   (
                                /*  This is the part that should fail because TestField1 was aliased in 
                                    the CTE. Running the query like this will NOT return any records; nor 
                                    will it give you an error stating an invalid column name. Changing 
                                    this to EvenField will return a recordset as expected.
                                */
                                SELECT      cte_Filter.TestField1
                                FROM        cte_Filter
                                )



--Crystaline Structures

CREATE FUNCTION dbo.SalesInfo ( )
RETURNS @return_variable TABLE
    (
      SalesOrderID INT ,
      OrderDate DATETIME ,
      SalesPersonID INT ,
      PurchaseOrderNumber dbo.OrderNumber ,
      AccountNumber dbo.AccountNumber ,
      ShippingCity NVARCHAR(30)
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                ( SalesOrderID ,
                  OrderDate ,
                  SalesPersonID ,
                  PurchaseOrderNumber ,
                  AccountNumber ,
                  ShippingCity
                )
                SELECT  soh.SalesOrderID ,
                        soh.OrderDate ,
                        soh.SalesPersonID ,
                        soh.PurchaseOrderNumber ,
                        soh.AccountNumber ,
                        a.City
                FROM    Sales.SalesOrderHeader AS soh
                        JOIN Person.Address AS a ON soh.ShipToAddressID = a.AddressID ;
        RETURN ;
    END ;


CREATE FUNCTION dbo.SalesDetails ( )
RETURNS @return_variable TABLE
    (
      SalesOrderID INT ,
      SalesOrderDetailID INT ,
      OrderQty SMALLINT ,
      UnitPrice MONEY
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                ( SalesOrderID ,
                  SalesOrderDetailId ,
                  OrderQty ,
                  UnitPrice
                )
                SELECT  sod.SalesOrderID ,
                        sod.SalesOrderDetailID ,
                        sod.OrderQty ,
                        sod.UnitPrice
                FROM    Sales.SalesOrderDetail AS sod ;
        RETURN ;
    END ;



CREATE FUNCTION dbo.CombinedSalesInfo ( )
RETURNS @return_variable TABLE
    (
      SalesPersonID INT ,
      ShippingCity NVARCHAR(30) ,
      OrderDate DATETIME ,
      PurchaseOrderNumber dbo.OrderNumber ,
      AccountNumber dbo.AccountNumber ,
      OrderQty SMALLINT ,
      UnitPrice MONEY
    )
AS 
    BEGIN;
        INSERT  INTO @return_variable
                ( SalesPersonId ,
                  ShippingCity ,
                  OrderDate ,
                  PurchaseOrderNumber ,
                  AccountNumber ,
                  OrderQty ,
                  UnitPrice
                )
                SELECT  si.SalesPersonID ,
                        si.ShippingCity ,
                        si.OrderDate ,
                        si.PurchaseOrderNumber ,
                        si.AccountNumber ,
                        sd.OrderQty ,
                        sd.UnitPrice
                FROM    dbo.SalesInfo() AS si
                        JOIN dbo.SalesDetails() AS sd 
                        ON si.SalesOrderID = sd.SalesOrderID ;
        RETURN ;
    END ;



SELECT  csi.OrderDate ,
        csi.PurchaseOrderNumber ,
        csi.AccountNumber ,
        csi.OrderQty ,
        csi.UnitPrice
FROM    dbo.CombinedSalesInfo() AS csi
WHERE   csi.SalesPersonID = 277
        AND csi.ShippingCity = 'Odessa' ;










SELECT  soh.OrderDate ,
        soh.PurchaseOrderNumber ,
        soh.AccountNumber ,
        sod.OrderQty ,
        sod.UnitPrice
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Person.Address AS ba ON soh.BillToAddressID = ba.AddressID
        JOIN Person.Address AS sa ON soh.ShipToAddressID = sa.AddressID
WHERE   soh.SalesPersonID = 277
        AND sa.City = 'Odessa' ;








-- I want everything and I want it now

SELECT  sod.SalesOrderDetailID
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID ;













SELECT  sod.SalesOrderDetailID
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE   soh.SalesOrderID = 58707 ;











-- The Query Czar
SELECT  s.[Name] AS StoreName ,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN sales.SalesPerson AS sp ON s.SalesPersonID = sp.BusinessEntityID
        JOIN HumanResources.Employee AS e ON sp.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
        


SELECT  s.[Name] AS StoreName ,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        INNER LOOP JOIN sales.SalesPerson AS sp ON s.SalesPersonID = sp.BusinessEntityID
        JOIN HumanResources.Employee AS e ON sp.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID

       

SELECT  s.[Name] AS StoreName ,
        p.LastName + ', ' + p.FirstName
FROM    Sales.Store AS s
        JOIN sales.SalesPerson AS sp ON s.SalesPersonID = sp.BusinessEntityID
        JOIN HumanResources.Employee AS e ON sp.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
OPTION  ( LOOP JOIN )







-- Query Czar2

SELECT  *
FROM    Purchasing.PurchaseOrderHeader AS poh
WHERE   poh.PurchaseOrderID * 2 = 3400






SELECT  *
FROM    Purchasing.PurchaseOrderHeader AS poh WITH ( INDEX ( PK_PurchaseOrderHeader_PurchaseOrderID ) )
WHERE   poh.PurchaseOrderID * 2 = 3400








SELECT *
FROM Purchasing.PurchaseOrderHeader poh
WHERE PurchaseOrderID = 3400/2







-- I Saw a Man Who wasn't there
SELECT  AddressID ,
        AddressLine1 ,
        AddressLine2
FROM    Person.Address
WHERE   AddressLine2 = NULL ;





SELECT  AddressID ,
        AddressLine1 ,
        AddressLine2
FROM    Person.Address
WHERE   NOT ( AddressLine2 = NULL ) ;






SELECT  AddressID ,
        AddressLine1 ,
        AddressLine2
FROM    Person.Address
WHERE   AddressLine2 IS NOT NULL ;






CREATE INDEX ixTest ON Person.Address(AddressLine2)
INCLUDE (AddressLine1);

SELECT  AddressID ,
        AddressLine1 ,
        AddressLine2
FROM    Person.Address
WHERE   AddressLine2 IS NOT NULL ;






CREATE INDEX ixTest ON Person.Address(AddressLine2)
INCLUDE (AddressLine1)
WHERE AddressLine2 IS NOT NULL
WITH (DROP_EXISTING = ON);

SELECT  AddressID ,
        AddressLine1 ,
        AddressLine2
FROM    Person.Address
WHERE   AddressLine2 IS NOT NULL ;






DROP INDEX Person.Address.ixTest;










-- RBAR

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















--Indexes, we don't need no stinking indexes

SELECT  soh.SalesOrderID
FROM    Sales.SalesOrderHeader AS soh
WHERE   LEFT(soh.SalesOrderNumber, 4) = 'SO62' ;










SELECT  soh.SalesOrderID
FROM    Sales.SalesOrderHeader AS soh
WHERE   soh.SalesOrderNumber LIKE 'SO62%' ;
















-- I'll huff and I'll puff

CREATE TABLE dbo.#Temp
    (
      SalesOrderId INT ,
      ShipDate DATETIME
    ) ;

INSERT  INTO dbo.#Temp
        ( SalesOrderId ,
          ShipDate
        )
        SELECT  soh.SalesOrderId ,
                soh.ShipDate
        FROM    Sales.SalesOrderHeader AS soh
        WHERE   soh.ShipDate BETWEEN '9/6/2002' AND '9/7/2002' ;

SELECT  t.SalesOrderId ,
        t.ShipDate ,
        sod.CarrierTrackingNumber
FROM    dbo.#Temp AS t
        JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = t.SalesOrderId ;

DROP TABLE dbo.#Temp ;







DECLARE @Temp TABLE
    (
      SalesOrderId INT ,
      ShipDate DATETIME
    ) ;

INSERT  INTO @Temp
        ( SalesOrderId ,
          ShipDate
        )
        SELECT  soh.SalesOrderId ,
                soh.ShipDate
        FROM    Sales.SalesOrderHeader AS soh
        WHERE   soh.ShipDate BETWEEN '9/6/2002' AND '9/7/2002' ;

SELECT  t.SalesOrderId ,
        t.ShipDate ,
        sod.CarrierTrackingNumber
FROM    @Temp AS t
        JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = t.SalesOrderId ;










WITH    cteTemp ( SalesOrderID, ShipDate )
          AS ( SELECT   soh.SalesOrderId ,
                        soh.ShipDate
               FROM     Sales.SalesOrderHeader AS soh
               WHERE    soh.ShipDate BETWEEN '9/6/2002' AND '9/7/2002'
             )
    SELECT  t.SalesOrderId ,
            t.ShipDate ,
            sod.CarrierTrackingNumber
    FROM    cteTemp AS t
            JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = t.SalesOrderId ;














-- Statistics
SELECT  *
INTO    dbo.NewOrders
FROM    Sales.SalesOrderDetail AS sod
GO
CREATE INDEX IX_NewOrders_ProductID ON NewOrders(ProductID)
GO

ALTER DATABASE AdventureWorks2008
SET AUTO_UPDATE_STATISTICS OFF;


SET STATISTICS XML ON ;
GO
SELECT  n.OrderQty ,
        n.CarrierTrackingNumber
FROM    dbo.NewOrders AS n
WHERE   ProductID = 897 ;
GO
SET STATISTICS XML OFF ;
GO

BEGIN TRAN ;
UPDATE  dbo.NewOrders
SET     ProductID = 897
WHERE   ProductID BETWEEN 800 AND 900 ;
GO

--UPDATE STATISTICS dbo.NewOrders;

SET STATISTICS XML ON ;
GO
SELECT  n.OrderQty ,
        n.CarrierTrackingNumber
FROM    dbo.NewOrders AS n
WHERE   ProductID = 897 ;
ROLLBACK TRAN ; 
GO
SET STATISTICS XML OFF ;
GO


ALTER DATABASE AdventureWorks2008
SET AUTO_UPDATE_STATISTICS ON;

DROP TABLE dbo.NewOrders ;
