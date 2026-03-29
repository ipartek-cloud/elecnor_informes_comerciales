create FUNCTION [dbo].[fnUltimoMesObraActualSQL] ()
RETURNS int
AS  
BEGIN

DECLARE @vUltimoMes as int

SELECT TOP 1 @vUltimoMes=[Mes]
FROM [RP_SIC].[dbo].[ObrasActualesSQL]
order by Año desc, Mes desc
	
RETURN(@vUltimoMes)

END
