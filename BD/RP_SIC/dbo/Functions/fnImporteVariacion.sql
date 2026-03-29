CREATE FUNCTION [dbo].[fnImporteVariacion] (@pImporte1 float, @pImporte2 float)
RETURNS float
AS  
BEGIN

DECLARE @vImporteVariacion as float

SET @vImporteVariacion=0

IF(isnull(@pImporte2,0)>0)
	BEGIN
		 SET @vImporteVariacion=((@pImporte1-@pImporte2)/@pImporte2)*100
	END
	
RETURN(@vImporteVariacion)

END
