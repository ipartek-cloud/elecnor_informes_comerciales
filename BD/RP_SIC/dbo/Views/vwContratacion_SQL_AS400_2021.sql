

CREATE VIEW [dbo].[vwContratacion_SQL_AS400_2021]
AS
SELECT        TOP (100) PERCENT Mes, CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, ISNULL(importe, 0) AS Importe
FROM            (SELECT        Mes, CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, SUM(Importe) AS importe
                          FROM            dbo.vwContratacion_AS400_2021
                          GROUP BY Mes, CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE
                          UNION
                          SELECT        Mes, CodCentro, CODOFER, DESOFER, CodCliente, NOMCLIENTE, Importe
                          FROM            dbo.vwContratacion_SQL_2021) AS vw


