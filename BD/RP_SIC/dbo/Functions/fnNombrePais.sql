CREATE FUNCTION [dbo].[fnNombrePais] (@CodAutonomia int, @NMPro as varchar(16))
RETURNS varchar(20)
AS  
BEGIN

DECLARE @Pais as varchar(20)

IF(@CodAutonomia<>19)
	BEGIN
		SET @Pais=''
	END
ELSE
	BEGIN
		SET @Pais=' (' + rtrim(@NMPro) + ')'
	END	
	
RETURN(@Pais)

END
