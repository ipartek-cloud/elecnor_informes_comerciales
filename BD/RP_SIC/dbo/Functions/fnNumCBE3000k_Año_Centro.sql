create FUNCTION [dbo].[fnNumCBE3000k_Año_Centro] (@pAño int, @pCodCentro decimal(3,0))
RETURNS int
AS  
BEGIN

	DECLARE @Num as int

	IF @pAño=2016
		SELECT @Num= NumCBE FROM vwContratacion_Ingresos300K_2016_CON_Referencias_CON_CBE WHERE CodCentro=@pCodCentro
	ELSE IF @pAño=2018
		SELECT @Num= NumCBE FROM vwContratacion_Ingresos300K_2018_CON_Referencias_CON_CBE WHERE CodCentro=@pCodCentro
	ELSE IF @pAño=2019
		SELECT @Num= NumCBE FROM vwContratacion_Ingresos300K_2019_CON_Referencias_CON_CBE WHERE CodCentro=@pCodCentro

	RETURN(isnull(@Num,0))

END