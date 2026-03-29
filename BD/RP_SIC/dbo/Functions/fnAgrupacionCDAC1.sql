create FUNCTION [dbo].[fnAgrupacionCDAC1] (@pAgrupacion varchar(100))
RETURNS varchar(2)
AS  
BEGIN

DECLARE @CDAC1 as varchar(2)

SET @CDAC1='00'

SELECT @CDAC1=CDAC1 FROM dbo.ActividadesSQL WHERE @pAgrupacion=Agrupacion
	
RETURN(@CDAC1)

END
