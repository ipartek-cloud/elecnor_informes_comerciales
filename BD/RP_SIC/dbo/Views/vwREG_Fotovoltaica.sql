
CREATE VIEW [dbo].[vwREG_Fotovoltaica]
AS
SELECT     dbo.Regularizaciones.CDCEN AS CodCentro, dbo.Regularizaciones.CDOFT AS CodOferta, ISNULL(dbo.Regularizaciones.NUMRE, 0) 
                      AS NumRegularizacion, dbo.Ofertas.DCOF AS DescripcionOferta, dbo.Ofertas.CDCLI AS CodCliente, dbo.Ofertas.LOCAL AS Localidad, 
                      dbo.Ofertas.PROOF AS CodProv, dbo.Ofertas.CDAC1 AS CodAct1, dbo.Ofertas.CDAC2 AS CodAct2, dbo.Ofertas.RPROF AS CodResponsable, 
                      dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR) AS FAdjudicacion, dbo.Regularizaciones.IMPRE AS ImporteContratado, dbo.Provincias.Pais, 
                      dbo.Provincias.NMPRO
FROM         dbo.Ofertas INNER JOIN
                      dbo.Regularizaciones ON dbo.Ofertas.CDOFT = dbo.Regularizaciones.CDOFT INNER JOIN
                      dbo.Provincias ON dbo.Ofertas.PROOF = dbo.Provincias.CDPRO
WHERE cdac1='04' and CDAC2='42'