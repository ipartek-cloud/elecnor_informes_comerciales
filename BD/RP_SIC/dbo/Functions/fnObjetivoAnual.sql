create FUNCTION [dbo].[fnObjetivoAnual] (@pMercado varchar(50),@pAño int)
RETURNS float
AS  
BEGIN

-- @pMercado : Internacional,Nacional
-- @pAño

DECLARE @ObjetivoAnual as float

SELECT @ObjetivoAnual=Importe FROM ObjetivosSQL WHERE Año=@pAño and Mercado=@pMercado
	
RETURN(@ObjetivoAnual)

END
