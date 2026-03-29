create FUNCTION [dbo].[fnNombreCliente] (@pCodCliente varchar(8))
RETURNS varchar(100)
AS  
BEGIN

	DECLARE @vNombreCliente as varchar(100)

	SELECT @vNombreCliente=NombreCliente FROM ClientesSQL WHERE CodCliente=@pCodCliente
	
	RETURN(isnull(@vNombreCliente,''))

END
