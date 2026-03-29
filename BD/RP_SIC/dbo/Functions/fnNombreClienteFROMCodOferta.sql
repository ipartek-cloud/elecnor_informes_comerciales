
CREATE FUNCTION [dbo].[fnNombreClienteFROMCodOferta](
	
	@CodOferta varchar(50)
)
RETURNS varchar(100)
AS
BEGIN

	DECLARE @NombreCliente varchar(100)

	IF isnull(@CodOferta,'')=''		
		SET @NombreCliente=''		
	ELSE
		SELECT @NombreCliente=isnull(NombreCliente,'') FROM vwObrasActualesSQL_Enlaces_CodOferta_Cliente WHERE @CodOferta=cdoft	

	RETURN  @NombreCliente
END