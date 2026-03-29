CREATE FUNCTION [dbo].[fnObra] (@TipoObra varchar(1),@Obra varchar(6),@ObraL varchar(2))
RETURNS varchar(10)
AS  
BEGIN

	DECLARE @Obras as varchar(10)

	IF @TipoObra<>'F'
		SET @Obras='-'
	ELSE
		SET @Obras=' '

	IF isnull(@Obra,'')<>''
		BEGIN
			SET @Obras='-'+ @Obra +isnull(@ObraL,'') +' '
		END
			
	RETURN(@Obras)

END
