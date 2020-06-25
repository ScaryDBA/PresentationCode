CREATE TABLE [dbo].[Vendor]
(
[VendorID] [int] NOT NULL IDENTITY(1, 1),
[VendorName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Vendor] ADD CONSTRAINT [PkVendor] PRIMARY KEY CLUSTERED  ([VendorID]) ON [PRIMARY]
GO
