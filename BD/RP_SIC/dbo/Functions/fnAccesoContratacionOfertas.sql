CREATE FUNCTION [dbo].[fnAccesoContratacionOfertas] (@pUsuario varchar(50))
RETURNS bit
AS  
BEGIN

	DECLARE @vAccesoContratacion bit
	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @vCodEntidad varchar(3)	
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@pUsuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@pUsuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@pUsuario

	SET @vAccesoContratacion=0

	SELECT @vCodEntidad=CodEntidad FROM WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha

	IF isnull(@vCodEntidad, '')=''
		SET @vAccesoContratacion= 0
	ELSE
		SET @vAccesoContratacion= 1
		
	RETURN(@vAccesoContratacion)

END