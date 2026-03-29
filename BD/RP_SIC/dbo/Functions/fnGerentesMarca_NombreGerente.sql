create FUNCTION [dbo].[fnGerentesMarca_NombreGerente] (@pNombreGerente varchar(100))
RETURNS int
AS  
BEGIN

	DECLARE @Num as int

	SELECT @Num= count(CodCentro) FROM [dbo].[CentrosGerentesSQL] WHERE NombreGerente=@pNombreGerente and Marca=1
	
	RETURN(isnull(@Num,0))

END