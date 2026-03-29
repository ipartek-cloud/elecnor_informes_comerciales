CREATE VIEW [dbo].[vwTendencias_SDG]
AS
SELECT        dbo.Sumarigrama.CodSubDirGeneral, dbo.Tendencias.Año, dbo.Tendencias.Mes, ISNULL(SUM(dbo.Tendencias.TendenciaCierre), 0) AS TendenciaCierre, 
                         ISNULL(SUM(dbo.Tendencias.ContratacionPdteImputar), 0) AS ContratacionPdteImputar, ISNULL(SUM(dbo.Tendencias.AsuntosPdtes), 0) AS AsuntosPdtes
FROM            dbo.Sumarigrama INNER JOIN
                         dbo.Tendencias ON dbo.Sumarigrama.CodCentro = dbo.Tendencias.CodCentro
GROUP BY dbo.Sumarigrama.CodSubDirGeneral, dbo.Tendencias.Año, dbo.Tendencias.Mes