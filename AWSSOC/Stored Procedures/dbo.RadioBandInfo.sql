SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROC [dbo].[RadioBandInfo]
(@RadioID INT)
AS
SELECT r.RadioID,
       r.RadioName,
       r.VendorID,
       rb.RadioID,
       rb.BandID,
       rb.Receive,
       rb.Transmit
FROM dbo.Radio AS r
    JOIN dbo.RadioBand AS rb
        ON rb.RadioID = r.RadioID
WHERE r.RadioID = @RadioID;
GO
