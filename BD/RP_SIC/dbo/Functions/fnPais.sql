create FUNCTION [dbo].[fnPais] (@CodAutonomia int)
RETURNS varchar(20)
AS  
BEGIN

DECLARE @Pais as varchar(20)

SET @Pais='Internacional'

IF(@CodAutonomia<>19)
	BEGIN
		SET @Pais='Nacional'
	END
	
RETURN(@Pais)

END
