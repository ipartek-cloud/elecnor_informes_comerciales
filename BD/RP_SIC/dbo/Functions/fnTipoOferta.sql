create FUNCTION [dbo].[fnTipoOferta] (@Tipo varchar(10))
RETURNS varchar(20)
AS  
BEGIN

DECLARE @TipoOferta as varchar(20)

Set @TipoOferta = CASE @Tipo
		WHEN 'E' THEN 'ELECNOR'
		WHEN 'F' THEN 'FILIALES'
		WHEN 'U' THEN 'UTES'
		WHEN 'S' THEN 'SUCURSALES'
		ELSE '' END

RETURN(@TipoOferta)

END
