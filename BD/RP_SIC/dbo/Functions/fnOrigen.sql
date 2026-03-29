CREATE FUNCTION [dbo].[fnOrigen] (@pValor bit)
RETURNS varchar(50)
AS  
BEGIN

DECLARE @vOrigen as varchar(50)

SET @vOrigen=''

IF(@pValor=0)
	BEGIN
		SET @vOrigen='Importacion'
	END	
ELSE
	BEGIN
		SET @vOrigen='Reparto'
	END	
	
RETURN(@vOrigen)

END
