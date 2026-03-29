create FUNCTION [dbo].[fnImporteContratacion_Mensual_Adhorna] (@Año int,@Mes int, @pAño int,@pMes int,@pImporte numeric(9,0))
RETURNS float
AS  
BEGIN

DECLARE @ImporteContratacion_Mensual_Adhorna as numeric(9,0)

SET @ImporteContratacion_Mensual_Adhorna=0

IF(@Año= @pAño AND @Mes=@pMes)
	BEGIN
		 SET @ImporteContratacion_Mensual_Adhorna=@pImporte
	END
	
RETURN(@ImporteContratacion_Mensual_Adhorna)

END
