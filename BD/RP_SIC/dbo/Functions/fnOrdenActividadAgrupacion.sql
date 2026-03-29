create FUNCTION [dbo].[fnOrdenActividadAgrupacion] (@pAgrupacion varchar(100))
RETURNS int
AS  
BEGIN

DECLARE @vOrden int

SET @vOrden=0

SELECT @vOrden=Orden FROM ActividadesSQL WHERE Agrupacion=@pAgrupacion
	
RETURN(@vOrden)

END
