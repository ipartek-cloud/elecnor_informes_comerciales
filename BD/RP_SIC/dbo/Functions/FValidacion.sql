create FUNCTION [dbo].[FValidacion] (@Nombre varchar(10),@Contraseña varchar(10))
RETURNS bit
AS  
BEGIN

DECLARE @vValidacion as bit
DECLARE @NumReg as integer

--SELECT @NumReg=count(idUsuario)
--FROM dbo.Usuarios
--WHERE Nombre=@Nombre AND Contraseña=@Contraseña 	

IF isnull(@NumReg,0)>0
	SET @vValidacion=1
ELSE
	SET @vValidacion=0

--RETURN @vValidacion
RETURN 1

END