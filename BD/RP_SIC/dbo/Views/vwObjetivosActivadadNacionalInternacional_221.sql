
CREATE VIEW [dbo].[vwObjetivosActivadadNacionalInternacional_221]
AS
SELECT        TOP (100) PERCENT dbo.ObjetivosActividadSQL.Año, dbo.fnCDAC(dbo.ObjetivosActividadSQL.CDAC1, dbo.ObjetivosActividadSQL.CDAC2) AS CDAC, 
                         SUM(dbo.ObjetivosActividadSQL.Importe) AS Importe, dbo.ObjetivosActividadSQL.Mercado
FROM            dbo.ObjetivosActividadSQL INNER JOIN
                         dbo.Sumarigrama ON dbo.ObjetivosActividadSQL.CodCentro = dbo.Sumarigrama.CodCentro AND dbo.ObjetivosActividadSQL.Año = dbo.Sumarigrama.Año
WHERE        (dbo.Sumarigrama.CodSubDirGeneral = 221)
GROUP BY dbo.ObjetivosActividadSQL.Año, dbo.fnCDAC(dbo.ObjetivosActividadSQL.CDAC1, dbo.ObjetivosActividadSQL.CDAC2), dbo.ObjetivosActividadSQL.Mercado

