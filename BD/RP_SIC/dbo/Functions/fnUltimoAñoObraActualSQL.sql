create FUNCTION [dbo].[fnUltimoAñoObraActualSQL] ()
RETURNS int
AS  
BEGIN

DECLARE @vUltimoAño as int

SELECT TOP 1 @vUltimoAño=[Año]
FROM [RP_SIC].[dbo].[ObrasActualesSQL]
order by Año desc
	
RETURN(@vUltimoAño)

END
