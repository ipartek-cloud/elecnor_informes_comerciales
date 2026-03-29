CREATE FUNCTION [dbo].[fnObjetivoAnual_SDG] (@pMercado varchar(50),@pAño int,@pCodSubDirGeneral int)
RETURNS float
AS  
BEGIN

-- @pMercado : Internacional,Nacional
-- @pAño

DECLARE @ObjetivoAnual as float

SELECT @ObjetivoAnual=Importe FROM ObjetivosSQL WHERE Año=@pAño and Mercado=@pMercado and @pCodSubDirGeneral=CodSubDirGeneral
	
RETURN(isnull(@ObjetivoAnual,0))

END