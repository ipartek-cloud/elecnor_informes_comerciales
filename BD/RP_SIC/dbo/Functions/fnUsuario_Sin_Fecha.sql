
CREATE FUNCTION [dbo].[fnUsuario_Sin_Fecha] (@pUsuario varchar(50))
RETURNS varchar(10)
AS  
BEGIN
	
	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@pUsuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@pUsuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@pUsuario
		
	RETURN(isnull(@Usuario_Sin_Fecha,''))

END
