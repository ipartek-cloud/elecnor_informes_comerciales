
CREATE VIEW [dbo].[vwContratacionOfertas_SQL_2018]
AS
SELECT   distinct  dbo.OfertasSQL.CodCentro, OfertasSQL.CodCliente,  dbo.OfertasSQL.CodOferta
FROM     dbo.OfertasSQL 
WHERE    (dbo.OfertasSQL.AñoAdjudicacion = 2018)

