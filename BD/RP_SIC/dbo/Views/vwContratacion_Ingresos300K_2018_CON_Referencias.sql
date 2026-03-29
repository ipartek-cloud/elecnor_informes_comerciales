

CREATE VIEW [dbo].[vwContratacion_Ingresos300K_2018_CON_Referencias]
AS
SELECT        CodCentro, COUNT(dbo.Referencias.idReferencia) AS NumReferencias
FROM            dbo.vwContratacion_Ingresos300K_2018 INNER JOIN
                         dbo.Referencias ON dbo.vwContratacion_Ingresos300K_2018.CodOferta = dbo.Referencias.CodOferta
GROUP BY dbo.vwContratacion_Ingresos300K_2018.CodCentro

