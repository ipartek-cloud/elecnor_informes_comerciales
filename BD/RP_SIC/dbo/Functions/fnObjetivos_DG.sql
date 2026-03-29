CREATE FUNCTION [dbo].[fnObjetivos_DG] (@pAño int,@pCodDirGeneral int)
RETURNS float
AS  
BEGIN

DECLARE @Objetivos as float

SET @Objetivos=0

SELECT   @Objetivos= SUM(Importe)
FROM     dbo.ObjetivosActividadSQL INNER JOIN
         dbo.Sumarigrama ON dbo.ObjetivosActividadSQL.CodCentro = dbo.Sumarigrama.CodCentro
WHERE  ObjetivosActividadSQL.Año=@pAño AND CodDirGeneral = @pCodDirGeneral 
	
RETURN(isnull(@Objetivos,0))

END
