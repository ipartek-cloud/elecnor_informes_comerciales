CREATE FUNCTION [dbo].[fnOfertadoAño_AREA] (@pUsuario varchar(50),@pAño int,@pMes int, @pCodSubDirNegocioArea int)
RETURNS float
AS  
BEGIN

DECLARE @OfertadoMes as float
DECLARE @vMes as int
	
SET @vMes=month(getdate())

SELECT @OfertadoMes=sum(PREVE) 
FROM WEB_OFERTACION INNER JOIN
         Sumarigrama ON WEB_OFERTACION.CdCen = Sumarigrama.CodCentro
WHERE Sumarigrama.Año=@pAño AND
	  Sumarigrama.CodSubDirNegocioArea = @pCodSubDirNegocioArea AND
	  WEB_OFERTACION.Usuario=@pUsuario AND
	  year(dbo.fgConvertirFechaDMY(FECHPP))=@pAño AND
	  Month(dbo.fgConvertirFechaDMY(FECHPP))<=@vMes
	
RETURN(isnull(@OfertadoMes,0)/1000)

END
