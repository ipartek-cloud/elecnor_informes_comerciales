CREATE PROCEDURE [dbo].[spActualizar_Clientes_Cartera_Diferida]
		AS
BEGIN
		
	BEGIN TRY
	
		SELECT CD.CodOferta, CD.CodCliente as CodCliente_CD,O.CODCLIENTE as CodCliente_AS400,CD.NomAgrupado as NomAgrupado_CD,O.NomAgrupado as NomAgrupado_AS400
		FROM vwOfertas_Clientes as O INNER JOIN Cart_DiferidaOfertasContratos_2016SQL as CD ON O.CODOFER=CD.CodOferta
		WHERE  CD.CodCliente<>O.CODCLIENTE

		UPDATE Cart_DiferidaOfertasContratos_2016SQL
		SET CodCliente=O.CODCLIENTE, NomAgrupado=O.NomAgrupado
		FROM vwOfertas_Clientes as O INNER JOIN Cart_DiferidaOfertasContratos_2016SQL as CD ON O.CODOFER=CD.CodOferta
		WHERE  CD.CodCliente<>O.CODCLIENTE
   
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER (), ERROR_MESSAGE()
	END CATCH 
	   
END
