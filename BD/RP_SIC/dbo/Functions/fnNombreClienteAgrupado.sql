CREATE FUNCTION [dbo].[fnNombreClienteAgrupado] (@pCodCliente varchar(8) ,@pNombreCliente varchar(100))
RETURNS varchar(100)
AS  
BEGIN

	DECLARE @vNombreCliente as varchar(100)

	IF @pNombreCliente IS NOT NULL
		BEGIN
			SET @vNombreCliente=@pNombreCliente
		END 
	ELSE IF LEFT(ISNULL(@pCodCliente,''),1)='A' AND @pNombreCliente IS NULL
		BEGIN
			SET @vNombreCliente='Pequeño Cliente Atersa'
		END 
	ELSE
		BEGIN	
			SELECT @vNombreCliente=NomAgrupado FROM ClientesSQL WHERE CodCliente=@pCodCliente
		END
	
	RETURN(isnull(@vNombreCliente,''))

END

