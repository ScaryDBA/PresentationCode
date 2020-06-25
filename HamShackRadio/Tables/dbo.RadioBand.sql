CREATE TABLE [dbo].[RadioBand]
(
[RadioID] [int] NOT NULL,
[BandID] [int] NOT NULL,
[Receive] [bit] NOT NULL,
[Transmit] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RadioBand] ADD CONSTRAINT [PKRadioBand] PRIMARY KEY CLUSTERED  ([RadioID], [BandID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RadioBand] ADD CONSTRAINT [FKBandRadioBand] FOREIGN KEY ([BandID]) REFERENCES [dbo].[Band] ([BandID])
GO
ALTER TABLE [dbo].[RadioBand] ADD CONSTRAINT [FKRadioRadioBand] FOREIGN KEY ([RadioID]) REFERENCES [dbo].[Radio] ([RadioID])
GO
