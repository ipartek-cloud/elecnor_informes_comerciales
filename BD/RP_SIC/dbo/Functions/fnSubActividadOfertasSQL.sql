CREATE FUNCTION [dbo].[fnSubActividadOfertasSQL] (@pCodAct1 varchar(2),@pCodAct2 varchar(2),@pReparto bit)
RETURNS varchar(2)
AS  
BEGIN

DECLARE @vCodAct2 varchar(2)

IF @pReparto=0 AND @pCodAct1='09' AND @pCodAct2='50'	 -- Espacio o Mantenimiento
	BEGIN
		SET @vCodAct2='50'
	END	
ELSE
	BEGIN
		SET @vCodAct2='00'
	END
	
RETURN(@vCodAct2)

END