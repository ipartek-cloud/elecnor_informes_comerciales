

CREATE VIEW [dbo].[Clientes_antes]
AS
SELECT     *
FROM         SIC.S44DD901.FICOS.CGA06AP AS Clientes
where (((CIA)='001') AND ((CNAUX)='C'))


