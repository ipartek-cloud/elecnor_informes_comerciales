CREATE VIEW [dbo].[vwObjetivosActividadesAGRUPNacionalInternacional_221]
AS
SELECT        Orden, Agrupacion, Año, Mercado, SUM(Importe) AS Importe
FROM            dbo.vwObjetivosActividadesNacionalInternacional_221
GROUP BY Orden, Agrupacion, Año, Mercado
