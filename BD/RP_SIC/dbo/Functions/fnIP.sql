CREATE FUNCTION [dbo].[fnIP] (@pImporte1 float, @pImporte2 float,@pMes int)
RETURNS float
AS  
BEGIN

DECLARE @vIP as float

SET @vIP=0

IF(isnull(@pImporte2,0)<>0 AND @pMes<>0)
	BEGIN
		 SET @vIP=@pImporte1/(@pImporte2*@pMes)
	END
	
RETURN(@vIP)

END
