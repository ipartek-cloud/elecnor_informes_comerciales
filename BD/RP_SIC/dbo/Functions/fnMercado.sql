
CREATE FUNCTION [dbo].[fnMercado] (@pMercado varchar(1))
RETURNS varchar(20)
AS  
BEGIN

DECLARE @Mercado as varchar(20)

SET @Mercado='Internacional'

IF(@pMercado='N')
	BEGIN
		SET @Mercado='Nacional'
	END
	
RETURN(@Mercado)

END
