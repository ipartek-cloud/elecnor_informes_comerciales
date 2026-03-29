create FUNCTION [dbo].[fnImporteContratacion_AcumuladoMesAnterior] (@pFecha datetime, @pAño int,@pMes int,@pImporte numeric(9,0))
RETURNS float
AS  
BEGIN

DECLARE @ImporteContratacion_AcumuladoMesAnterior as numeric(9,0)

SET @ImporteContratacion_AcumuladoMesAnterior=0

IF((Year(@pFecha)= @pAño) AND (month(@pFecha)<=@pMes-1))
	BEGIN
		 SET @ImporteContratacion_AcumuladoMesAnterior=@pImporte
	END
	
RETURN(@ImporteContratacion_AcumuladoMesAnterior)

END
