

CREATE VIEW [dbo].[vwRegularizaciones_2021_Sup]
AS
SELECT        CDCEN, CDOFT, IMPRE, AR, MR
FROM            OPENQUERY(SIC, 
                         ' SELECT CDCEN, CDOFT, IMPRE, substr( digits(dec(19000000+FECHAR,8,0)), 1, 4 ) AR,substr( digits(dec(19000000+FECHAR,8,0)), 5, 2) MR
		FROM S44DD901.ICOMERF.IC10AP
                                WHERE substr( digits(dec(19000000+FECHAR,8,0)), 1, 4 )>=2021')
                          AS vw