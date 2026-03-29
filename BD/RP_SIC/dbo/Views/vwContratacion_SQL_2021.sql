

CREATE VIEW [dbo].[vwContratacion_SQL_2021]
AS
SELECT        TOP (100) PERCENT dbo.OfertasSQL.AñoAdjudicacion AS Año, MONTH(dbo.OfertasSQL.FAdjudicacion) AS Mes, dbo.OfertasSQL.CodCentro, 
                         dbo.OfertasSQL.CodOferta AS CODOFER, dbo.OfertasSQL.DescripcionOferta AS DESOFER, dbo.OfertasSQL.CodCliente, 
                         dbo.fnNombreClienteAgrupadoATERSA(dbo.OfertasSQL.CodCliente, dbo.ClientesSQL.NomAgrupado) AS NomCliente, 
                         dbo.OfertasSQL.ImporteContratado AS Importe
FROM            dbo.OfertasSQL LEFT OUTER JOIN
                         dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
WHERE        (dbo.OfertasSQL.AñoAdjudicacion = 2021)


