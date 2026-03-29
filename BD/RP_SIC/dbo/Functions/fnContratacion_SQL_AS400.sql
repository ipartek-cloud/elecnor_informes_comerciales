CREATE FUNCTION [dbo].[fnContratacion_SQL_AS400] (@pAño int, @pUsuario varchar(15))
RETURNS
 @OFERREGU TABLE (
	AÑOAD int,
	MESAD int,
	CT int,
	CODOFER varchar(10),
	DESOFER varchar(100),
	CODCLIENTE varchar(8),
	NOMCLIENTE varchar (100),
	IMPAD numeric(9,0)
 )
AS
BEGIN

  INSERT INTO @OFERREGU(AÑOAD,MESAD,CT,CODOFER,DESOFER,CODCLIENTE,NOMCLIENTE,IMPAD) 
  SELECT AÑOAD,MESAD,CT,CODOFER,DESOFER,OFERREGU.CODCLIENTE, dbo.ClientesSQL.NomAgrupado,IMPAD 
  FROM OFERREGU LEFT OUTER JOIN dbo.ClientesSQL ON OFERREGU.CODCLIENTE = dbo.ClientesSQL.CodCliente  
  WHERE AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@pUsuario
  UNION
  SELECT dbo.OfertasSQL.AñoAdjudicacion AS Año, MONTH(dbo.OfertasSQL.FAdjudicacion) AS Mes, dbo.OfertasSQL.CodCentro, 
         dbo.OfertasSQL.CodOferta AS CODOFER, dbo.OfertasSQL.DescripcionOferta AS DESOFER, dbo.OfertasSQL.CodCliente,          
		 dbo.fnNombreClienteAgrupadoATERSA(dbo.OfertasSQL.CodCliente, dbo.ClientesSQL.NomAgrupado) AS NomCliente, 
		 dbo.OfertasSQL.ImporteContratado AS Importe
  FROM   dbo.OfertasSQL LEFT OUTER JOIN dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
  WHERE  dbo.OfertasSQL.AñoAdjudicacion = @pAño

  --INSERT INTO @OFERREGU(AÑOAD,MESAD,CT,CODOFER,DESOFER,CODCLIENTE,NOMCLIENTE,IMPAD) 
  --SELECT AÑOAD,MESAD,CT,CODOFER,DESOFER,OFERREGU.CODCLIENTE, dbo.ClientesSQL.NomAgrupado,SUM(IMPAD) FROM OFERREGU LEFT OUTER JOIN
  --       dbo.ClientesSQL ON OFERREGU.CODCLIENTE = dbo.ClientesSQL.CodCliente
  --GROUP BY Usuario,ADJUDICADA,AÑOAD,MESAD,CT,CODOFER,DESOFER,OFERREGU.CODCLIENTE, dbo.ClientesSQL.NomAgrupado
  --HAVING AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@pUsuario
  --UNION
  --SELECT dbo.OfertasSQL.AñoAdjudicacion AS Año, MONTH(dbo.OfertasSQL.FAdjudicacion) AS Mes, dbo.OfertasSQL.CodCentro, 
  --       dbo.OfertasSQL.CodOferta AS CODOFER, dbo.OfertasSQL.DescripcionOferta AS DESOFER, dbo.OfertasSQL.CodCliente, 
  --       dbo.ClientesSQL.NomAgrupado AS NomCliente,dbo.OfertasSQL.ImporteContratado AS Importe
  --FROM   dbo.OfertasSQL LEFT OUTER JOIN dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
  --WHERE  dbo.OfertasSQL.AñoAdjudicacion = @pAño
  
 RETURN

END
