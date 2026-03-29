
CREATE PROCEDURE [dbo].[spOfertasAsociadasAInversion]
	@pAño as int =2024
	, @pMes as int=2
AS
BEGIN

SET @pMes=CASE WHEN @pAño IS NULL THEN NULL ELSE @pMes END
-- Declare de @Ofertas
BEGIN

	DECLARE @Ofertas as Table (CDCEN varchar(3), CDOFT varchar(100), DCOF varchar(500), TVEN float
								,CTRO varchar(3), OBRA varchar(10), CDAUT int, CDCLI varchar(50))

	INSERT INTO @Ofertas 
	SELECT  RIGHT('000'+LTRIM(CDCEN),3), CDOFT, DCOF, TVEN
			, RIGHT('000'+LTRIM(CDCEN),3) CTRO, RIGHT('00000'+LTRIM(OBRA),5), CDAUT, CDCLI 
	FROM OPENQUERY(SIC, 'SELECT DISTINCT OFCA.CDCEN, OFCA.CDOFT, OFCA.DCOF, OFCA.TVEN
													, OFCA.CDCEN CTRO, Enlaces.OBRA, CAut.CDAUT, OFCA.CDCLI
								FROM S44DD901.ICOMERF.IC09AP As OFCA 
										INNER JOIN S44DD901.ICOMERF.ICPOAI As OAI ON OFCA.CDOFT = OAI.JVAYNB
										LEFT JOIN S44DD901.FICOSCO.CO005BP AS Enlaces ON OFCA.CDCEN = Enlaces.CTRO AND OFCA.CDOFT = Enlaces.CDOFT
										LEFT JOIN S44DD901.ICOMERF.IC05AP as Prov ON OFCA.PROOF = Prov.CDPRO
										LEFT JOIN S44DD901.ICOMERF.IC11AP as CAut ON Prov.CDAUT = CAut.CDAUT
								WHERE NOT (OFCA.ADELE <> ''S'' AND Enlaces.CDOFT IS NULL) 
										AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 )>=2005	
										AND OFCA.BAJA<>''B''
										--AND OFCA.WS10=''E'' -- Solo Elecnor
								') OFER 
END


SELECT Año, Mes, DN, Mercado, [CodOferta AI], [Descrip Oferta], Cliente, NombreCliente
		, CASE WHEN SUM(q.ContOAS)>1 OR SUM(q.ContOHS)>1 THEN '--' ELSE MIN(CTRO) END CTRO
		, CASE WHEN SUM(q.ContOAS)>1 OR SUM(q.ContOHS)>1 THEN '--' ELSE MIN(OBRA) END OBRA
		, ROUND([Contratación Total], 0) [Contratación Total]
		, ROUND(SUM([Produccion Origen]), 0) [Produccion Origen]
		, ROUND(([Contratación Total] - SUM([Produccion Origen])), 0) Cartera
FROM (
--- Producciones Normales
		SELECT	1 ContOAS, 0 ContOHS
				, OAS.Año, OAS.Mes 
				, S.CodDDirNegocio DN
				, 'AI-' + IIF(OFER.cdaut<>'19', 'Nac', 'Int') Mercado
				, OFER.CDOFT [CodOferta AI]
				, OFER.DCOF [Descrip Oferta]
				, Cli.CodCliente Cliente
				, Cli.NombreCliente
				--, Cli.NomAgrupado
				, RIGHT('000' + CAST(OFER.CTRO as varchar(3)), 3) CTRO
				, CASE WHEN LEFT(OFER.OBRA, 3) IS NULL THEN '' ELSE LEFT(OFER.OBRA, 3) END OBRA --, RIGHT(OFER.OBRA, 2) OBRAL

				, CAST(MIN(OFER.TVEN) as float) [Contratación Total]
				, CAST(SUM(ISNULL(OAS.SOP,0)) as float) [Produccion Origen]

		--, *
		FROM @Ofertas OFER 
				LEFT JOIN ClientesSQL Cli ON OFER.CDCLI = Cli.CodCliente
				LEFT JOIN ObrasActualesSQL OAS ON OFER.CTRO=OAS.CTR AND OFER.OBRA=OAS.OBRA+OAS.OBRAL
				LEFT JOIN Sumarigrama S ON OFER.CTRO=S.CodCentro
		where (@pAño IS NULL OR (OAS.Año=ISNULL(@pAño,0) AND OAS.Mes=ISNULL(@pMes,0)))
		--AND (@IdOferta IS NULL OR OFER.CDOFT=@IdOferta) 
		
		GROUP BY OAS.Año, OAS.Mes 
				, S.CodDDirNegocio 
				, 'AI-' + IIF(OFER.cdaut<>'19', 'Nac', 'Int') 
				, OFER.CDOFT
				, OFER.DCOF 
				, Cli.CodCliente 
				, Cli.NombreCliente
		
				, OFER.CTRO, LEFT(OFER.OBRA, 3)

UNION

--- Histórico de Producciones 
		SELECT	0 ContOAS, 1 ContOHS
				, @pAño Año, @pMes Mes 
				, S.CodDDirNegocio DN
				, 'AI-' + IIF(OFER.cdaut<>'19', 'Nac', 'Int') Mercado
				, OFER.CDOFT [CodOferta AI]
				, OFER.DCOF [Descrip Oferta]
				, Cli.CodCliente Cliente
				, Cli.NombreCliente

				, RIGHT('000' + CAST(OFER.CTRO as varchar(3)), 3) CTRO
				, CASE WHEN LEFT(OFER.OBRA, 3) IS NULL THEN '' ELSE LEFT(OFER.OBRA, 3) END OBRA --, RIGHT(OFER.OBRA, 2) OBRAL

				, CAST(MIN(OFER.TVEN) as float) [Contratación Total]
				, CAST(SUM(ISNULL(OHS.SOP,0)) as float) [Produccion Origen]

		--, *
		FROM @Ofertas OFER 
				LEFT JOIN ClientesSQL Cli ON OFER.CDCLI = Cli.CodCliente
				LEFT JOIN ObrasHistoricasSQL OHS ON OFER.CTRO=OHS.CTR AND OFER.OBRA=OHS.OBRA+OHS.OBRAL
				LEFT JOIN Sumarigrama S ON OFER.CTRO=S.CodCentro
		--where (@IdOferta IS NULL OR OFER.CDOFT=@IdOferta) 
		
		GROUP BY S.CodDDirNegocio 
				, 'AI-' + IIF(OFER.cdaut<>'19', 'Nac', 'Int') 
				, OFER.CDOFT
				, OFER.DCOF 
				, Cli.CodCliente 
				, Cli.NombreCliente
		
				, OFER.CTRO, LEFT(OFER.OBRA, 3)

	) q
GROUP BY Año, Mes, DN, Mercado, [CodOferta AI], [Descrip Oferta], Cliente, NombreCliente
		, [Contratación Total]
END
