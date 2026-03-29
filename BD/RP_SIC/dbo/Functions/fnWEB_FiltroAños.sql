
CREATE FUNCTION fnWEB_FiltroAños ()
RETURNS 
@t TABLE (Año int )
AS
BEGIN
	DECLARE @Año as int = YEAR(GETDATE())
	DECLARE @i as int = 2014

	WHILE (@i <= @Año)
	BEGIN
		INSERT INTO @t VALUES(@i)
		SET @i = @i + 1
	END
	
	RETURN 
END
