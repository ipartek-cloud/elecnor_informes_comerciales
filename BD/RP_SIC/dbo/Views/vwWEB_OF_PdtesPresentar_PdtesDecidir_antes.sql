CREATE VIEW [dbo].[vwWEB_OF_PdtesPresentar_PdtesDecidir_antes]
AS
SELECT     CDCEN AS CodCentro, CDOFT AS CodOferta, dbo.fgConvertirFechaDMY(FECHAA) AS FechaAlta, dbo.fgConvertirFechaDMY(FECHPP) AS Fecha, 
                      dbo.fgConvertirFechaDMY(FECHAD) AS FechaAdjudicacion, PREVE AS Importe, Usuario
FROM         dbo.WEB_OFERTACION
WHERE     (ISNULL(FECHAD, 0) = 0) AND (ISNULL(FECHPP, 0) <> 0)
