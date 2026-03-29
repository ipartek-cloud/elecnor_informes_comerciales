CREATE FUNCTION [dbo].[fnImporteContratacion_Acumulado_Adhorna] (@Año int,@Mes int, @pAño int,@pMes int,@pImporte numeric(9,0))
RETURNS float
AS  
BEGIN

DECLARE @ImporteContratacion_AñoAnterior as numeric(9,0)

SET @ImporteContratacion_AñoAnterior=0

IF(@Año= @pAño) AND (@Mes<=@pMes)
	BEGIN
		 SET @ImporteContratacion_AñoAnterior=@pImporte
	END
	
RETURN(@ImporteContratacion_AñoAnterior)

END
