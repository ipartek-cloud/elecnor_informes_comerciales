
CREATE VIEW [dbo].[vwObjetivosActividadesNacionalInternacional]
AS
SELECT        TOP (100) PERCENT dbo.vwActividadesCDAC.Orden, dbo.vwActividadesCDAC.Agrupacion, dbo.vwActividadesCDAC.CDAC, 
                         dbo.vwObjetivosActivadadNacionalInternacional.Año, ISNULL(dbo.vwObjetivosActivadadNacionalInternacional.Importe, 0) AS Importe, 
                         dbo.vwObjetivosActivadadNacionalInternacional.Mercado
FROM            dbo.vwActividadesCDAC LEFT OUTER JOIN
                         dbo.vwObjetivosActivadadNacionalInternacional ON dbo.vwActividadesCDAC.CDAC = dbo.vwObjetivosActivadadNacionalInternacional.CDAC
WHERE        (ISNULL(dbo.vwObjetivosActivadadNacionalInternacional.Mercado, N'') <> '')

