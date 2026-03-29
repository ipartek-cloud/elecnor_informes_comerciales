CREATE FUNCTION [dbo].[fnObjetivoAnual_AREA] (@pMercado varchar(50),@pAño int,@pCodSubDirNegocioArea int)
RETURNS float
AS  
BEGIN

DECLARE @ObjetivoAnual as float

SELECT @ObjetivoAnual=sum(Importe)
FROM   dbo.ObjetivosDelegacionSQL INNER JOIN
       dbo.vwSumarigrama_AREA_DEL ON dbo.ObjetivosDelegacionSQL.Año = dbo.vwSumarigrama_AREA_DEL.Año AND 
       dbo.ObjetivosDelegacionSQL.CodDelegacion = dbo.vwSumarigrama_AREA_DEL.CodDelegacion
WHERE  ObjetivosDelegacionSQL.Año=@pAño AND Mercado=@pMercado AND CodSubDirNegocioArea = @pCodSubDirNegocioArea
	
RETURN(isnull(@ObjetivoAnual,0))

END
