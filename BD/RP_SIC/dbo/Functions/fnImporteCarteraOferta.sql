
--fnImporteCarteraOferta(Tipo,CodOferta,ImporteTotal,@pAño,@pMes)

CREATE FUNCTION [dbo].[fnImporteCarteraOferta] (@pTipo_I as varchar(1),@pTipo_Contratacion as varchar(1),@pCodOferta numeric(10,0),@pImporteTotal float, @pAño int, @pMes int)
RETURNS float
AS  
BEGIN

	DECLARE @ImporteCartera as float

	SET @ImporteCartera=0

	IF @pTipo_I= @pTipo_Contratacion
		BEGIN
			SELECT @ImporteCartera=@pImporteTotal-sum(Impre)
			FROM Regularizaciones
			WHERE cdoft=@pCodOferta AND 
				  year(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR))=@pAño AND
				  Month(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR))>@pMes
				 
		END
 
	RETURN(isnull(@ImporteCartera,0))

END
