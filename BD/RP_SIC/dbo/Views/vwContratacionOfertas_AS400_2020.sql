

CREATE VIEW [dbo].[vwContratacionOfertas_AS400_2020]
AS
SELECT       CT AS CodCentro,CODCLIENTE, CODOFER
FROM            OPENQUERY(SIC, 
                         'SELECT DISTINCT  CT , CODOFER, CODCLIENTE FROM S44DD901.ICOMERF.OFERREGU WHERE AÑOAD = 2020 AND ADJUDICADA = ''S'' ')
                          AS Contratacion_AS400_2020