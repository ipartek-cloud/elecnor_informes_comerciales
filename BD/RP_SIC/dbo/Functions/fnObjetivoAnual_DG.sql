CREATE FUNCTION [dbo].[fnObjetivoAnual_DG] (@pMercado varchar(50),@pAño int)
RETURNS float
AS  
BEGIN

-- @pMercado : Internacional,Nacional
-- @pAño

DECLARE @ObjetivoAnual as float

SELECT @ObjetivoAnual=sum(Importe) FROM ObjetivosSQL WHERE Año=@pAño and Mercado=@pMercado
	
RETURN(isnull(@ObjetivoAnual,0))

END
