
CREATE FUNCTION [dbo].[fnContratacionAcumulada_SQL_AS400] (@pAño int, @pMes int, @pUsuario varchar(15))
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

  INSERT INTO @Contratacion(CodCentro,CODOFER,DESOFER,CODCLIENTE,NOMCLIENTE,Importe) 
  SELECT CodCentro,CODOFER,DESOFER,CODCLIENTE,isnull(NOMCLIENTE,''), SUM(Importe)
  FROM (
  
	  SELECT MESAD as Mes ,CT as CodCentro,CODOFER,DESOFER,OFERREGU.CODCLIENTE as CodCliente, dbo.ClientesSQL.NomAgrupado AS NomCliente,IMPAD AS Importe FROM OFERREGU LEFT OUTER JOIN
			 dbo.ClientesSQL ON OFERREGU.CODCLIENTE = dbo.ClientesSQL.CodCliente  
	  WHERE  AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@pUsuario
	  UNION ALL
	  SELECT MONTH(dbo.OfertasSQL.FAdjudicacion) AS Mes, dbo.OfertasSQL.CodCentro, 
			 dbo.OfertasSQL.CodOferta AS CODOFER, dbo.OfertasSQL.DescripcionOferta AS DESOFER, dbo.OfertasSQL.CodCliente, 
			 dbo.fnNombreClienteAgrupadoATERSA(dbo.OfertasSQL.CodCliente, dbo.ClientesSQL.NomAgrupado) AS NomCliente, 
			 dbo.OfertasSQL.ImporteContratado AS Importe
	  FROM   dbo.OfertasSQL LEFT OUTER JOIN dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
	  WHERE  dbo.OfertasSQL.AñoAdjudicacion = @pAño
  
  ) as vw
  WHERE Mes<=@pMes
  GROUP BY CodCentro,CODOFER,DESOFER,CODCLIENTE,NOMCLIENTE  

 RETURN

END