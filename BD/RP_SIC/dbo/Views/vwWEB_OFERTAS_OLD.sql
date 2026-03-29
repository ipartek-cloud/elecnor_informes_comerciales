
CREATE VIEW [dbo].[vwWEB_OFERTAS_OLD]
AS
SELECT     CDCEN AS CodCentro, CDOFT AS CodOferta, DCOF AS DescripcionOferta, CDCLI AS CodCliente, LOCAL AS Localidad, PROOF AS CodProv, 
                      CDAC1 AS CodAct1, CDAC2 AS CodAct2, RPROF AS CodResponsable, 
	CASE WHEN LEN(FECHAD)>5 THEN convert(datetime,right(FECHAD,6),103) ELSE NULL END AS FAdjudicacion,		
                      PREAD AS ImporteContratado
FROM         dbo.Contratacion

