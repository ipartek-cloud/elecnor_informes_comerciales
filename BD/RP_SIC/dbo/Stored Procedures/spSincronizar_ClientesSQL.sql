CREATE PROCEDURE [dbo].[spSincronizar_ClientesSQL]	 	
		AS
BEGIN
		
		INSERT INTO ClientesSQL (CodCliente,NombreCliente,NomAgrupado,Pais)
		SELECT  dbo.Clientes.AUX, dbo.Clientes.NAUX,dbo.Clientes.NAUX, dbo.Clientes.PAIS
		FROM    dbo.ClientesSQL RIGHT OUTER JOIN
                dbo.Clientes ON dbo.ClientesSQL.CodCliente = dbo.Clientes.AUX
		--WHERE   ISNULL(dbo.ClientesSQL.CodCliente,'') = ''	
		WHERE   dbo.ClientesSQL.CodCliente Is Null
		
		select 0
    
END
