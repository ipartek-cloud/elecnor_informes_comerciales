CREATE FUNCTION [dbo].[fnFormatFecha]
(
	@Fecha int
)
RETURNS varchar(5)
AS
BEGIN

	DECLARE @FormatFecha varchar(5)

	SET @FormatFecha=''

	IF isnull(@Fecha,0)<>0
		BEGIN
			SET @FormatFecha=dbo.fnFormat(@Fecha,4)
			SET @FormatFecha=right(@FormatFecha,2) +'_'+ left(@FormatFecha,2) 
		END

	RETURN @FormatFecha

END
