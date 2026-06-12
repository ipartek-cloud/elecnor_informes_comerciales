CREATE PROCEDURE [dbo].[spContratacion_PorOferta_BACKUP] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	--[spContratacion_PorOferta_BACKUP] 2024,12

	/*
---------------------------------------------------------------- desde AQUÍ
	*/
	-- Copia en local y filtrada de los datos de la vista vwWEB_OFERTAS_CA (acceso al AS400)
	DECLARE @SQL_AS400_select as varchar(max)
	DECLARE @SQL_AS400_from as varchar(max)
	DECLARE @SQL_AS400 as varchar(max)

	-- No se muy bien pero el EXEC no me funciona con SELECT INTO. POr eso lo hago con CREATE TABLE + INSERT INTO
	CREATE TABLE #vwWEB_OFERTAS_CA_Local  (CodCentro varchar(3),CodOferta varchar(10), NumRegularizacion numeric (3,0), FAlta datetime, DescripcionOferta varchar (100), 
											CodCliente varchar(10), Localidad varchar(100), CodProv varchar(2), ImporteAprox float, FPresentacion datetime, PresupuestoVenta float, 
											FAdjudicacion datetime, AñoAdjudicacion numeric(4,0), MesAdjudicacion numeric(2,0), Adjudicada varchar(1), ImporteContratado float, Pais varchar(100))

	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_CA_Local (CodCentro, CodOferta, NumRegularizacion, FAlta, DescripcionOferta, CodCliente, Localidad,
																	CodProv, ImporteAprox, FPresentacion, PresupuestoVenta, 
																	FAdjudicacion, AñoAdjudicacion, MesAdjudicacion, Adjudicada, ImporteContratado, Pais)
							SELECT RIGHT(''000'' + CAST(Ofertas.CDCEN as varchar(3)),3) AS CodCentro, Ofertas.CDOFT AS CodOferta, 0 AS NumRegularizacion, 
									dbo.fgConvertirFechaDMY(Ofertas.FECHAA) AS FAlta, Ofertas.DCOF AS DescripcionOferta, 
									Ofertas.CDCLI AS CodCliente, Ofertas.LOCAL AS Localidad, Ofertas.PROOF AS CodProv, Ofertas.IMAOF AS ImporteAprox, 
									dbo.fgConvertirFechaDMY(Ofertas.FECHPP) AS FPresentacion, Ofertas.PREVE AS PresupuestoVenta, 
									dbo.fgConvertirFechaDMY(Ofertas.FECHAD) AS FAdjudicacion, 
									YEAR(dbo.fgConvertirFechaDMY(Ofertas.FECHAD)) AS AñoAdjudicacion, 
									MONTH(dbo.fgConvertirFechaDMY(Ofertas.FECHAD)) AS MesAdjudicacion, Ofertas.ADELE AS Adjudicada, 
									Ofertas.PREAD AS ImporteContratado, Provincias.Pais
							'
	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, ''
										SELECT     *
										FROM S44DD901.ICOMERF.IC09AP 
										WHERE ADELE = ''''S''''
										-------------------------------------------------------------------------------------------------
										 -- Paco 2025-03-31 Para que tenga en cuenta la contratación a origen
										 -- AND (substr( digits(dec(19000000+FECHAD,8,0)), 1, 4 ) = ' + CAST(@pAño as varchar(4)) + ' AND substr( digits(dec(19000000+FECHAD,8,0)), 5, 2 ) <= ' + CAST(@pMes as varchar(2)) + ')
										 AND (
												((substr( digits(dec(19000000+FECHAD,8,0)), 1, 4 ) = ' + CAST(@pAño as varchar(4)) + ' AND substr( digits(dec(19000000+FECHAD,8,0)), 5, 2 ) <= ' + CAST(@pMes as varchar(2)) + '))
											OR 
												(substr( digits(dec(19000000+FECHAD,8,0)), 1, 4 ) < ' + CAST(@pAño as varchar(4)) + ' )
											)
										-------------------------------------------------------------------------------------------------
								'')'

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') Ofertas INNER JOIN Provincias ON Ofertas.PROOF = Provincias.CDPRO'

	--PRINT (@SQL_AS400)
	EXEC (@SQL_AS400)

	CREATE TABLE #vwRegularizaciones_Local  (CodCentro varchar(3),CodOferta varchar(10), NumRegularizacion numeric (3,0), FAlta datetime, DescripcionOferta varchar (100), 
											CodCliente varchar(10), Localidad varchar(100), CodProv varchar(2), ImporteAprox float, FPresentacion datetime, PresupuestoVenta float, 
											FAdjudicacion datetime, AñoAdjudicacion numeric(4,0), MesAdjudicacion numeric(2,0), Adjudicada varchar(1), ImporteContratado float, Pais varchar(100))

	SET @SQL_AS400_select = 'INSERT INTO #vwRegularizaciones_Local (CodCentro, CodOferta, NumRegularizacion, FAlta, DescripcionOferta, CodCliente, Localidad,
																	CodProv, ImporteAprox, FPresentacion, PresupuestoVenta, 
																	FAdjudicacion, AñoAdjudicacion, MesAdjudicacion, Adjudicada, ImporteContratado, Pais)
							SELECT RIGHT(''000'' + CAST(vReg.CDCEN as varchar(3)),3) AS CodCentro, vReg.CDOFT AS CodOferta, ISNULL(vReg.NUMRE, 0) AS NumRegularizacion, dbo.fgConvertirFechaDMY(vReg.FECHAA) AS FAlta, 
									vReg.DCOF AS DescripcionOferta, vReg.CDCLI AS CodCliente, vReg.LOCAL AS Localidad, vReg.PROOF AS CodProv, vReg.IMAOF AS ImporteAprox, 
									 dbo.fgConvertirFechaDMY(vReg.FECHPP) AS FPresentacion, vReg.PREVE AS PresupuestoVenta, dbo.fgConvertirFechaDMY(vReg.FECHAR) AS FAdjudicacion, 
									 YEAR(dbo.fgConvertirFechaDMY(vReg.FECHAR)) AS AñoAdjudicacion, MONTH(dbo.fgConvertirFechaDMY(vReg.FECHAR)) AS MesAdjudicacion, 
									 vReg.ADELE AS Adjudicada, vReg.IMPRE AS ImporteContratado, dbo.fnPais(vReg.CDAUT) AS Pais
							'
	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, ''
										SELECT REG.CDCEN, REG.CDOFT, REG.NUMRE, OFE.FECHAA, OFE.DCOF, OFE.CDCLI, OFE.LOCAL, OFE.PROOF, OFE.IMAOF,
												OFE.FECHPP, OFE.PREVE, REG.FECHAR, 
												substr( digits(dec(19000000+REG.FECHAR,8,0)), 1, 4 ) AA, 
												substr( digits(dec(19000000+REG.FECHAR,8,0)), 5, 2 ) MM, 
												substr( digits(dec(19000000+REG.FECHAR,8,0)), 7, 2 ) DD
												,OFE.ADELE, REG.IMPRE, AUT.CDAUT 
										FROM S44DD901.ICOMERF.IC09AP OFE INNER JOIN S44DD901.ICOMERF.IC10AP REG ON OFE.CDOFT = REG.CDOFT
											INNER JOIN S44DD901.ICOMERF.IC05AP PRO ON PRO.CDPRO = OFE.PROOF 
												INNER JOIN S44DD901.ICOMERF.IC11AP AUT ON PRO.CDAUT = AUT.CDAUT
										-------------------------------------------------------------------------------------------------
										-- Paco 2025-03-31 Para que tenga en cuenta la contratación a origen
										-- WHERE (substr( digits(dec(19000000+REG.FECHAR,8,0)), 1, 4 ) = ' + CAST(@pAño as varchar(4)) + ' AND substr( digits(dec(19000000+REG.FECHAR,8,0)), 5, 2 ) <= ' + CAST(@pMes as varchar(2)) + ')
										WHERE (
													((substr( digits(dec(19000000+REG.FECHAR,8,0)), 1, 4 ) = ' + CAST(@pAño as varchar(4)) + ' AND substr( digits(dec(19000000+FECHAR,8,0)), 5, 2 ) <= ' + CAST(@pMes as varchar(2)) + '))
												OR
													(substr( digits(dec(19000000+FECHAR,8,0)), 1, 4 ) < ' + CAST(@pAño as varchar(4)) + ' )
												)
											-------------------------------------------------------------------------------------------------
									'')'

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vReg '

	--PRINT (@SQL_AS400)
	EXEC (@SQL_AS400)
	
---------------------------------------------------------------- hasta AQUÍ

--SELECT '#vwWEB_OFERTAS_CA_Local', * FROM #vwWEB_OFERTAS_CA_Local
--SELECT '#vwRegularizaciones_Local', * FROM #vwRegularizaciones_Local
--SELECT 'OfertasSQL', * FROM OfertasSQL
--SELECT 'HistoricoContratacionGrupoSQL', * FROM HistoricoContratacionGrupoSQL


	DECLARE @vContratacionMensualInfraEstructuras TABLE (CodOferta varchar(10), CodSubDirGeneral int,NombreSubDirGeneral varchar(100),NombreDirNegocio varchar(30),NombreSubDirNegocioArea varchar(100), Pais varchar(50)
			, ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- OFERTAS
	
	INSERT INTO @vContratacionMensualInfraEstructuras(CodOferta, CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT --'vwOfertas',
			CodOferta
			, CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,0, sum(ImporteContratado) as ImporteContratado,0
	FROM #vwWEB_OFERTAS_CA_Local vwOfertas 
			INNER JOIN dbo.Sumarigrama ON vwOfertas.CodCentro = dbo.Sumarigrama.CodCentro 
	-------------------------------------------------------------------------------------------------
	-- Paco 2025-03-31 Para que tenga en cuenta la contratación a origen
	-- WHERE AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes
	WHERE  AñoAdjudicacion<@pAño OR (AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes)
	-------------------------------------------------------------------------------------------------
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais, CodOferta
	ORDER BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais, CodOferta
	
	-- REGULARIZACIONES

	INSERT INTO @vContratacionMensualInfraEstructuras(CodOferta, CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT --'vwRegularizaciones', 
			CodOferta
			, CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,vwRegularizacionesQ.Pais, 0, sum(vwRegularizacionesQ.ImporteContratado) as ImporteContratado,0
	FROM         (SELECT   CodCentro, CodOferta, NumRegularizacion, FAlta, DescripcionOferta, CodCliente, Localidad, CodProv, ImporteAprox, 
							FPresentacion, PresupuestoVenta, FAdjudicacion, AñoAdjudicacion, MesAdjudicacion, Adjudicada, ImporteContratado,Pais
				  FROM     #vwRegularizaciones_Local vwRegularizaciones
  				  -------- -------------------------------------------------------------------------------------------
				  -- Paco 2025-03-31 Para que tenga en cuenta la contratación a origen
				  -- WHERE (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes) 
				  WHERE (AñoAdjudicacion < @pAño) OR ((AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes))
  				  -------------------------------------------------------------------------------------------------
				  ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais, CodOferta
	ORDER BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais, CodOferta
	
	-- OFERTASsql
	
	INSERT INTO @vContratacionMensualInfraEstructuras(CodOferta, CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT --'OfertasSQL', 
			CodOferta
			, CodSubDirGeneral,NombreSubDirGeneral, NombreDirNegocio,NombreSubDirNegocioArea, dbo.Provincias.Pais, 0, sum(dbo.OfertasSQL.ImporteContratado) as ImporteContratado,0
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
  	-------------------------------------------------------------------------------------------------
	-- Paco 2025-03-31 Para que tenga en cuenta la contratación a origen
	-- WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	WHERE AñoAdjudicacion<@pAño  OR (AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes)
  	-------------------------------------------------------------------------------------------------
		AND Reparto=0
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais, CodOferta
	ORDER BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais, CodOferta
	
		
			
	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacionMensualInfraEstructuras(CodOferta, CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT --'HistoricoContratacionGrupoSQL', 
			CodOferta
			, CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Mercado,0, 0,sum(Importe) 
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.HistoricoContratacionGrupoSQL ON dbo.Sumarigrama.CodCentro = dbo.HistoricoContratacionGrupoSQL.CodCentro
	WHERE  dbo.HistoricoContratacionGrupoSQL.Año=@pAño-1 AND Mes <= @pMes 
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Mercado, CodOferta
	ORDER BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Mercado, CodOferta
		
	SELECT CodOferta
			-- , CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais
			-- , sum(ImporteContratado) as ImporteContratado
			,Sum(ImporteContratadoAcumulado + ImporteContratadoAcumuladoAñoAnterior) as ImporteContratado 
	FROM @vContratacionMensualInfraEstructuras
	GROUP BY CodOFerta-- , CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais
	ORDER BY CodOferta

END
