CREATE FUNCTION [dbo].[fnCarteraPdteProducirCentro] (@Año int,@Mes int,@CodCentro varchar(3))
RETURNS float
AS  
BEGIN

	DECLARE @Importe as float

	SELECT @Importe= Importe
	FROM [dbo].[CarteraPdteProducirSQL]
	WHERE @Año=Año AND @Mes=Mes AND @CodCentro=CodCentro
	
	RETURN(round(isnull(@Importe,0),0))

END
