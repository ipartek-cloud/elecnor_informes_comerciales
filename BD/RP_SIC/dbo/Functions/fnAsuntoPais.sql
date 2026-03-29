


create FUNCTION [dbo].[fnAsuntoPais]
 (@idArea_Pais int)
RETURNS varchar(100)
AS  
BEGIN

	DECLARE @Pais as varchar(100)

	Select Distinct @Pais=Pais FROM RPI_Area_Pais WHERE idArea_Pais=@idArea_Pais
			
	RETURN(isnull(@Pais,''))

END
