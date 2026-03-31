

CREATE VIEW [dbo].[vwContratacion_2016]
AS
SELECT	CodCentro, CodOferta      
FROM    OPENQUERY(SIC, 'SELECT DIGITS(CDCEN) as CodCentro, DIGITS(CDOFT) as CodOferta, FECHAD FROM S44DD901.ICOMERF.IC09AP WHERE FECHAD>=''1160000'' AND Adele=''S''') 

UNION

SELECT  CodCentro, CodOferta
FROM OfertasSQL 
WHERE  Adjudicada='S' AND AñoAdjudicacion>=2016