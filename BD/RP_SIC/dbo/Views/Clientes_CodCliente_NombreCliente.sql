CREATE VIEW [dbo].[Clientes_CodCliente_NombreCliente]
AS
	SELECT    CodCliente,NombreCliente
	FROM    OPENQUERY(SIC,'
			SELECT AUX as CodCliente,NAUX as NombreCliente FROM S44DD901.FICOS.CGA06AP AS Clientes
			WHERE CIA = ''001'' AND CNAUX = ''C''
			')