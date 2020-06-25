CREATE TABLE [dbo].[Radio]
(
[RadioID] [int] NOT NULL IDENTITY(1, 1),
[RadioName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VendorID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Radio] ADD CONSTRAINT [PkRadio] PRIMARY KEY CLUSTERED  ([RadioID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RadioNameIdx] ON [dbo].[Radio] ([RadioName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Radio] ADD CONSTRAINT [FKVendorRadio] FOREIGN KEY ([VendorID]) REFERENCES [dbo].[Vendor] ([VendorID])
GO
