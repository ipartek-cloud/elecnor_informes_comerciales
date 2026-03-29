CREATE VIEW [dbo].[vwObjetivosActividadesNacionalInternacional_221]
AS
SELECT        TOP (100) PERCENT dbo.vwActividadesCDAC.Orden, dbo.vwActividadesCDAC.Agrupacion, dbo.vwActividadesCDAC.CDAC, 
                         dbo.vwObjetivosActivadadNacionalInternacional_221.Año, ISNULL(dbo.vwObjetivosActivadadNacionalInternacional_221.Importe, 0) AS Importe, 
                         dbo.vwObjetivosActivadadNacionalInternacional_221.Mercado
FROM            dbo.vwActividadesCDAC LEFT OUTER JOIN
                         dbo.vwObjetivosActivadadNacionalInternacional_221 ON dbo.vwActividadesCDAC.CDAC = dbo.vwObjetivosActivadadNacionalInternacional_221.CDAC
WHERE        (ISNULL(dbo.vwObjetivosActivadadNacionalInternacional_221.Mercado, N'') <> '')