CREATE FUNCTION [dbo].[fnAI] (@pAI numeric(10,0))
RETURNS varchar(2)
AS  
BEGIN

DECLARE @AI as varchar(20)

SET @AI=''

--IF(isnull(@pAI,-1)<>-1 )
IF(isnull(@pAI,0)<>0)
	BEGIN
		SET @AI='AI'
	END
	
RETURN(@AI)

END
