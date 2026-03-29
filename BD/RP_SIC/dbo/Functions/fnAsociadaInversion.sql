create FUNCTION [dbo].[fnAsociadaInversion] (@CodOferta int)
RETURNS varchar(20)
AS  
BEGIN

DECLARE @AsociadaInversion as varchar(20)

IF(isnull(@CodOferta,'')='')
	BEGIN
		SET @AsociadaInversion=''
	END
ELSE
	BEGIN
		SET @AsociadaInversion='Asociada Inversión'
	END	
	
RETURN(@AsociadaInversion)

END
