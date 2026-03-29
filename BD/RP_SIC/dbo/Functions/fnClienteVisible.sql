CREATE FUNCTION [dbo].[fnClienteVisible] (@pNombreCliente varchar(100))
RETURNS bit
AS  
BEGIN

DECLARE @vClienteVisible as bit

SET @vClienteVisible=0 

IF(isnull(@pNombreCliente,'')<>'')
	BEGIN
		SELECT @vClienteVisible=Visible FROM ClientesSQL WHERE NomAgrupado=@pNombreCliente
	END	
	
RETURN(@vClienteVisible)

END
