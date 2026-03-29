create FUNCTION [dbo].[fnOfertaMesActual] (@pMes int, @pMesActual int)
RETURNS varchar(20)
AS  
BEGIN

DECLARE @OfertaMesActual as varchar(20)

IF(@pMes = @pMesActual)
	BEGIN
		SET @OfertaMesActual=dbo.FMes(@pMes)
	END
ELSE
	BEGIN
		SET @OfertaMesActual='Anterior'
	END	
	
RETURN(@OfertaMesActual)

END
