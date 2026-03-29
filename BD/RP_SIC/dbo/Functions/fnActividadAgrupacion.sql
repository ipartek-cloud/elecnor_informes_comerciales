
CREATE FUNCTION [dbo].[fnActividadAgrupacion] (@CDAC1 varchar(2), @CDAC2 varchar(2))
RETURNS varchar(100)
AS  
BEGIN

DECLARE @Agrupacion as varchar(100)

SELECT TOP 1 @Agrupacion=Agrupacion FROM ActividadesSQL WHERE CDAC1=@CDAC1 AND CDAC2=@CDAC2
	
RETURN(isnull(@Agrupacion,''))

END