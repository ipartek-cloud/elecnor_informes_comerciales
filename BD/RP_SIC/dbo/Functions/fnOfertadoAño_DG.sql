CREATE FUNCTION [dbo].[fnOfertadoAño_DG] (@pUsuario varchar(50),@pAño int,@pMes int)
RETURNS float
AS  
BEGIN

DECLARE @OfertadoMes as float
DECLARE @vMes as int
	
SET @vMes=month(getdate())

SELECT @OfertadoMes=sum(PREVE) FROM WEB_OFERTACION
WHERE Usuario=@pUsuario AND
	  year(dbo.fgConvertirFechaDMY(FECHPP))=@pAño AND
	  Month(dbo.fgConvertirFechaDMY(FECHPP))<=@vMes
	
RETURN(isnull(@OfertadoMes,0)/1000)

END
