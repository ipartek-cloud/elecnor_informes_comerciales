CREATE VIEW [dbo].[vwWEB_OFERTAS_CA_SinAdjudicacion_SinObras_antes]
AS
SELECT        dbo.vwWEB_OFERTACION_CA.CDOFT AS CodOferta
FROM            dbo.vwWEB_OFERTACION_CA LEFT OUTER JOIN
                         dbo.Enlaces ON dbo.vwWEB_OFERTACION_CA.CDCEN = dbo.Enlaces.CTRO AND dbo.vwWEB_OFERTACION_CA.CDOFT = dbo.Enlaces.CDOFT
WHERE        (dbo.vwWEB_OFERTACION_CA.ADELE <> 'S') AND (ISNULL(dbo.Enlaces.CDOFT, - 1) = - 1)
