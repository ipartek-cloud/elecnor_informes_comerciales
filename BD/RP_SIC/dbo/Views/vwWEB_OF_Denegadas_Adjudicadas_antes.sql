CREATE  VIEW [dbo].[vwWEB_OF_Denegadas_Adjudicadas_antes]
AS
SELECT     CDCEN AS CodCentro, CDOFT AS CodOferta, dbo.fgConvertirFechaDMY(FECHAD) AS Fecha, ADELE AS Adjudicada, PREAD AS Importe, Usuario
FROM         dbo.WEB_OFERTACION
WHERE     (ISNULL(FECHAD, 0) <> 0)
