CREATE FUNCTION [dbo].[fnNombreCentro] (@CodCentro varchar(3))
RETURNS varchar(30)
AS  
BEGIN

	DECLARE @NombreCentro as varchar(30)

	SELECT @NombreCentro= NombreCentro
	FROM [dbo].[Sumarigrama]
	WHERE @CodCentro=CodCentro
	
	RETURN(isnull(@NombreCentro,''))

END
