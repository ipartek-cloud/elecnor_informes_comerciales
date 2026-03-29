CREATE VIEW [dbo].[vwWEB_OF_Abiertas_antes]
AS
SELECT     CDCEN AS CodCentro, CDOFT AS CodOferta, dbo.fgConvertirFechaDMY(FECHAA) AS Fecha, IMAOF AS Importe, Usuario
FROM         dbo.WEB_OFERTACION
