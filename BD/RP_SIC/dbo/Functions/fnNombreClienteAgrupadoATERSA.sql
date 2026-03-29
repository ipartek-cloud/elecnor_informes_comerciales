create FUNCTION [dbo].[fnNombreClienteAgrupadoATERSA] (@pCodCliente varchar(8) ,@pNombreCliente varchar(100))
RETURNS varchar(100)
AS  
BEGIN

	DECLARE @vNombreCliente as varchar(100)

	IF LEFT(ISNULL(@pCodCliente,''),1)='A' AND @pNombreCliente IS NULL
		BEGIN
			SET @vNombreCliente='Pequeño Cliente Atersa'
		END
	ELSE
		BEGIN	
			SET @vNombreCliente=@pNombreCliente
		END
	
	RETURN(isnull(@vNombreCliente,''))

END