CREATE FUNCTION [dbo].[fnObjetivoAnual_DN] (@pMercado varchar(50),@pAño int,@pCodDDirNegocio int)
RETURNS float
AS  
BEGIN

DECLARE @ObjetivoAnual as float

SELECT     @ObjetivoAnual=sum(Importe)
FROM       dbo.ObjetivosDelegacionSQL INNER JOIN
                      dbo.vwSumarigrama_DN_DEL ON dbo.ObjetivosDelegacionSQL.Año = dbo.vwSumarigrama_DN_DEL.Año AND 
                      dbo.ObjetivosDelegacionSQL.CodDelegacion = dbo.vwSumarigrama_DN_DEL.CodDelegacion
WHERE  ObjetivosDelegacionSQL.Año=@pAño AND Mercado=@pMercado AND CodDDirNegocio = @pCodDDirNegocio
	
RETURN(isnull(@ObjetivoAnual,0))

END
