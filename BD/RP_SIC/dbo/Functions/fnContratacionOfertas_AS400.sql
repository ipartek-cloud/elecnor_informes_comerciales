CREATE FUNCTION [dbo].[fnContratacionOfertas_AS400] (@pAño int, @pAdjudicada varchar(1), @pUsuario varchar(15))
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
  
 RETURN

END