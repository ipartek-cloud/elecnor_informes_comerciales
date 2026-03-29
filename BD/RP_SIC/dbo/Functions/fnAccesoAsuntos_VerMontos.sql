

create FUNCTION [dbo].[fnAccesoAsuntos_VerMontos] (@pUsuario varchar(50))
RETURNS bit
AS  
BEGIN

	DECLARE @vAccesoAsuntos_VerMontos bit
	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@pUsuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@pUsuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@pUsuario

	SET @vAccesoAsuntos_VerMontos=0

	SELECT @vAccesoAsuntos_VerMontos=AccesoAsuntos_VerMontos FROM WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha
		
	RETURN(@vAccesoAsuntos_VerMontos)

END
