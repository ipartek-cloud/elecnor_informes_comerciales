
CREATE FUNCTION [dbo].[fnObjetivos_Actividad_Agrupacion] (@pAño int,@pAgrupacion varchar(100))
RETURNS float
AS  
BEGIN

DECLARE @Objetivos as float
Declare @vCDAC as varchar(4)

SET @Objetivos=0

SELECT @Objetivos=sum(importe)
FROM [RP_SIC].[dbo].[vwObjetivosActividadAgrupacion]
WHERE Año=@pAño and Agrupacion=@pAgrupacion
	
RETURN(isnull(@Objetivos,0))

END