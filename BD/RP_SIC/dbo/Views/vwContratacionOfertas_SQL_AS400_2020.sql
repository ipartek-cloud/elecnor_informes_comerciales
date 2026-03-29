

CREATE VIEW [dbo].[vwContratacionOfertas_SQL_AS400_2020]
AS
SELECT       CodCentro, CODCLIENTE, CODOFER
FROM            (SELECT      CodCentro,CODCLIENTE,CODOFER
                          FROM            dbo.vwContratacionOfertas_AS400_2020
                          UNION
                          SELECT       CodCentro,CodCliente, CodOferta
                          FROM            dbo.vwContratacionOfertas_SQL_2020) AS vw


