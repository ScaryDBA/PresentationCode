SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [dbo].[VendorInfo]
AS
SELECT v.VendorName,
       r.RadioName
FROM dbo.Vendor AS v
    JOIN dbo.Radio AS r
        ON v.VendorID = r.VendorID;
GO
