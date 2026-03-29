CREATE VIEW [dbo].[vwObjetivosActivadadNacionalInternacional_DN]
AS
SELECT   dbo.ObjetivosActividadSQL.Año, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, 
                         dbo.fnCDAC(dbo.ObjetivosActividadSQL.CDAC1, dbo.ObjetivosActividadSQL.CDAC2) AS CDAC, SUM(dbo.ObjetivosActividadSQL.Importe) AS Importe, 
                         dbo.ObjetivosActividadSQL.Mercado
FROM            dbo.ObjetivosActividadSQL INNER JOIN
                         dbo.Sumarigrama ON dbo.ObjetivosActividadSQL.CodCentro = dbo.Sumarigrama.CodCentro AND dbo.ObjetivosActividadSQL.Año = dbo.Sumarigrama.Año
WHERE        (dbo.Sumarigrama.CodSubDirGeneral = 221)
GROUP BY dbo.ObjetivosActividadSQL.Año, dbo.fnCDAC(dbo.ObjetivosActividadSQL.CDAC1, dbo.ObjetivosActividadSQL.CDAC2), dbo.ObjetivosActividadSQL.Mercado, 
                         dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio