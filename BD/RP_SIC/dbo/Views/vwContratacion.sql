


CREATE VIEW [dbo].[vwContratacion]
AS

SELECT        CodCentro, CodOferta
FROM            OPENQUERY(SIC, 
                         'SELECT (CDCEN) as CodCentro, (CDOFT) as CodOferta, FECHAD FROM S44DD901.ICOMERF.IC09AP WHERE  Adele=''S''')
UNION
SELECT        CodCentro, CodOferta
FROM            OfertasSQL
WHERE        Adjudicada = 'S'

