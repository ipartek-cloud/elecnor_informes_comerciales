CREATE FUNCTION [dbo].[fnLiteralSIN] (@pTipo varchar(1), @pTotalObrasOferta int)
RETURNS varchar(50)
AS  
BEGIN

DECLARE @Literal as varchar(50)

SET @Literal=''

IF(isnull(@pTipo,'')='F' OR isnull(@pTipo,'')='U' OR isnull(@pTipo,'')='S')
	BEGIN
		SET @Literal='Sin Datos Producción'
	END
ELSE IF (isnull(@pTotalObrasOferta,0)=0)
	BEGIN
		SET @Literal='Sin Obra Asociada'
	END
	
RETURN(@Literal)

END
