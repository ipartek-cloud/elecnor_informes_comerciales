CREATE PROCEDURE [dbo].[spContratacion_NacIntTODO] 		
	@pAño int,
	@pMes int,
	@pNacInt varchar(1)='' -- N = nacional / I = Internacional / cualquier otra cosa TODO
	AS
BEGIN

	SET @pNacInt = ISNULL(@pNacInt,'')

--	DECLARE @vContratacionInternacional TABLE (CodProv varchar(2),Pais varchar(50),ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float, Ajuste bit)
	DECLARE @Sql as varchar(8000)
	DECLARE @SqlFrom as varchar(8000)
		
	CREATE TABLE #vContratacionInternacional (CodProv varchar(2),Pais varchar(50),ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float, Ajuste bit)

	-- OFERTAS
	-- [vwOfertasInternacional]
	SET @SqlFrom = '
					SELECT O.CDCEN AS CodCentro, O.CDOFT AS CodOferta, 0 AS NumRegularizacion, 
							dbo.fgConvertirFechaDMY(O.FECHAA) AS FAlta, O.DCOF AS DescripcionOferta, 
							O.CDCLI AS CodCliente, O.LOCAL AS Localidad, O.PROOF AS CodProv, 
							O.IMAOF AS ImporteAprox, O.CDAC1 AS CodAct1, O.CDAC2 AS CodAct2, 
							O.RPROF AS CodResponsable, dbo.fgConvertirFechaDMY(O.FECHPP) AS FPresentacion, 
							O.PREVE AS PresupuestoVenta, dbo.fgConvertirFechaDMY(O.FECHAD) AS FAdjudicacion, 
							YEAR(dbo.fgConvertirFechaDMY(O.FECHAD)) AS AñoAdjudicacion, 
							MONTH(dbo.fgConvertirFechaDMY(O.FECHAD)) AS MesAdjudicacion, O.ADELE AS Adjudicada, 
							O.PREAD AS ImporteContratado, P.NMPRO AS Pais
                    FROM Ofertas O
	                        INNER JOIN Provincias P ON O.PROOF = P.CDPRO
		           -- Paco 21/01/2026 porque no cuadraba lo que devolvía este SP con lo de spContratacion_DG_SDG_DN_SDNA, que está bien 
                            INNER JOIN Sumarigrama S ON S.CodCentro = O.CDCEN
					'
	IF @pNacInt='I'
		SET @SqlFrom = @SqlFrom + 'WHERE P.Pais = ''Internacional'''
	IF @pNacInt='N'
		SET @SqlFrom = @SqlFrom + 'WHERE P.Pais = ''Nacional'''
	
	SET @Sql = '	
	INSERT INTO #vContratacionInternacional(CodProv,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,Ajuste)	
	SELECT CodProv,Pais,sum(ImporteContratado) ,0,0
	FROM (' + @SqlFrom + ') Ofertas
	WHERE  AñoAdjudicacion=' + STR(@pAño) + '  AND MesAdjudicacion<=' + STR(@pMes) + ' AND Adjudicada=''S''
	GROUP BY CodProv,Pais'

	--print  (@Sql)
	EXEC (@Sql)

	---- REGULARIZACIONES
	-- vwRegularizacionesInternacional
	SET @SqlFrom = '
					SELECT R.CDCEN AS CodCentro, R.CDOFT AS CodOferta, ISNULL(R.NUMRE, 0) AS NumRegularizacion, 
							dbo.fgConvertirFechaDMY(O.FECHAA) AS FAlta, O.DCOF AS DescripcionOferta, 
							O.CDCLI AS CodCliente, O.LOCAL AS Localidad, O.PROOF AS CodProv, O.IMAOF AS ImporteAprox, 
							O.CDAC1 AS CodAct1, O.CDAC2 AS CodAct2, O.RPROF AS CodResponsable, 
							dbo.fgConvertirFechaDMY(O.FECHPP) AS FPresentacion, O.PREVE AS PresupuestoVenta, 
							dbo.fgConvertirFechaDMY(R.FECHAR) AS FAdjudicacion, 
							YEAR(dbo.fgConvertirFechaDMY(R.FECHAR)) AS AñoAdjudicacion, 
							MONTH(dbo.fgConvertirFechaDMY(R.FECHAR)) AS MesAdjudicacion, 
							O.ADELE AS Adjudicada, R.IMPRE AS ImporteContratado, P.NMPRO AS Pais
					FROM Ofertas O ' +
	               '        INNER JOIN Regularizaciones R ON O.CDOFT = R.CDOFT
							INNER JOIN Provincias P ON O.PROOF = P.CDPRO
		           -- Paco 21/01/2026 porque no cuadraba lo que devolvía este SP con lo de spContratacion_DG_SDG_DN_SDNA, que está bien 
	                        INNER JOIN Sumarigrama S ON R.CDCEN = S.CodCentro --------------------
					  '
	IF @pNacInt='I'
		SET @SqlFrom = @SqlFrom + 'WHERE P.Pais = ''Internacional'''
	IF @pNacInt='N'
		SET @SqlFrom = @SqlFrom + 'WHERE P.Pais = ''Nacional'''

	SET @Sql = '	
	INSERT INTO #vContratacionInternacional(CodProv,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,Ajuste)	
	SELECT CodProv,Pais,sum(ImporteContratado) ,0,0
	FROM (SELECT   CodCentro,ImporteContratado,CodProv,Pais
			FROM (' + @SqlFrom + ') Regularizaciones
			WHERE  AñoAdjudicacion=' + STR(@pAño) + '  AND MesAdjudicacion<=' + STR(@pMes) + ') Q
	GROUP BY CodProv,Pais'

	--print  (@Sql)
	EXEC (@Sql)

	---- OfertasSQL
	-- ProvinciasInternacional
	SET @SqlFrom = '
					SELECT CAutonoma.CDAUT, CAutonoma.NMAUT, P.CDPRO, P.NMPRO, dbo.fnPais(CAutonoma.CDAUT) AS Pais
					FROM SIC.S44DD901.ICOMERF.IC05AP AS P INNER JOIN
						SIC.S44DD901.ICOMERF.IC11AP AS CAutonoma ON P.CDAUT = CAutonoma.CDAUT
					  '
	IF @pNacInt='I'
		SET @SqlFrom = @SqlFrom + 'WHERE dbo.fnPais(CAutonoma.CDAUT) =  ''Internacional'''
	IF @pNacInt='N'
		SET @SqlFrom = @SqlFrom + 'WHERE dbo.fnPais(CAutonoma.CDAUT) =  ''Nacional'''

	SET @Sql = '	
	INSERT INTO #vContratacionInternacional(CodProv,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,Ajuste)	
	SELECT CodProv,Provincias.NMPRO,sum(O.ImporteContratado) ,0,0
	FROM OfertasSQL O INNER JOIN
			 (' + @SqlFrom + ') Provincias ON O.CodProv = Provincias.CDPRO INNER JOIN
                      Sumarigrama S ON O.CodCentro = S.CodCentro
	WHERE  AñoAdjudicacion=' + STR(@pAño) + '  AND month(FAdjudicacion)<=' + STR(@pMes) + '
	           -- Paco 21/01/2026 Comentada esta parte de la condición porque no cuadraba lo que devolvía este SP con lo de spContratacion_DG_SDG_DN_SDNA, que está bien 
	           --AND Reparto=0
	GROUP BY CodProv,Provincias.NMPRO'

	--print  (@Sql)
	EXEC (@Sql)

	----OfertasSQL_Ajustes
	-- ProvinciasInternacional
	SET @SqlFrom = @SqlFrom -- No cambia
		
	SET @Sql = '	
	INSERT INTO #vContratacionInternacional(CodProv,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,Ajuste)	
	SELECT CodProv,Provincias.NMPRO,sum(O.Importe) ,0,1
	FROM OfertasSQL_Ajustes O INNER JOIN
			 (' + @SqlFrom + ') Provincias ON O.CodProv = Provincias.CDPRO 
	WHERE  AñoAdjudicacion=' + STR(@pAño) + '  AND month(FAdjudicacion)<=' + STR(@pMes) + '
	GROUP BY CodProv,Provincias.NMPRO'

	--print  (@Sql)
	EXEC (@Sql)

	--SELECT CodProv,Pais, isnull(Sum(ImporteContratadoAcumulado),0) as ImporteContratadoAcumulado, isnull(sum(ImporteContratadoAcumuladoAñoAnterior),0) as ImporteContratadoAcumuladoAñoAnterior,Ajuste 
	--FROM #vContratacionInternacional	
	--GROUP BY CodProv,Pais,Ajuste

	SELECT CodProv, Pais, 
			SUM(ImporteContratadoAcumulado) ImporteContratadoAcumulado, 
			SUM(ImporteContratadoAcumuladoAñoAnterior) ImporteContratadoAcumuladoAñoAnterior,
			Ajuste
	FROM (
		SELECT CASE WHEN IsNUMERIC(CodProv)=1 THEN 'Nacional' ELSE 'Internacional' END NacInt,
				CASE WHEN IsNUMERIC(CodProv)=1 THEN '00' ELSE CodProv END CodProv, 
				CASE WHEN IsNUMERIC(CodProv)=1 THEN 'España' ELSE Pais END Pais, 
				isnull(Sum(ImporteContratadoAcumulado),0) as ImporteContratadoAcumulado, 
				isnull(sum(ImporteContratadoAcumuladoAñoAnterior),0) as ImporteContratadoAcumuladoAñoAnterior,Ajuste 
		FROM #vContratacionInternacional	
		GROUP BY CodProv,Pais,Ajuste
		) q
	GROUP BY CodProv,Pais,Ajuste
		
END