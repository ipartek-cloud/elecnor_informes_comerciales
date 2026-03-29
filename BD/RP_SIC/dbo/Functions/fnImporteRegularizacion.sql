create FUNCTION [dbo].[fnImporteRegularizacion] (@pCodCentro int, @pCodOferta int)
RETURNS float
AS  
BEGIN

	DECLARE @vImporteRegularizacion as float

	SET @vImporteRegularizacion=0

	SELECT @vImporteRegularizacion=sum(Impre)
	FROM Regularizaciones 
	WHERE cdcen=@pCodCentro and cdoft=@pCodOferta
	
	RETURN(isnull(@vImporteRegularizacion,0))

END
