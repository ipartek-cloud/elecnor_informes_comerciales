CREATE FUNCTION [dbo].[fnCarteraTipoDescripcion] (@Tipo varchar(1))
RETURNS varchar(50)
AS  
BEGIN

	DECLARE @TipoDescripcion as varchar(50)

	SET @TipoDescripcion=''

	IF @Tipo='E'
		BEGIN
			SET @TipoDescripcion='Ejecutado por Elecnor'
		END
	ELSE IF @Tipo='U'
		BEGIN
			SET @TipoDescripcion='Ejecutado en Ute'
		END
	ELSE IF @Tipo='F'
		BEGIN
			SET @TipoDescripcion='Ejecutado por la Filial'
		END
	ELSE IF @Tipo='S'
		BEGIN
			SET @TipoDescripcion='Ejecutado por la Sucursal'
		END

	RETURN(@TipoDescripcion)

END
