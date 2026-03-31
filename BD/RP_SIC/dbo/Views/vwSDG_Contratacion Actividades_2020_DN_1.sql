

CREATE VIEW [dbo].[vwSDG_Contratacion Actividades_2020_DN]
AS
SELECT        dbo.ActividadesSQL.Orden, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.ActividadesSQL.Agrupacion, 
                         LEFT(dbo.[@ContratacionGrupo2020].MERCADO, 1) AS Pais, SUM(dbo.[@ContratacionGrupo2020].IMPAD) AS Contrat2020, 
                         dbo.[@ContratacionGrupo2020].MESAD
FROM            dbo.Sumarigrama INNER JOIN
                         dbo.[@ContratacionGrupo2020] ON dbo.Sumarigrama.CodCentro = dbo.[@ContratacionGrupo2020].CT INNER JOIN
                         dbo.ActividadesSQL ON dbo.[@ContratacionGrupo2020].ACT2 = dbo.ActividadesSQL.CDAC2 AND 
                         dbo.[@ContratacionGrupo2020].ACT1 = dbo.ActividadesSQL.CDAC1
WHERE        (dbo.Sumarigrama.CodSubDirGeneral = 221)
GROUP BY dbo.ActividadesSQL.Orden, dbo.ActividadesSQL.Agrupacion, LEFT(dbo.[@ContratacionGrupo2020].MERCADO, 1), dbo.[@ContratacionGrupo2020].MESAD, 
                         dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio