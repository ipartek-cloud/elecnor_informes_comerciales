create FUNCTION [dbo].[fnCarteraDiferidaAnual] (@MontoAnual float, @Contrat float)
RETURNS float
AS  
BEGIN

DECLARE @CarteraDiferidaAnual as float

SET @CarteraDiferidaAnual=@MontoAnual-@Contrat

IF(@CarteraDiferidaAnual<0)
	BEGIN
		 SET @CarteraDiferidaAnual=0
	END
	
RETURN(@CarteraDiferidaAnual)

END
