CREATE FUNCTION [dbo].[fnActividadDescripcion] (@CDAC1 varchar(2), @CDAC2 varchar(2))
RETURNS varchar(100)
AS  
BEGIN

DECLARE @Agrupacion as varchar(100)

SELECT @Agrupacion=DSACT FROM ActividadesSQL WHERE @CDAC1=CDAC1 AND @CDAC2=CDAC2
	
RETURN(isnull(@Agrupacion,''))

END
