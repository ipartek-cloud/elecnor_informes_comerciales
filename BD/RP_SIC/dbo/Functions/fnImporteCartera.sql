
--fnImporteCarteraOferta(Tipo,CodOferta,ImporteTotal,@pAño,@pMes)

CREATE FUNCTION [dbo].[fnImporteCartera] (@pTipo_I as varchar(1),@pTipo_Contratacion as varchar(1),@pImporteTotal float,@pImporteRegularizacion float)
RETURNS float
AS  
BEGIN

	DECLARE @Importe as float

	SET @Importe=0

	IF @pTipo_I= @pTipo_Contratacion
		BEGIN
			SET @Importe=isnull(@pImporteTotal,0)-isnull(@pImporteRegularizacion,0)				 
		END
 
	RETURN(@Importe)

END
