
CREATE VIEW [dbo].[vwWEB_REG_OLD]
AS
SELECT     OfRe.CDCEN AS CodCentro, OfRe.CDOFT AS CodOferta, ISNULL(OfRe.NUMRE, 0) 
                      AS NumRegularizacion, OfRe.DCOF AS DescripcionOferta, OfRe.CDCLI AS CodCliente, OfRe.LOCAL AS Localidad, 
                      OfRe.PROOF AS CodProv, OfRe.CDAC1 AS CodAct1, OfRe.CDAC2 AS CodAct2, OfRe.RPROF AS CodResponsable, 
	CASE WHEN LEN(FECHAR)>5 THEN convert(datetime,right(FECHAR,6),103) ELSE NULL END AS FAdjudicacion,		
			OfRe.IMPRE AS ImporteContratado, 
                    OfRe.CAUS, 
	CASE WHEN LEN(FECHAA)>5 THEN convert(datetime,right(FECHAA,6),103) ELSE NULL END AS FAlta,		
					OfRe.IMAOF AS ImporteAlta, 
	CASE WHEN LEN(FECHPP)>5 THEN convert(datetime,right(FECHPP,6),103) ELSE NULL END AS FPresentacion,		
					OfRe.PREVE AS ImportePresentacion
FROM         dbo.Contratacion_Ofertas_Regularizaciones OfRe

