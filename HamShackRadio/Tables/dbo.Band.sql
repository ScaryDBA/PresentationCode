CREATE TABLE [dbo].[Band]
(
[BandID] [int] NOT NULL IDENTITY(1, 1),
[BandName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BandRangeBottomKhz] [decimal] (6, 2) NOT NULL,
[BandRangeTopKhz] [decimal] (6, 2) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Band] ADD CONSTRAINT [PkBands] PRIMARY KEY CLUSTERED  ([BandID]) ON [PRIMARY]
GO
