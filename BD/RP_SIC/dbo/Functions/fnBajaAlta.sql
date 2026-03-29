create FUNCTION [dbo].[fnBajaAlta] (@Tipo varchar(1))
RETURNS int
AS  
BEGIN

	DECLARE @TipoBajaAlta as int

	SET @TipoBajaAlta=0

	IF @Tipo='B'
		BEGIN
		  SET @TipoBajaAlta=1
		 END

	RETURN(@TipoBajaAlta)

END
