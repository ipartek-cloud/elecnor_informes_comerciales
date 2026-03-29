create FUNCTION [dbo].[fnImporteObjetivos] (@pCodCentro numeric(3,0),@pAño int)
RETURNS  numeric(9,0)
AS  
BEGIN

DECLARE @ImporteObjetivos numeric(9,0)

SELECT @ImporteObjetivos=Importe 
FROM dbo.ObjetivosActividadSQL 
WHERE CodCentro=@pCodCentro and Año=@pAño
	
RETURN(isnull(@ImporteObjetivos,0))

END
