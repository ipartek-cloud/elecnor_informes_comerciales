create FUNCTION [dbo].[fnCodNota2] ()
RETURNS varchar(5)
AS  
BEGIN

	DECLARE @CodNota as varchar(5)

	SELECT @CodNota= Cod_Nota2
	FROM [dbo].[WEB_Parametros]
	
	RETURN(isnull(@CodNota,''))

END
