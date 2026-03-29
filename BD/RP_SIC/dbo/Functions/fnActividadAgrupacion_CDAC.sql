
create FUNCTION [dbo].[fnActividadAgrupacion_CDAC] (@CDAC1 varchar(2), @CDAC2 varchar(2))
RETURNS varchar(100)
AS  
BEGIN

DECLARE @Agrupacion as varchar(100)
DECLARE @vCDAC as varchar(4)

SET @vCDAC=[dbo].[fnCDAC](@CDAC1,@CDAC2)

SELECT TOP 1 @Agrupacion=Agrupacion FROM ActividadesSQL WHERE @vCDAC=[dbo].[fnCDAC](CDAC1,CDAC2)
	
RETURN(isnull(@Agrupacion,''))

END