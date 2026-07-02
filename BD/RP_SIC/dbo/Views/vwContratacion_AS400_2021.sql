

CREATE VIEW [dbo].[vwContratacion_AS400_2021]
AS
SELECT        Contratacion_AS400.AÑOAD AS Año, Contratacion_AS400.MESAD AS Mes, Contratacion_AS400.CT AS CodCentro, 
                         Contratacion_AS400.CODOFER, Contratacion_AS400.DESOFER, Contratacion_AS400.CODCLIENTE, 
                         dbo.ClientesSQL.NomAgrupado AS NOMCLIENTE, Contratacion_AS400.IMPAD AS Importe
FROM            OPENQUERY(SIC, 
                         'SELECT  AÑOAD, MESAD , CT , CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, IMPAD FROM S44DD901.ICOMERF.OFERREGU 
						 WHERE AÑOAD = 2021 AND ADJUDICADA = ''S'' ')
                          AS Contratacion_AS400 LEFT OUTER JOIN
                         dbo.ClientesSQL ON Contratacion_AS400.CODCLIENTE = dbo.ClientesSQL.CodCliente