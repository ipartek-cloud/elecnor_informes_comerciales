create FUNCTION [dbo].[fnContratacion_Comentario] ()
	RETURNS varchar (1000)
AS  

BEGIN

	DECLARE @Contratacion_Comentario as varchar(1000)

	SELECT @Contratacion_Comentario=Contratacion_Comentario FROM dbo.WEB_Parametros
	
	return @Contratacion_Comentario

END