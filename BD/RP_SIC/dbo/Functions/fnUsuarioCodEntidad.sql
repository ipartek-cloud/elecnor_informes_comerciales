

CREATE FUNCTION [dbo].[fnUsuarioCodEntidad] (@pUsuario varchar(50))
RETURNS varchar(3)
AS  
BEGIN

	DECLARE @vUsuarioCodEntidad varchar(3)
	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@pUsuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@pUsuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@pUsuario

	SET @vUsuarioCodEntidad=''

	SELECT @vUsuarioCodEntidad=CodEntidad FROM WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha
		
	RETURN(@vUsuarioCodEntidad)

END
