CREATE FUNCTION [dbo].[fnNumOfertas3000k_Año_Centro] (@pAño int, @pCodCentro decimal(3,0))
RETURNS int
AS  
BEGIN

	DECLARE @Num as int

	IF @pAño=2016
		SELECT @Num= COUNT(codoferta) FROM vwContratacion_Ingresos300K_2016 WHERE CodCentro=@pCodCentro
	ELSE IF @pAño=2018
		SELECT @Num= COUNT(codoferta) FROM vwContratacion_Ingresos300K_2018 WHERE CodCentro=@pCodCentro
	ELSE IF @pAño=2019
		SELECT @Num= COUNT(codoferta) FROM vwContratacion_Ingresos300K_2019 WHERE CodCentro=@pCodCentro

	RETURN(isnull(@Num,0))

END
