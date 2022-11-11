USE WideWorldImporters;
GO
-- Add StockItems to cause a data skew in Suppliers
--
DECLARE @StockItemID INT;
DECLARE @StockItemName VARCHAR(100);
DECLARE @SupplierID INT;
SELECT @StockItemID = 228;
SET @StockItemName = 'Dallas Cowboys Shirt'+CONVERT(VARCHAR(10), @StockItemID);
SET @SupplierID = 4;
DELETE FROM Warehouse.StockItems WHERE StockItemID >= @StockItemID;
SET NOCOUNT ON;
BEGIN TRANSACTION;
WHILE @StockItemID <= 20000000
BEGIN
INSERT INTO Warehouse.StockItems
(StockItemID, StockItemName, SupplierID, UnitPackageID, OuterPackageID, LeadTimeDays,
QuantityPerOuter, IsChillerStock, TaxRate, UnitPrice, TypicalWeightPerUnit, LastEditedBy
)
VALUES (@StockItemID, @StockItemName, @SupplierID, 10, 9, 12, 100, 0, 15.00, 100.00, 0.300, 1);
SET @StockItemID = @StockItemID + 1;
SET @StockItemName = 'Dallas Cowboys Shirt'+convert(varchar(10), @StockItemID);
END
COMMIT TRANSACTION;
SET NOCOUNT OFF;
GO



USE WideWorldImporters;
GO
ALTER INDEX FK_Warehouse_StockItems_SupplierID ON Warehouse.StockItems REBUILD;
GO


USE WideWorldImporters;
GO
-- Make sure QS is on and set runtime collection lower than default
ALTER DATABASE WideWorldImporters SET QUERY_STORE = ON;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 60, INTERVAL_LENGTH_MINUTES = 1, QUERY_CAPTURE_MODE = ALL);
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR ALL;
GO
-- Enable DOP feedback
ALTER DATABASE SCOPED CONFIGURATION SET DOP_FEEDBACK = ON;
GO
-- Clear proc cache to start with new plans
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO


CREATE OR ALTER PROCEDURE [Warehouse].[GetStockItemsbySupplier]  @SupplierID int
AS
BEGIN
SELECT StockItemID, SupplierID, StockItemName, TaxRate, LeadTimeDays
FROM Warehouse.StockItems s
WHERE SupplierID = @SupplierID
ORDER BY StockItemName;
END;
GO

EXEC Warehouse.GetStockItemsbySupplier @SupplierID = 4 -- int

"c:\Program Files\Microsoft Corporation\RMLUtils\ostress" -U"sa" -P"$cthulhu1988" -Q"EXEC Warehouse.GetStockItemsbySupplier 4;" -n1 -r75 -q -oworkload_wwi_regress -dWideWorldImporters


