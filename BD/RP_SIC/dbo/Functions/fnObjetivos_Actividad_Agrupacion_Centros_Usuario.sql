
CREATE FUNCTION [dbo].[fnObjetivos_Actividad_Agrupacion_Centros_Usuario] (@pAño int,@pAgrupacion varchar(100), @pCentros varchar(8000))
RETURNS float
AS  
BEGIN

	DECLARE @Objetivos as float
	
	SELECT @Objetivos=sum(importe)
	FROM  [dbo].[fnObjetivos_Actividad_Centros_Usuario](@pAño,@pCentros)
	WHERE Agrupacion=@pAgrupacion
	
	RETURN(isnull(@Objetivos,0))

END