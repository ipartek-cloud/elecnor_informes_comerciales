


create FUNCTION [dbo].[fnImporteCartera_CarteraDetallada] (@pUsuario varchar(50),@pTipo varchar(1))
RETURNS float
AS  
BEGIN

	DECLARE @ImporteCartera as float

	SET @ImporteCartera=0

	SELECT @ImporteCartera=[ImporteCartera]
	FROM [dbo].[vwCarteraDetalladaUsuarioCentro_ImporteCartera]
	WHERE [Usuario]=@pUsuario AND [Tipo]=@pTipo
	
	RETURN(isnull(@ImporteCartera,0))

END
