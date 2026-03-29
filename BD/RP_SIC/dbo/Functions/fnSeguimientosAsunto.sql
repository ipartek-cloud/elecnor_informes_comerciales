
CREATE FUNCTION [dbo].[fnSeguimientosAsunto] (@idAsunto int, @pTipo varchar(1))
RETURNS varchar(8000)
AS  
BEGIN

DECLARE @SC as varchar(8000)

SELECT @SC = 
    STUFF((SELECT TOP 2 ',' + ' (' + Fecha + ')  ' + Descripcion
           FROM RPI_Seguimientos b 
           WHERE b.idAsunto = a.idAsunto AND Tipo=@pTipo
		   order by CONVERT(Datetime, Fecha, 105) desc
          FOR XML PATH('')), 1, 1, '')
FROM RPI_Seguimientos a
where idasunto=@idAsunto 
GROUP BY idAsunto


RETURN( isnull(@SC,''))

END