

CREATE FUNCTION [dbo].[fnContratacionOfertas_SQL_AS400] (@pAño int, @pAdjudicada varchar(1), @pUsuario varchar(15))
RETURNS
 @OFERREGU TABLE (
	CodCentro int,
	CODOFER int,
	CODCLIENTE varchar(8)
 )
AS
BEGIN

  INSERT INTO @OFERREGU(CodCentro,CODOFER,CODCLIENTE) 
  SELECT DISTINCT CT, CODOFER, CODCLIENTE FROM OFERREGU WHERE AÑOAD=@pAño AND ADJUDICADA = @pAdjudicada AND Usuario=@pUsuario
  UNION ALL
  SELECT DISTINCT CodCentro, CodOferta, CodCliente FROM dbo.OfertasSQL WHERE AñoAdjudicacion = @pAño
  
 RETURN

END
