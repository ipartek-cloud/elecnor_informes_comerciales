CREATE FUNCTION [dbo].[fnObjetivoMensual] (@pMercado varchar(50),@pAño int)
RETURNS float
AS  
BEGIN

-- @pMercado : Internacional,Nacional
-- @pAño

DECLARE @ObjetivoMensual as float

SELECT @ObjetivoMensual=Importe FROM ObjetivosSQL WHERE Año=@pAño and Mercado=@pMercado
SET @ObjetivoMensual=dbo.fnFormatoMoneda(@ObjetivoMensual/12)
	
RETURN(@ObjetivoMensual)

END
