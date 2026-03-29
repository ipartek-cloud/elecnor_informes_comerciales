create FUNCTION [dbo].[fnUltimaOcurrenciaCaracter] (@pCadena varchar(200) ,@pCompare varchar(1))
	RETURNS varchar (100)
AS  

BEGIN

	DECLARE @fnUltimaOcurrenciaCaracter varchar(100)	
	DECLARE @Caracter nvarchar(1)	
	DECLARE @Longitud int
	DECLARE @Posicion int
	DECLARE @I int
	
	SET @I =0
	SET @Posicion =0
	
	IF  ISNULL(@pCadena,'')='' or ISNULL(@pCompare,'')=''
		BEGIN
			Return ''
		END
		
	SET @pCadena= REPLACE(@pCadena,'#','')
	SET @Longitud= LEN(@pCadena)
	
	WHILE (@I) < @Longitud
		BEGIN
			SET @Caracter= SUBSTRING(@pCadena,@I+1,1)
			IF @Caracter= @pCompare 
				BEGIN
					SET @Posicion=@I+1		
				END	
			SET @I=@I+1		
		END
		
	IF @Posicion>0
		SET @fnUltimaOcurrenciaCaracter=  SUBSTRING(@pCadena,@Posicion+1,@Longitud-@Posicion)
	ELSE
		SET @fnUltimaOcurrenciaCaracter=''
		
	return @fnUltimaOcurrenciaCaracter

END
