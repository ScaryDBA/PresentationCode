--table spool
BEGIN TRAN

DELETE  FROM Production.Product
WHERE   ProductID = 3343;

ROLLBACK TRAN












--SET UP
SELECT @@SPID;
--DROP INDEX PurchaseOrderDetailDueDate ON Purchasing.PurchaseOrderDetail



--Query tuning
SELECT  poh.PurchaseOrderID,
        poh.RevisionNumber,
        poh.Status,
        poh.OrderDate,
        poh.ShipDate,
        p.Name AS ProductName,
        pod.DueDate,
        pod.OrderQty,
        pod.LineTotal,
        v.Name AS OrderVendorName,
        pv.AverageLeadTime
FROM    Purchasing.PurchaseOrderHeader AS poh
JOIN    Purchasing.PurchaseOrderDetail AS pod
        ON pod.PurchaseOrderID = poh.PurchaseOrderID
JOIN    Purchasing.ProductVendor AS pv
        ON pv.ProductID = pod.ProductID
JOIN    Purchasing.Vendor AS v
        ON v.BusinessEntityID = poh.VendorID
JOIN    Production.Product AS p
        ON p.ProductID = pod.ProductID
WHERE   pod.DueDate > '8/15/2014';









CREATE NONCLUSTERED INDEX PurchaseOrderDetailDueDate ON Purchasing.PurchaseOrderDetail
(
DueDate ASC
)
INCLUDE (OrderQty,LineTotal,ProductID);









--VIEWS
--Standard view

SELECT  (ve.LastName + ', ' + ve.FirstName) AS EmployeeName,
        ve.Title,
        ve.JobTitle,
        ve.EmailAddress
FROM    HumanResources.vEmployee AS ve
WHERE   ve.City = 'Bellevue';












SELECT  *
FROM    HumanResources.vEmployee AS ve;

















SELECT  *
FROM    HumanResources.vEmployee AS ve
WHERE   ve.City = 'Bellevue';

















--materialized view

SELECT  *
FROM    Production.vProductAndDescription AS vpad;





SELECT  *
FROM    Production.vProductAndDescription AS vpad WITH (NOEXPAND);
















SELECT  sp.StateProvinceID,
        sp.StateProvinceCode,
        sp.IsOnlyStateProvinceFlag,
        sp.Name AS StateProvinceName,
        cr.CountryRegionCode,
        cr.Name AS CountryRegionName
FROM    Person.StateProvince sp
INNER JOIN Person.CountryRegion cr
        ON sp.CountryRegionCode = cr.CountryRegionCode;




SELECT  sp.StateProvinceID,
        sp.StateProvinceCode,
        sp.IsOnlyStateProvinceFlag,
        sp.Name AS StateProvinceName,
        cr.CountryRegionCode,
        cr.Name AS CountryRegionName
FROM    Person.StateProvince sp
INNER JOIN Person.CountryRegion cr
        ON sp.CountryRegionCode = cr.CountryRegionCode
OPTION  (EXPAND VIEWS)












--foreign keys

BEGIN TRANSACTION
INSERT  Person.Address
        (AddressLine1,
         AddressLine2,
         City,
         StateProvinceID,
         PostalCode,
         SpatialLocation,
         rowguid,
         ModifiedDate
        )
VALUES  (N'1313 Mockingbird Lane', -- AddressLine1 - nvarchar(60)
         N'', -- AddressLine2 - nvarchar(60)
         N'Springfield', -- City - nvarchar(30)
         35, -- StateProvinceID - int
         N'90120', -- PostalCode - nvarchar(15)
         (geography::STGeomFromText('POINT(17.4298207 -78.341136)', 4326)), -- SpatialLocation - geography
         NEWID(), -- rowguid - uniqueidentifier
         GETDATE()  -- ModifiedDate - datetime
        );
ROLLBACK






BEGIN TRANSACTION
DELETE  FROM Person.BusinessEntity
WHERE   BusinessEntityID = 42;
ROLLBACK		




BEGIN TRANSACTION
DELETE  FROM Person.BusinessEntity
WHERE   BusinessEntityID = 44442;
ROLLBACK		












--foreign key

SELECT  p.LastName + ',' + p.FirstName AS PersonName
FROM    Person.Address AS a
JOIN    Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
JOIN    Person.BusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
JOIN    Person.Person AS p
        ON be.BusinessEntityID = p.BusinessEntityID;



SELECT  p.LastName + ',' + p.FirstName AS PersonName
FROM    dbo.MyAddress AS a
JOIN    dbo.MyBusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
JOIN    dbo.MyBusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
JOIN    dbo.MyPerson AS p
        ON be.BusinessEntityID = p.BusinessEntityID;





SELECT  *
INTO    dbo.MyAddress
FROM    Person.Address;

SELECT  *
INTO    dbo.MyBusinessEntityAddress
FROM    Person.BusinessEntityAddress;

SELECT  *
INTO    dbo.MyBusinessEntity
FROM    Person.BusinessEntity;

SELECT  *
INTO    dbo.MyPerson
FROM    Person.Person;








SELECT  p.LastName + ',' + p.FirstName AS PersonName
FROM    dbo.MyAddress AS a
JOIN    dbo.MyBusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
JOIN    dbo.MyBusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
JOIN    dbo.MyPerson AS p
        ON be.BusinessEntityID = p.BusinessEntityID;







ALTER TABLE dbo.MyAddress ADD  CONSTRAINT PK_MyAddress_AddressID PRIMARY KEY CLUSTERED
(
AddressID ASC
);

CREATE NONCLUSTERED INDEX IX_MyBusinessEntityAddress_AddressID ON dbo.MyBusinessEntityAddress
(
AddressID ASC
);

ALTER TABLE dbo.MyBusinessEntityAddress ADD  CONSTRAINT PK_MyBusinessEntityAddress_BusinessEntityID_AddressID_AddressTypeID PRIMARY KEY CLUSTERED
(
BusinessEntityID ASC,
AddressID ASC,
AddressTypeID ASC
);

ALTER TABLE dbo.MyBusinessEntity ADD  CONSTRAINT PK_MyBusinessEntity_BusinessEntityID PRIMARY KEY CLUSTERED
(
BusinessEntityID ASC
);

ALTER TABLE dbo.MyPerson ADD  CONSTRAINT PK_Person_BusinessEntityID PRIMARY KEY CLUSTERED
(
BusinessEntityID ASC
);



SELECT  p.LastName + ',' + p.FirstName AS PersonName
FROM    dbo.MyAddress AS a
JOIN    dbo.MyBusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
JOIN    dbo.MyBusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
JOIN    dbo.MyPerson AS p
        ON be.BusinessEntityID = p.BusinessEntityID;





SELECT  p.LastName + ', ' + p.FirstName AS PersonName
FROM    Person.Address AS a
JOIN    Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
JOIN    Person.BusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
JOIN    Person.Person AS p
        ON be.BusinessEntityID = p.BusinessEntityID
WHERE   p.LastName LIKE 'Ran%';

SELECT  p.LastName + ', ' + p.FirstName AS PersonName
FROM    dbo.MyAddress AS a
JOIN    dbo.MyBusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
JOIN    dbo.MyBusinessEntity AS be
        ON bea.BusinessEntityID = be.BusinessEntityID
JOIN    dbo.MyPerson AS p
        ON be.BusinessEntityID = p.BusinessEntityID
WHERE   p.LastName LIKE 'Ran%';





--1
SELECT  p.LastName + ',' + p.FirstName AS PersonName
FROM person.BusinessEntityAddress AS bea
JOIN Person.Person AS p
ON p.BusinessEntityID = bea.BusinessEntityID;
GO
--2
SELECT  p.LastName + ',' + p.FirstName AS PersonName
FROM dbo.MyBusinessEntityAddress AS bea
JOIN dbo.MyPerson AS p
ON p.BusinessEntityID = bea.BusinessEntityID;
GO





--calculated columns

SELECT  wo.OrderQty,
        wo.StockedQty,
        wo.ScrappedQty,
        sr.Name AS ScrapReason,
        p.Name AS ProductName,
        p.ProductID
FROM    Production.WorkOrder AS wo
JOIN    Production.Product AS p
        ON p.ProductID = wo.ProductID
JOIN    Production.ScrapReason AS sr
        ON sr.ScrapReasonID = wo.ScrapReasonID
WHERE   p.ProductID = 904;


--persisted columns needs to be added here







--Constraint



BEGIN TRANSACTION
INSERT  Purchasing.ShipMethod
        (Name,
         ShipBase,
         ShipRate,
         rowguid,
         ModifiedDate
        )
VALUES  ('High Speed Drone', -- Name - Name
         42.0, -- ShipBase - money
         0, -- ShipRate - money
         NEWID(), -- rowguid - uniqueidentifier
         GETDATE()  -- ModifiedDate - datetime
        );
ROLLBACK TRANSACTION




BEGIN TRANSACTION
INSERT  Purchasing.ShipMethod
        (Name,
         ShipBase,
         ShipRate,
         rowguid,
         ModifiedDate
        )
VALUES  ('High Speed Drone', -- Name - Name
         0, -- ShipBase - money
         0.1, -- ShipRate - money
         NEWID(), -- rowguid - uniqueidentifier
         GETDATE()  -- ModifiedDate - datetime
        );
ROLLBACK TRANSACTION


--show the defaults
ALTER TABLE Purchasing.ShipMethod ADD  CONSTRAINT DF_ShipMethod_ShipBase  DEFAULT ((0.00)) FOR ShipBase

ALTER TABLE Purchasing.ShipMethod ADD  CONSTRAINT DF_ShipMethod_ShipRate  DEFAULT ((0.00)) FOR ShipRate





BEGIN TRANSACTION
INSERT  Purchasing.ShipMethod
        (Name)
VALUES  ('High Speed Drone' -- Name - Name
         );
ROLLBACK TRANSACTION




ALTER TABLE Purchasing.ShipMethod  WITH CHECK ADD  CONSTRAINT CK_ShipMethod_ShipBase CHECK  ((ShipBase>(0.00)));


ALTER TABLE Purchasing.ShipMethod  DROP  CONSTRAINT CK_ShipMethod_ShipBase 


SELECT * FROM Sales.SalesOrderDetail AS soh

BEGIN TRAN
INSERT Sales.SalesOrderDetail
        (SalesOrderID,
         CarrierTrackingNumber,
         OrderQty,
         ProductID,
         SpecialOfferID,
         UnitPrice,
         UnitPriceDiscount,
         rowguid,
         ModifiedDate
        )
VALUES  (60176, -- SalesOrderID - int
         N'XYZ123', -- CarrierTrackingNumber - nvarchar(25)
         1, -- OrderQty - smallint
         873, -- ProductID - int
         1, -- SpecialOfferID - int
         -22, -- UnitPrice - money
         0.0, -- UnitPriceDiscount - money
         NEWID(), -- rowguid - uniqueidentifier
         GETDATE()  -- ModifiedDate - datetime
        );
ROLLBACK TRAN


--constraints and SELECT
SELECT  soh.OrderDate,
        soh.ShipDate,
        sod.OrderQty,
        sod.UnitPrice,
        p.Name AS ProductName
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   p.Name = 'Water Bottle - 30 oz.';



SELECT  sod.SalesOrderID,
        sod.SalesOrderDetailID,
        sod.CarrierTrackingNumber,
        sod.OrderQty,
        sod.ProductID,
        sod.SpecialOfferID,
        sod.UnitPrice,
        sod.UnitPriceDiscount,
        sod.LineTotal,
        sod.rowguid,
        sod.ModifiedDate
FROM    Sales.SalesOrderDetail AS sod;






SELECT  soh.OrderDate,
        soh.ShipDate,
        sod.OrderQty,
        sod.UnitPrice,
        p.Name AS ProductName
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   p.Name = 'Water Bottle - 30 oz.'


SELECT  soh.OrderDate,
        soh.ShipDate,
        sod.OrderQty,
        sod.UnitPrice,
        p.Name AS ProductName
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   p.Name = 'Water Bottle - 30 oz.'
        AND sod.UnitPrice = $0.0;











ALTER TABLE Sales.SalesOrderDetail DROP CONSTRAINT CK_SalesOrderDetail_UnitPrice




SELECT  soh.OrderDate,
        soh.ShipDate,
        sod.OrderQty,
        sod.UnitPrice,
        p.Name AS ProductName
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   p.Name = 'Water Bottle - 30 oz.'
        AND sod.UnitPrice < $0.0;



ALTER TABLE Sales.SalesOrderDetail WITH NOCHECK ADD  CONSTRAINT CK_SalesOrderDetail_UnitPrice CHECK  ((UnitPrice>=(0.00)))
GO






SELECT  soh.OrderDate,
        soh.ShipDate,
        sod.OrderQty,
        sod.UnitPrice,
        p.Name AS ProductName
FROM    Sales.SalesOrderHeader AS soh
JOIN    Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
JOIN    Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE   p.Name = 'Water Bottle - 30 oz.'
        AND sod.UnitPrice < $0.0;





--cleanup
ALTER TABLE Sales.SalesOrderDetail DROP CONSTRAINT CK_SalesOrderDetail_UnitPrice
GO
ALTER TABLE Sales.SalesOrderDetail  WITH CHECK ADD  CONSTRAINT CK_SalesOrderDetail_UnitPrice CHECK  ((UnitPrice>=(0.00)))
GO
EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Check constraint [UnitPrice] >= (0.00)',
    @level0type = N'SCHEMA',
    @level0name = N'Sales',
    @level1type = N'TABLE',
    @level1name = N'SalesOrderDetail',
    @level2type = N'CONSTRAINT',
    @level2name = N'CK_SalesOrderDetail_UnitPrice'
GO


--try this with zero rows







--merge

create PROCEDURE dbo.MergeSalesOrderDetail (
     @SalesOrderID INT,
     @SalesOrderDetailID INT NULL,
     @CarrierTrackingNumber VARCHAR(25),
     @OrderQty SMALLINT,
     @ProductID INT,
     @SpecialOfferID INT,
     @UnitPrice MONEY,
     @UnitPriceDiscount MONEY
    )
AS
--comment
MERGE Sales.SalesOrderDetail AS target
USING
    (SELECT @SalesOrderID,
            @SalesOrderDetailID,
            @CarrierTrackingNumber,
            @OrderQty,
            @ProductID,
            @SpecialOfferID,
            @UnitPrice,
            @UnitPriceDiscount
    ) AS source (SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
                 OrderQty, ProductID, SpecailOfferID, UnitPrice,
                 UnitPriceDiscount)
ON (source.SalesOrderID = target.SalesOrderID
    AND source.SalesOrderDetailID = target.SalesOrderDetailID
   )
WHEN NOT MATCHED THEN
    INSERT (SalesOrderID,
            CarrierTrackingNumber,
            OrderQty,
            ProductID,
            SpecialOfferID,
            UnitPrice,
            UnitPriceDiscount,
            rowguid,
            ModifiedDate
           )
    VALUES (source.SalesOrderID,
            source.CarrierTrackingNumber,
            source.OrderQty,
            source.ProductID,
            source.SpecailOfferID,
            source.UnitPrice,
            source.UnitPriceDiscount,
            NEWID(),
            GETUTCDATE()
           )
WHEN MATCHED AND source.OrderQty > 0 THEN
    UPDATE SET OrderQty = source.OrderQty,
               ProductID = source.ProductID,
               SpecialOfferID = source.SpecailOfferID,
               UnitPrice = source.UnitPrice,
               UnitPriceDiscount = source.UnitPriceDiscount,
               ModifiedDate = GETUTCDATE()
WHEN MATCHED AND source.OrderQty = 0 THEN
    DELETE;

GO





--insert (remember, estimated plans)
BEGIN TRANSACTION
EXEC dbo.MergeSalesOrderDetail
    @SalesOrderID = 43688, -- int
    @SalesOrderDetailID = NULL,
    @CarrierTrackingNumber = 'Some value', -- varchar(25)
    @OrderQty = 1, -- smallint
    @ProductID = 733, -- int
    @SpecialOfferID = 1, -- int
    @UnitPrice = 4.7, -- money
    @UnitPriceDiscount = 0.0; -- money
ROLLBACK TRANSACTION


DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROCEDURE dbo.MergeSalesOrderDetail%'

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO


--update
BEGIN TRANSACTION
EXEC dbo.MergeSalesOrderDetail
    @SalesOrderID = 43688, -- int
    @SalesOrderDetailID = 263, -- int
    @CarrierTrackingNumber = 'Yo!', -- varchar(25)
    @OrderQty = 1, -- smallint
    @ProductID = 729, -- int
    @SpecialOfferID = 1, -- int
    @UnitPrice = 183.9382, -- money
    @UnitPriceDiscount = 0.0; -- money
ROLLBACK TRANSACTION


DECLARE @PlanHandle VARBINARY(64)

SELECT @PlanHandle = deqs.plan_handle 
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROCEDURE dbo.MergeSalesOrderDetail%'

DBCC FREEPROCCACHE(@PlanHandle);


--delete
BEGIN TRANSACTION
EXEC dbo.MergeSalesOrderDetail
    @SalesOrderID = 43688, -- int
    @SalesOrderDetailID = 263, -- int
    @CarrierTrackingNumber = 'Yo!', -- varchar(25)
    @OrderQty = 0, -- smallint
    @ProductID = 729, -- int
    @SpecialOfferID = 1, -- int
    @UnitPrice = 183.9382, -- money
    @UnitPriceDiscount = 0.0; -- money
ROLLBACK TRANSACTION



SELECT deps.execution_count FROM sys.dm_exec_procedure_stats AS deps
WHERE deps.object_id = OBJECT_ID('dbo.MergeSalesOrderDetail')












--triggers


CREATE TRIGGER [Sales].[iduSalesOrderDetail] ON [Sales].[SalesOrderDetail] 
AFTER INSERT, DELETE, UPDATE AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        -- If inserting or updating these columns
        IF UPDATE(ProductID) OR UPDATE(OrderQty) OR UPDATE(UnitPrice) OR UPDATE(UnitPriceDiscount) 
        -- Insert record into TransactionHistory
        BEGIN
            INSERT INTO Production.TransactionHistory
                (ProductID
                ,ReferenceOrderID
                ,ReferenceOrderLineID
                ,TransactionType
                ,TransactionDate
                ,Quantity
                ,ActualCost)
            SELECT 
                inserted.ProductID
                ,inserted.SalesOrderID
                ,inserted.SalesOrderDetailID
                ,'S'
                ,GETDATE()
                ,inserted.OrderQty
                ,inserted.UnitPrice
            FROM inserted 
                INNER JOIN Sales.SalesOrderHeader 
                ON inserted.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID;

            UPDATE Person.Person 
            SET Demographics.modify('declare default element namespace 
                "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
                replace value of (/IndividualSurvey/TotalPurchaseYTD)[1] 
                with data(/IndividualSurvey/TotalPurchaseYTD)[1] + sql:column ("inserted.LineTotal")') 
            FROM inserted 
                INNER JOIN Sales.SalesOrderHeader AS SOH
                ON inserted.SalesOrderID = SOH.SalesOrderID 
                INNER JOIN Sales.Customer AS C
                ON SOH.CustomerID = C.CustomerID
            WHERE C.PersonID = Person.Person.BusinessEntityID;
        END;

        -- Update SubTotal in SalesOrderHeader record. Note that this causes the 
        -- SalesOrderHeader trigger to fire which will update the RevisionNumber.
        UPDATE Sales.SalesOrderHeader
        SET Sales.SalesOrderHeader.SubTotal = 
            (SELECT SUM(Sales.SalesOrderDetail.LineTotal)
                FROM Sales.SalesOrderDetail
                WHERE Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID)
        WHERE Sales.SalesOrderHeader.SalesOrderID IN (SELECT inserted.SalesOrderID FROM inserted);

        UPDATE Person.Person 
        SET Demographics.modify('declare default element namespace 
            "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
            replace value of (/IndividualSurvey/TotalPurchaseYTD)[1] 
            with data(/IndividualSurvey/TotalPurchaseYTD)[1] - sql:column("deleted.LineTotal")') 
        FROM deleted 
            INNER JOIN Sales.SalesOrderHeader 
            ON deleted.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID 
            INNER JOIN Sales.Customer
            ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
        WHERE Sales.Customer.PersonID = Person.Person.BusinessEntityID;
    END TRY
    BEGIN CATCH
        EXECUTE dbo.uspPrintError;

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE dbo.uspLogError;
    END CATCH;
END;

GO

BEGIN TRAN
INSERT Person.Person
        (BusinessEntityID,
         PersonType,
         NameStyle,
         Title,
         FirstName,
         MiddleName,
         LastName,
         Suffix,
         EmailPromotion,
         AdditionalContactInfo,
         Demographics,
         rowguid,
         ModifiedDate
        )
VALUES  (0, -- BusinessEntityID - int
         N'', -- PersonType - nchar(2)
         2, -- NameStyle - NameStyle
         N'', -- Title - nvarchar(8)
         'first', -- FirstName - Name
         NULL, -- MiddleName - Name
         'name', -- LastName - Name
         N'', -- Suffix - nvarchar(10)
         0, -- EmailPromotion - int
         NULL, -- AdditionalContactInfo - xml
         NULL, -- Demographics - xml
         NEWID(), -- rowguid - uniqueidentifier
         GETDATE()  -- ModifiedDate - datetime
        )

ROLLBACK TRAN




--identity
BEGIN TRANSACTION
INSERT Sales.Store
        (BusinessEntityID,
         Name,
         SalesPersonID,
         Demographics,
         rowguid,
         ModifiedDate
        )
VALUES  (43, -- BusinessEntityID - int
         'Grant''s Pain Emporium', -- Name - Name
         284, -- SalesPersonID - int
         NULL, -- Demographics - xml
         NEWID(), -- rowguid - uniqueidentifier
         GETUTCDATE()  -- ModifiedDate - datetime
        );
COMMIT TRANSACTION 










CREATE SEQUENCE dbo.MySeqGenerator START WITH 1 INCREMENT BY 1;
GO

CREATE TABLE dbo.SeqTest
    (SeqTestID int PRIMARY KEY DEFAULT (NEXT VALUE FOR dbo.MySeqGenerator),
    MyVal varchar(50) NOT NULL,
    Qty int NOT NULL);
GO

ALTER TABLE dbo.SeqTest  WITH CHECK ADD CONSTRAINT QtyGreaterThanZero CHECK  ((Qty>0))
GO




INSERT dbo.SeqTest
        (MyVal, Qty)
VALUES  ('Dude', -- MyVal - varchar(50)
         42  -- Qty - int
         );
GO
INSERT dbo.SeqTest
        (MyVal, Qty)
VALUES  ('Duddette', -- MyVal - varchar(50)
         0  -- Qty - int
         );
GO
INSERT dbo.SeqTest
        (MyVal, Qty)
VALUES  ('Something', -- MyVal - varchar(50)
         142  -- Qty - int
         );
GO



SELECT * FROM dbo.SeqTest AS st;







--cleanup
DROP SEQUENCE dbo.MySeqGenerator;
DROP TABLE dbo.SeqTest;










--User Defined Functions
SELECT * FROM dbo.ufnGetContactInformation(42) AS ugci;











DROP FUNCTION dbo.ProductList;
GO

CREATE FUNCTION dbo.ProductList (@ProductCategory INT)
RETURNS @ProductList TABLE (
     ProductId INT,
     Name NVARCHAR(50),
     Color NVARCHAR(15),
     CategoryName NVARCHAR(50),
     SubCategoryName NVARCHAR(50)
    )
AS 
    BEGIN
        IF EXISTS ( SELECT  *
                    FROM    Production.ProductSubcategory AS ps
                    WHERE   ps.ProductCategoryID = @productCategory ) 
            BEGIN
                INSERT  @ProductList
                        SELECT  p.ProductId,
                                p.NAME,
                                p.Color,
                                pc.Name,
                                ps.Name
                        FROM    Production.Product AS p
                                JOIN Production.ProductSubcategory AS ps
                                ON p.ProductSubcategoryID = ps.ProductSubcategoryID
                                JOIN Production.ProductCategory AS pc
                                ON ps.ProductCategoryID = pc.ProductCategoryID
                        WHERE   pc.ProductCategoryID = @ProductCategory
                RETURN ;
            END
        RETURN 
    END
GO






-- remember to run these seperately
SELECT  *
FROM    Sales.SalesOrderDetail AS sod
        JOIN dbo.ProductList (3) AS pl
        ON sod.ProductID = pl.ProductId
WHERE   sod.SalesOrderID = 43676;








SELECT  sod.*,
        p.productId,
        p.Name,
        p.Color,
        pc.Name AS CategoryName,
        ps.Name AS SubCategoryName
FROM    Sales.SalesOrderDetail AS SOD
        JOIN Production.Product AS p
        ON SOD.ProductID = p.ProductID
        JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE   pc.ProductCategoryID = 3
        AND SOD.SalesOrderID = 43676;












SELECT  p.ProductID,
        dbo.ufnGetProductListPrice(p.ProductID, '2014/03/31')
FROM    Production.Product AS p;









CREATE FUNCTION dbo.GetProductPrice(@ProductID int, @OrderDate datetime)
RETURNS table
AS 
   RETURN SELECT plph.ListPrice 
    FROM Production.Product p 
        INNER JOIN Production.ProductListPriceHistory plph 
        ON p.ProductID = plph.ProductID 
            AND p.ProductID = @ProductID 
            AND @OrderDate BETWEEN plph.StartDate AND COALESCE(plph.EndDate, CONVERT(datetime, '99991231', 112)); -- Make sure we get all the prices!







SELECT  p.ProductID,
        gpp.ListPrice
FROM    Production.Product AS p
OUTER APPLY dbo.GetProductPrice(p.ProductID, '2014/03/31') AS gpp;






--in-memory stored procedures
USE InMemoryTest;
GO


EXEC dbo.AddressDetails @City = N'Walla Walla';










EXEC dbo.AddressDetails N'Walla Walla';










--live execution plan
USE AdventureWorks2014;
GO




SELECT * FROM sys.dm_exec_query_profiles AS deqp


--run in a different connection
SET STATISTICS PROFILE ON 
GO
SELECT  *
FROM    Production.ProductCostHistory AS pch,
        Production.BillOfMaterials AS bom,
        Person.ContactType AS ct;
	











-- added plans
-- multiple warnings
SELECT  p.LastName + ', ' + p.FirstName AS PersonName,
        a.AddressLine1,
        a.City,
        a.PostalCode
FROM    person.Address AS a
        JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
        JOIN Person.Person AS p
        ON bea.BusinessEntityID = p.BusinessEntityID
WHERE   city = 'Berlin'
        AND PostalCode = 14197




--simple parameterization
SELECT ct.*
FROM    Person.ContactType AS ct
WHERE   ct.ContactTypeID = 700000;

SELECT ct.*
FROM    Person.ContactType AS ct
WHERE   ct.ContactTypeID = 7000;

SELECT ct.*
FROM    Person.ContactType AS ct
WHERE   ct.ContactTypeID = 7;


SELECT * FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE '%@1%'

SELECT  p.LastName
FROM    Person.Person AS p
WHERE   p.LastName = 'Abel';


SELECT  p.LastName
FROM    Person.Person AS p
WHERE   p.LastName = 'Abercrombie';





