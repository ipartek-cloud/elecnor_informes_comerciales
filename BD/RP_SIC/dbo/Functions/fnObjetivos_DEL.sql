


CREATE FUNCTION [dbo].[fnObjetivos_DEL] (@pAño int, @pCodDelegacion varchar(3))
RETURNS float
AS  
BEGIN

DECLARE @Objetivos as float

SET @Objetivos=0

SELECT   @Objetivos= SUM(Importe)
FROM     dbo.ObjetivosActividadSQL INNER JOIN
         dbo.Sumarigrama ON dbo.ObjetivosActividadSQL.CodCentro = dbo.Sumarigrama.CodCentro
WHERE  ObjetivosActividadSQL.Año=@pAño AND CodDelegacion = @pCodDelegacion 
	
RETURN(isnull(@Objetivos,0))

END
