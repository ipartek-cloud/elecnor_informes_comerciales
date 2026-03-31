




CREATE VIEW [dbo].[vwSDG_Contratacion Actividades_2022_DN]
AS
SELECT        dbo.ActividadesSQL.Orden, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.ActividadesSQL.Agrupacion, 
                         LEFT(CG.MERCADO, 1) AS Pais, SUM(CG.IMPAD) AS Contratatacion, 
                         CG.MESAD
FROM            dbo.Sumarigrama INNER JOIN
                         dbo.[@ContratacionGrupo2022] CG ON dbo.Sumarigrama.CodCentro = CG.CT INNER JOIN
                         dbo.ActividadesSQL ON CG.ACT2 = dbo.ActividadesSQL.CDAC2 AND CG.ACT1 = dbo.ActividadesSQL.CDAC1
WHERE        (dbo.Sumarigrama.CodSubDirGeneral = 221)
GROUP BY dbo.ActividadesSQL.Orden, dbo.ActividadesSQL.Agrupacion, LEFT(CG.MERCADO, 1), CG.MESAD, 
                         dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio