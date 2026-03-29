
create FUNCTION [dbo].[fnImporteContratadoAgrupacion] (@pUsuario varchar(50), @pAgrupacion varchar(50))
RETURNS float
AS  
BEGIN

	DECLARE @Importe as float

	SET @Importe=0

	SELECT @Importe=SUM(ImporteContratado) FROM WEB_ContratacionActividadUsuario WHERE @pUsuario=Usuario AND @pAgrupacion=Agrupacion
 
	RETURN(isnull(@Importe,0))

END