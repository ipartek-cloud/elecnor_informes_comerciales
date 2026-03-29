CREATE FUNCTION [dbo].[fnPaises] (@pMercado varchar(50),@pNMPRO varchar(50))
RETURNS varchar(20)
AS  
BEGIN

DECLARE @Paises as varchar(20)

SET @Paises=''

IF(@pMercado='Internacional')
	BEGIN
		SET @Paises=@pNMPRO
	END
	
RETURN(rtrim(@Paises))

END
