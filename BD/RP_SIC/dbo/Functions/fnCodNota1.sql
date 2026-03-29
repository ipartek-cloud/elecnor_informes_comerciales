create FUNCTION [dbo].[fnCodNota1] ()
RETURNS varchar(5)
AS  
BEGIN

	DECLARE @CodNota as varchar(5)

	SELECT @CodNota= Cod_Nota1
	FROM [dbo].[WEB_Parametros]
	
	RETURN(isnull(@CodNota,''))

END
