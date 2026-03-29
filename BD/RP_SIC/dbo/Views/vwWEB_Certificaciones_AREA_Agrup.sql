CREATE VIEW [dbo].[vwWEB_Certificaciones_AREA_Agrup]
AS
SELECT        Usuario, CodSubDirNegocioArea, NombreSubDirNegocioArea, SUM(NumReferencias_ALL) AS NumReferencias_ALL, SUM(NumCBE_ALL) AS NumCBE_ALL, SUM(NumOfertas_2016) 
                         AS NumOfertas_2016, SUM(NumReferencias_2016) AS NumReferencias_2016, SUM(NumCBE_2016) AS NumCBE_2016, SUM(NumOfertas_2018) 
                         AS NumOfertas_2018, SUM(NumReferencias_2018) AS NumReferencias_2018, SUM(NumCBE_2018) AS NumCBE_2018, SUM(NumOfertas_2019) 
                         AS NumOfertas_2019, SUM(NumReferencias_2019) AS NumReferencias_2019, SUM(NumCBE_2019) AS NumCBE_2019
FROM            dbo.WEB_CertificacionesUsuarioCentro
GROUP BY Usuario,CodSubDirNegocioArea, NombreSubDirNegocioArea