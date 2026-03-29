
create FUNCTION [dbo].[fnAccesoTendencias] (@pUsuario varchar(50))
RETURNS bit
AS  
BEGIN

	DECLARE @vAccesoTendencias bit
	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@pUsuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@pUsuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@pUsuario

	SET @vAccesoTendencias=0

	SELECT @vAccesoTendencias=Acceso_Tendencias FROM WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha
		
	RETURN(@vAccesoTendencias)

END
