create FUNCTION [dbo].[fnCodNota3] ()
RETURNS varchar(5)
AS  
BEGIN

	DECLARE @CodNota as varchar(5)

	SELECT @CodNota= Cod_Nota3
	FROM [dbo].[WEB_Parametros]
	
	RETURN(isnull(@CodNota,''))

END
