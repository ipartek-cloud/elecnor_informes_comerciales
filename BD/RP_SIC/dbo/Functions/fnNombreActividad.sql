CREATE FUNCTION [dbo].[fnNombreActividad] (@CDAC varchar(4))
RETURNS varchar(30)
AS  
BEGIN

	DECLARE @NombreActividad as varchar(30)

	SELECT @NombreActividad= DSACT
	FROM [dbo].[Actividades]
	WHERE CDAC1+CDAC2=@CDAC
	
	RETURN(isnull(@NombreActividad,''))

END
