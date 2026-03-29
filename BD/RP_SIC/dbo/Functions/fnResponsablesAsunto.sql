CREATE FUNCTION [dbo].[fnResponsablesAsunto] (@idAsunto int, @UsuarioPropietario	varchar(50))
RETURNS varchar(1000)
AS  
BEGIN

DECLARE @Responsables as varchar(1000)

SELECT @Responsables = 
    STUFF((SELECT ',' + UsuarioResponsable
           FROM RPI_Responsables b 
           WHERE b.idAsunto = a.idAsunto 
          FOR XML PATH('')), 1, 1, '')
FROM RPI_Responsables a
where idasunto=@idAsunto
GROUP BY idAsunto


RETURN(UPPER (@UsuarioPropietario + ','  + isnull(@Responsables,'')))

END
