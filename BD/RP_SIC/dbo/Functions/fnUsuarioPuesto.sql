
CREATE FUNCTION [dbo].[fnUsuarioPuesto] (@pUsuario varchar(50))
RETURNS varchar(5)
AS  
BEGIN

	DECLARE @vUsuarioPuesto varchar(5)
	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@pUsuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@pUsuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@pUsuario

	SET @vUsuarioPuesto=''

	SELECT @vUsuarioPuesto=Puesto FROM WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha
		
	RETURN(@vUsuarioPuesto)

END
