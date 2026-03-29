
CREATE VIEW [dbo].[vwContratacionOfertas_SQL_AS400_2018]
AS
SELECT       CodCentro, CODCLIENTE, CODOFER
FROM            (SELECT      CodCentro,CODCLIENTE,CODOFER
                          FROM            dbo.vwContratacionOfertas_AS400_2018
                          UNION
                          SELECT       CodCentro,CodCliente, CodOferta as CODOFER
                          FROM            dbo.vwContratacionOfertas_SQL_2018) AS vw


