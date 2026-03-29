
CREATE FUNCTION [dbo].[fnQuitar1999] (@pFecha datetime)
	RETURNS datetime
AS  

BEGIN

	DECLARE @fecha datetime

	IF @pFecha='1/1/1999' 
		BEGIN
			SET @fecha= null
		END
	ELSE
		BEGIN
			set @fecha= @pFecha
		END	

		return @fecha

END

