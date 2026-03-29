CREATE VIEW [dbo].[vwContratacion_Ingresos300K_2019_CON_Referencias]
AS
SELECT        CodCentro, COUNT(dbo.Referencias.idReferencia) AS NumReferencias
FROM            dbo.vwContratacion_Ingresos300K_2019 INNER JOIN
                         dbo.Referencias ON dbo.vwContratacion_Ingresos300K_2019.CodOferta = dbo.Referencias.CodOferta
GROUP BY dbo.vwContratacion_Ingresos300K_2019.CodCentro