CREATE FUNCTION [dbo].[fnEnlaces] (@pUno bit, @pUsuario varchar(10))
RETURNS
 @CO005BP TABLE (
	  CTRO char(3),
	  OBRA char(3),
	  OBRAL char(2),
	  CDOFT numeric(10,0),
	  FechaApertura numeric(4,0),
	  FechaCierre numeric(4,0)
 )
AS
BEGIN

  IF @pUno=1
	  INSERT INTO @CO005BP(CTRO,OBRA,OBRAL,CDOFT, FechaApertura, FechaCierre) 
	  SELECT CTRO,OBRA,OBRAL,CDOFT, FechaApertura, FechaCierre FROM CO005BP WHERE Usuario=@pUsuario
  ELSE
	  INSERT INTO @CO005BP(CTRO,OBRA,OBRAL,CDOFT, FechaApertura, FechaCierre) 
	  SELECT CTRO,OBRA,OBRAL,CDOFT, FechaApertura, FechaCierre FROM CO005BP WHERE Usuario=@pUsuario AND CDOFT<>1
  
 RETURN

END
