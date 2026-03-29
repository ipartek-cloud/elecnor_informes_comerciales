create FUNCTION [dbo].[fnImporteContratacion_MesActual] (@pFecha datetime, @pAño int,@pMes int,@pImporte numeric(9,0))
RETURNS float
AS  
BEGIN

DECLARE @ImporteContratacion_AñoAnterior as numeric(9,0)

SET @ImporteContratacion_AñoAnterior=0

IF((Year(@pFecha)= @pAño) AND (month(@pFecha)=@pMes))
	BEGIN
		 SET @ImporteContratacion_AñoAnterior=@pImporte
	END
	
RETURN(@ImporteContratacion_AñoAnterior)

END
