create FUNCTION [dbo].[fnGerentesMarca_CodCentro] (@pCodCentro numeric(3,0))
RETURNS int
AS  
BEGIN

	DECLARE @Num as int

	SELECT @Num= count(CodCentro) FROM [dbo].[CentrosGerentesSQL] WHERE CodCentro=@pCodCentro and Marca=1
	
	RETURN(isnull(@Num,0))

END