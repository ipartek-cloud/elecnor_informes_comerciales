
CREATE FUNCTION [dbo].[fnAgrupacionCentro] (@pCodCentro numeric(3,0),@pNombreCentro varchar(50))
RETURNS varchar(50)
AS  
BEGIN

	DECLARE @vAgrupacionCentro varchar(50)

	SET @vAgrupacionCentro=''

	IF (@pCodCentro=843 OR @pCodCentro=857 OR @pCodCentro=849 OR @pCodCentro=25 OR @pCodCentro=74 OR @pCodCentro=78 OR @pCodCentro=829)
		BEGIN
			SET @vAgrupacionCentro=@pNombreCentro
		END
		
	RETURN(@vAgrupacionCentro)

END
