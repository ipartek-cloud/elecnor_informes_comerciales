create FUNCTION [dbo].[fnFormatoMoneda] (@pCantidad float)
	RETURNS float
AS  

BEGIN

	DECLARE @vCantidad float
	
	SET @vCantidad=cast(isnull(@pCantidad,0)as decimal(16,2))

	RETURN @vCantidad

END
