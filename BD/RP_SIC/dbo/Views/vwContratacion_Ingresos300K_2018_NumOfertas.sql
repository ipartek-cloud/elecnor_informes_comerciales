CREATE VIEW [dbo].[vwContratacion_Ingresos300K_2018_NumOfertas]
AS
SELECT        CodCentro, COUNT(CodOferta) AS NumOfertas
FROM            dbo.vwContratacion_Ingresos300K_2018
GROUP BY CodCentro