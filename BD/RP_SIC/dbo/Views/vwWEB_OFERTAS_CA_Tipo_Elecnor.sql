
CREATE VIEW [dbo].[vwWEB_OFERTAS_CA_Tipo_Elecnor]
AS
SELECT        CDCEN AS CodCentro, CDOFT AS CodOferta, dbo.fgConvertirFechaDMY(FECHAD) AS FAdjudicacion, TVEN AS ImporteTotal, ADELE AS Adjudicada, WS10 AS Tipo
FROM            dbo.vwWEB_OFERTACION_CA
WHERE        (BAJA <> 'B') AND WS10='E'

