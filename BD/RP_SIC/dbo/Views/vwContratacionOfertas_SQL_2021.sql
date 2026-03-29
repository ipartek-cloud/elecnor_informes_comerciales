


create VIEW [dbo].[vwContratacionOfertas_SQL_2021]
AS
SELECT   distinct  dbo.OfertasSQL.CodCentro, OfertasSQL.CodCliente,  dbo.OfertasSQL.CodOferta
FROM     dbo.OfertasSQL 
WHERE    (dbo.OfertasSQL.AñoAdjudicacion = 2021)



