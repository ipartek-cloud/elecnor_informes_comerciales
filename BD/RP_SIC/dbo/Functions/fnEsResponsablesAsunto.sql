create FUNCTION [dbo].[fnEsResponsablesAsunto] (@idAsunto int, @Usuario	varchar(50))
RETURNS bit
AS  
BEGIN

DECLARE @EsResponsable as bit
DECLARE @num as integer

SELECT @num=isnull(count(idAsunto),0)
FROM RPI_Responsables 
WHERE idasunto=@idAsunto and UsuarioResponsable = @Usuario

IF @num>0
	BEGIN
		SET @EsResponsable=1
	END
ELSE
	BEGIN
		SET @EsResponsable=0
	END

RETURN(@EsResponsable)

END
