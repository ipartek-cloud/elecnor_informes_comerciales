
CREATE FUNCTION [dbo].[fnContratacionAcumulada_SQL_AS400_2019] ( @pMes  int)
RETURNS
 @Contratacion TABLE (
	CodCentro int,
	CODOFER int,
	DESOFER varchar(100),
	CODCLIENTE varchar(8),
	NOMCLIENTE varchar(100),
	Importe float
 )
AS
BEGIN

  INSERT INTO @Contratacion(CodCentro,CODOFER,DESOFER,CODCLIENTE,NOMCLIENTE, Importe) 
  SELECT CodCentro,CODOFER,DESOFER,CODCLIENTE,isnull(NOMCLIENTE,''), sum(Importe)
  FROM vwContratacion_SQL_AS400_2019
  WHERE Mes<=@pMes
  GROUP BY CodCentro,CODOFER,DESOFER,CODCLIENTE,NOMCLIENTE  

 RETURN

END