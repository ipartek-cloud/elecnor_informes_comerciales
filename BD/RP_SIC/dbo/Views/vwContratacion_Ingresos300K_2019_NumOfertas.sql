CREATE VIEW [dbo].[vwContratacion_Ingresos300K_2019_NumOfertas]
AS
SELECT        CodCentro, COUNT(CodOferta) AS NumOfertas
FROM            dbo.vwContratacion_Ingresos300K_2019
GROUP BY CodCentro