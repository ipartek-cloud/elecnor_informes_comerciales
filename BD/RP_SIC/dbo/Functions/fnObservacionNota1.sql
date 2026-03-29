create FUNCTION [dbo].[fnObservacionNota1] ()
RETURNS varchar(50)
AS  
BEGIN

	DECLARE @Observacion_Nota as varchar(50)

	SELECT @Observacion_Nota= [Observacion_Nota1]
	FROM [dbo].[WEB_Parametros]
	
	RETURN(isnull(@Observacion_Nota,''))

END
