


CREATE VIEW [dbo].[vwSDG_Contratacion Actividades_2022_0708_DN]
AS
SELECT        dbo.ActividadesSQL.Orden, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.ActividadesSQL.CDAC1, 
                         LEFT(CG.MERCADO, 1) AS Pais, SUM(CG.IMPAD) AS Contratacion, 
                         CG.MESAD
FROM            dbo.Sumarigrama INNER JOIN
                         dbo.[@ContratacionGrupo2022] AS CG ON dbo.Sumarigrama.CodCentro = CG.CT INNER JOIN
                         dbo.ActividadesSQL ON CG.ACT2 = dbo.ActividadesSQL.CDAC2 AND 
                         CG.ACT1 = dbo.ActividadesSQL.CDAC1
WHERE        (dbo.Sumarigrama.CodSubDirGeneral = 221) AND (dbo.ActividadesSQL.CDAC1 = '07') OR
                         (dbo.Sumarigrama.CodSubDirGeneral = 221) AND (dbo.ActividadesSQL.CDAC1 = '08')
GROUP BY dbo.ActividadesSQL.Orden, LEFT(CG.MERCADO, 1), CG.MESAD, dbo.ActividadesSQL.CDAC1, 
                         dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio



