
CREATE VIEW [dbo].[vwObjetivosActividad]
AS
SELECT        Año, dbo.fnCDAC(CDAC1, CDAC2) AS CDAC, SUM(Importe) AS Importe
FROM            dbo.ObjetivosActividadSQL
GROUP BY Año, dbo.fnCDAC(CDAC1, CDAC2)

