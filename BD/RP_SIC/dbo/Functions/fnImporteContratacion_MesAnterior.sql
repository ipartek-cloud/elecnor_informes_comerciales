create FUNCTION [dbo].[fnImporteContratacion_MesAnterior] (@pFecha datetime, @pAño int,@pMes int,@pImporte numeric(9,0))
RETURNS float
AS  
BEGIN

DECLARE @ImporteContratacion_MesAnterior as numeric(9,0)

SET @ImporteContratacion_MesAnterior=0

IF((Year(@pFecha)= @pAño) AND (month(@pFecha)=@pMes-1))
	BEGIN
		 SET @ImporteContratacion_MesAnterior=@pImporte
	END
	
RETURN(@ImporteContratacion_MesAnterior)

END
