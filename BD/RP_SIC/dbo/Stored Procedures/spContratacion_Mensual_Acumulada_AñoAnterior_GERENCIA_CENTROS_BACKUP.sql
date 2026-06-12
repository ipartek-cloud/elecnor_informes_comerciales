CREATE PROCEDURE [dbo].[spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS_BACKUP] 		
	@pAño int,
	@pMes int
	AS
BEGIN

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
							SELECT Ofertas.CDCEN AS CodCentro, Ofertas.CDOFT AS CodOferta, 0 AS NumRegularizacion, 
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
											 AND (substr( digits(dec(19000000+FECHAD,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+FECHAD,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
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
							SELECT vReg.CDCEN AS CodCentro, vReg.CDOFT AS CodOferta, ISNULL(vReg.NUMRE, 0) AS NumRegularizacion, dbo.fgConvertirFechaDMY(vReg.FECHAA) AS FAlta, 
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
										WHERE (substr( digits(dec(19000000+REG.FECHAR,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+REG.FECHAR,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
									'')'

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vReg '

	--PRINT (@SQL_AS400)
	EXEC (@SQL_AS400)
	
---------------------------------------------------------------- hasta AQUÍ



	DECLARE @vContratacion TABLE (CodCentro varchar(3), ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- OFERTAS
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  vwOfertas.CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM dbo.Sumarigrama INNER JOIN
		 #vwWEB_OFERTAS_CA_Local vwOfertas ON dbo.Sumarigrama.CodCentro = vwOfertas.CodCentro 		
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY vwOfertas.CodCentro	
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  vwRegularizacionesQ.CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0 
	FROM         (SELECT   CodCentro, CodOferta, NumRegularizacion, FAlta, DescripcionOferta, CodCliente, Localidad, CodProv, ImporteAprox, 
							FPresentacion, PresupuestoVenta, FAdjudicacion, AñoAdjudicacion, MesAdjudicacion, Adjudicada, ImporteContratado,Pais
				  FROM     #vwRegularizaciones_Local vwRegularizaciones
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY vwRegularizacionesQ.CodCentro
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0 
	FROM    dbo.OfertasSQL	
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro	
	
	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT HistoricoContratacionGrupoSQL.CodCentro,0, 0,sum(Importe) 
	FROM dbo.HistoricoContratacionGrupoSQL 
	WHERE  Año=@pAño-1 AND Mes <= @pMes 
	GROUP BY CodCentro

	
	SELECT NombreGerente,CentrosGerentesSQL.CodCentro, sum(isnull(ImporteContratado,0)) as ImporteContratado,Sum(isnull(ImporteContratadoAcumulado,0)) as ImporteContratadoAcumulado, sum(isnull(ImporteContratadoAcumuladoAñoAnterior,0)) as ImporteContratadoAcumuladoAñoAnterior 
	FROM CentrosGerentesSQL	LEFT JOIN @vContratacion ON
		[@vContratacion].CodCentro=CentrosGerentesSQL.CodCentro	AND CentrosGerentesSQL.Año=@pAño
	GROUP BY NombreGerente,CentrosGerentesSQL.CodCentro
	ORDER BY CentrosGerentesSQL.CodCentro
		
END
