



CREATE VIEW [dbo].[vwSDG_Contratacion Actividades_2021_DN]
AS
SELECT        dbo.ActividadesSQL.Orden, S.CodDDirNegocio, S.NombreDirNegocio, dbo.ActividadesSQL.Agrupacion, 
                         LEFT(dbo.[@ContratacionGrupo2021].MERCADO, 1) AS Pais, SUM(dbo.[@ContratacionGrupo2021].IMPAD) AS Contrat2021, 
                         dbo.[@ContratacionGrupo2021].MESAD
FROM            dbo.Sumarigrama2021 S INNER JOIN
                         dbo.[@ContratacionGrupo2021] ON S.CodCentro = dbo.[@ContratacionGrupo2021].CT INNER JOIN
                         dbo.ActividadesSQL ON dbo.[@ContratacionGrupo2021].ACT2 = dbo.ActividadesSQL.CDAC2 AND 
                         dbo.[@ContratacionGrupo2021].ACT1 = dbo.ActividadesSQL.CDAC1
WHERE        (S.CodSubDirGeneral = 221)
GROUP BY dbo.ActividadesSQL.Orden, dbo.ActividadesSQL.Agrupacion, LEFT(dbo.[@ContratacionGrupo2021].MERCADO, 1), dbo.[@ContratacionGrupo2021].MESAD, 
                         S.CodDDirNegocio, S.NombreDirNegocio