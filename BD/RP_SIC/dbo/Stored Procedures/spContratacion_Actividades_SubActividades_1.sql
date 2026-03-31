CREATE PROCEDURE [dbo].[spContratacion_Actividades_SubActividades] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	SET NOCOUNT ON;
BEGIN
-------------------------------------------------------------------------------------------------	
	CREATE TABLE #vwWEB_OFERTAS_CA_Local  (CodCentro varchar(3), CodOferta varchar(10), AñoAdjudicacion int, MesAdjudicacion int, ImporteContratado float, CodAct1 varchar(2), CodAct2 varchar(2), Pais varchar(200))
	CREATE TABLE #vwWEB_Regularizaciones_Local  (CodCentro varchar(3), CodOferta varchar(10), NumRegularizacion int, AñoAdjudicacion int, MesAdjudicacion int, ImporteContratado float, CodAct1 varchar(2), CodAct2 varchar(2), Pais varchar(200))
	DECLARE @SQL_AS400_select as varchar(max)
	DECLARE @SQL_AS400_from as varchar(max)
	DECLARE @SQL_AS400 as varchar(max)

-- Ofertas
	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_CA_Local (CodCentro, CodOferta, AñoAdjudicacion, MesAdjudicacion, ImporteContratado, CodAct1, CodAct2, Pais)
							SELECT CDCEN AS CodCentro
									, CDOFT AS CodOferta, 
									YEAR(CASE WHEN LEN(FECHAD) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAD, 6), 103) 
										ELSE (CASE WHEN FECHAD = ''0'' THEN ''19990101'' ELSE NULL END) 
									END) AS AñoAdjudicado, 
									MONTH(CASE WHEN LEN(FECHAD) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAD, 6), 103) 
										ELSE (CASE WHEN FECHAD = ''0'' THEN ''19990101'' ELSE NULL END) 
									END) AS MesAdjudicado, 
									PREAD AS ImporteContratado
									, CDAC1, CDAC2
									, Pais
							'

	SET @SQL_AS400_from = '
							SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT OFCA.CDCEN, OFCA.CDOFT, OFCA.FECHAA, OFCA.DCOF, OFCA.CDCLI, OFCA.LOCAL, OFCA.PROOF, OFCA.IMAOF
							, OFCA.CDAC1, OFCA.CDAC2, OFCA.DECOF, OFCA.RPROF, OFCA.FECHPP, OFCA.PREVE, OFCA.FECHAD, OFCA.ADELE, OFCA.PREAD
							, OFCA.TCOS, OFCA.TVEN, OFCA.USER, OFCA.WS10, OFCA.DESPRO, OFCA.BAJA
									, CASE WHEN CAutonoma.CDAUT<>19 THEN ''''Nacional'''' ELSE ''''Internacional'''' END Pais
							 FROM  S44DD901.ICOMERF.IC09AP As OFCA 
									INNER JOIN S44DD901.ICOMERF.IC05AP as Provincias ON OFCA.PROOF=Provincias.CDPRO
									INNER JOIN S44DD901.ICOMERF.IC11AP as CAutonoma ON Provincias.CDAUT = CAutonoma.CDAUT							 
							 WHERE OFCA.ADELE = ''''S'''' 
									-- Paco 2024/09/04 Comentado porque en informe Access no coincidía valor de "Parque Eólicos" con lo que debía de ser por una oferta de Baja (2111700023)
									--AND OFCA.BAJA<> ''''B''''
									AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 )>=2005
									AND substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 1, 4 )=' + CAST(@pAño as varchar(4)) + '
									AND substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 5, 2 )<=' + CAST(@pMes as varchar(2)) + '
							'')'

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vwWEB_OFERTAS_CA'
	--PRINT cast(@SQL_AS400 as text)
	EXEC (@SQL_AS400)

-- regularizaciones
	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_Regularizaciones_Local (CodCentro, CodOferta, NumRegularizacion, AñoAdjudicacion, MesAdjudicacion, ImporteContratado, CodAct1, CodAct2, Pais)
							SELECT CDCEN AS CodCentro
									, CDOFT AS CodOferta
									, NUMRE
									, YEAR(CASE WHEN LEN(FECHAR) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAR, 6), 103) 
										ELSE (CASE WHEN FECHAR = ''0'' THEN ''19990101'' ELSE NULL END) 
									END) AS AñoAdjudicado, 
									MONTH(CASE WHEN LEN(FECHAR) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAR, 6), 103) 
										ELSE (CASE WHEN FECHAR = ''0'' THEN ''19990101'' ELSE NULL END) 
									END) AS MesAdjudicado, 
									IMPRE AS ImporteContratado
									, CDAC1, CDAC2
									, Pais
							'

	SET @SQL_AS400_from = '
	SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT REG.CDCEN, REG.CDOFT, REG.NUMRE
							, REG.FECHAR, REG.IMPRE
							, OFCA.CDAC1, OFCA.CDAC2
							, CASE WHEN CAutonoma.CDAUT<>19 THEN ''''Nacional'''' ELSE ''''Internacional'''' END Pais
							 FROM  S44DD901.ICOMERF.IC09AP As OFCA 
									INNER JOIN S44DD901.ICOMERF.IC10AP REG ON OFCA.CDOFT=REG.CDOFT
									INNER JOIN S44DD901.ICOMERF.IC05AP as Provincias ON OFCA.PROOF=Provincias.CDPRO
									INNER JOIN S44DD901.ICOMERF.IC11AP as CAutonoma ON Provincias.CDAUT = CAutonoma.CDAUT							 
							 WHERE OFCA.ADELE = ''''S'''' 
									-- Paco 2024/09/04 Comentado porque en informe Access no coincidía valor de "Parque Eólicos" con lo que debía de ser por una oferta de Baja (2111700023)
									--AND OFCA.BAJA<> ''''B''''
									AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 )>=2005
									AND substr( digits(dec(19000000+REG.FECHAR,8,0)), 1, 4 )=' + CAST(@pAño as varchar(4)) + '
									AND substr( digits(dec(19000000+REG.FECHAR,8,0)), 5, 2 )<=' + CAST(@pMes as varchar(2)) + '
							'')'

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') Regularizaciones'
	--PRINT cast(@SQL_AS400 as text)
	EXEC (@SQL_AS400)
-------------------------------------------------------------------------------------------------	
END
	DECLARE @vContratacionActividades TABLE (NombreDirGeneral varchar(100),CodAct1 varchar(2),CodAct2 varchar(2),Pais varchar(50), ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- OFERTAS
			
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM dbo.Sumarigrama INNER JOIN
		 #vwWEB_OFERTAS_CA_Local O ON dbo.Sumarigrama.CodCentro = O.CodCentro
	WHERE  O.AñoAdjudicacion=@pAño AND O.MesAdjudicacion <= @pMes 
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	
	/*
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,0,sum(ImporteContratado)
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOfertas ON dbo.Sumarigrama.CodCentro = dbo.vwOfertas.CodCentro
	WHERE  AñoAdjudicacion=@pAño-1 AND MesAdjudicacion <= @pMes --AND Adjudicada='S'
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	*/
	
	-- REGULARIZACIONES
		
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM         (SELECT   CodCentro,CodAct1,CodAct2 ,Pais,ImporteContratado
				  FROM     #vwWEB_Regularizaciones_Local REG
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	
	/*
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  NombreDirGeneral,CodAct1,CodAct2,Pais,0,sum(ImporteContratado)
	FROM         (SELECT   CodCentro,CodAct1,CodAct2 ,Pais,ImporteContratado
				  FROM     dbo.vwRegularizaciones
				  WHERE    (AñoAdjudicacion = @pAño-1) AND (MesAdjudicacion <= @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	*/

	-- OFERTASsql	dbo.fnSubActividadOfertasSQL(CodAct1, CodAct2, Reparto) 
		
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT     NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	
	/*
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT     NombreDirGeneral,CodAct1,CodAct2,Pais,0,sum(ImporteContratado)
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE AñoAdjudicacion=@pAño-1 AND month(FAdjudicacion) <= @pMes
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais	
	*/
	
	
	/*
	SELECT NombreDirGeneral,Pais,CodAct1 as CodActividad,Agrupacion as Actividad,CodAct1,CodAct2,Orden,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoAnterior 
	FROM 
		(SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
		 FROM @vContratacionActividades	
		 GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais) OfertasSQL
			INNER JOIN
			dbo.ActividadesSQL ON OfertasSQL.CodAct1 = dbo.ActividadesSQL.CDAC1 AND OfertasSQL.CodAct2 = dbo.ActividadesSQL.CDAC2
	*/
				
	SELECT NombreDirGeneral,Pais,CodAct1 as CodActividad,Agrupacion as Actividad,CodAct1,CodAct2,Orden,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoAnterior,0 as Desglose_AñoAnterior
	FROM 
		(SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
		 FROM @vContratacionActividades	
		 GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais) OfertasSQL
			INNER JOIN
			dbo.ActividadesSQL ON OfertasSQL.CodAct1 = dbo.ActividadesSQL.CDAC1 AND OfertasSQL.CodAct2 = dbo.ActividadesSQL.CDAC2
			
	UNION -- Nivel Superior de Año Anterior	
	
	SELECT  '',Mercado,dbo.fnAgrupacionCDAC1(Agrupacion),Agrupacion,dbo.fnAgrupacionCDAC1(Agrupacion),'00',dbo.fnOrdenActividadAgrupacion(Agrupacion),0,sum(Importe),0 as Desglose_AñoAnterior
	FROM Historico_Mercado_SubActividadSQL
	WHERE Año=@pAño-1 
	GROUP BY Agrupacion,Mercado	
	
	UNION -- Desglose de Año Anterior
	
	--SELECT  '',Mercado,dbo.fnAgrupacionCDAC1(Agrupacion),Agrupacion,dbo.fnAgrupacionCDAC1(Agrupacion),CodAct2,dbo.fnOrdenActividadAgrupacion(Agrupacion),0,sum(Importe*1000),1 as Desglose_AñoAnterior
	--FROM Historico_Mercado_SubActividadSQL
	--WHERE Año=@pAño-1 
	--GROUP BY Agrupacion,Mercado,CodAct2	
	
	SELECT  '',Mercado,dbo.fnAgrupacionCDAC1(Agrupacion),Agrupacion,dbo.fnAgrupacionCDAC1(Agrupacion),CodAct2,dbo.fnOrdenActividadAgrupacion(Agrupacion),0,sum(Importe),1 as Desglose_AñoAnterior
	FROM Historico_Mercado_SubActividadSQL
	WHERE Año=@pAño-1 
	GROUP BY Agrupacion,Mercado,CodAct2			
	
END