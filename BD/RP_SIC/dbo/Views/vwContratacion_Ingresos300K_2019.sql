

CREATE VIEW [dbo].[vwContratacion_Ingresos300K_2019]
AS
SELECT	CodCentro, CodOferta      
FROM    OPENQUERY(SIC, 'SELECT (CDCEN) as CodCentro, (CDOFT) as CodOferta, FECHAD FROM S44DD901.ICOMERF.IC09AP WHERE TVEN>=300000 AND FECHAD>=''1190000'' AND Adele=''S''') 

UNION

SELECT  CodCentro, CodOferta
FROM OfertasSQL 
WHERE  Adjudicada='S' AND ImporteContratado>=300000 AND AñoAdjudicacion=2019
