
CREATE VIEW [dbo].[vwContratacionOfertas_SQL_AS400_2019]
AS
SELECT       CodCentro, CODCLIENTE, CODOFER
FROM            (SELECT      CodCentro,CODCLIENTE,CODOFER
                          FROM            dbo.vwContratacionOfertas_AS400_2019
                          UNION
                          SELECT       CodCentro,CodCliente, CodOferta
                          FROM            dbo.vwContratacionOfertas_SQL_2019) AS vw

