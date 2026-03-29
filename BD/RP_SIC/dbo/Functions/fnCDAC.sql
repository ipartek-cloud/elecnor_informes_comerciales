CREATE FUNCTION [dbo].[fnCDAC] (@CDAC1 varchar(2),@CDAC2 varchar(2))
RETURNS varchar(4)
AS  
BEGIN

	DECLARE @CDAC as varchar(4)

	SET @CDAC=''

	IF @CDAC1 IN ('04', '06', '09')
		SET @CDAC = @CDAC1 +  @CDAC2
	ELSE
		BEGIN
			IF @CDAC1='07' 
				SET @CDAC1='08'
			ELSE
			BEGIN
				IF @CDAC1+@CDAC2='0229'
					SET @CDAC1='01'
			END
			SET @CDAC = @CDAC1 + '00'
		END

	RETURN(@CDAC)

END
