CREATE PROCEDURE [dbo].[spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS] 		
	@pAño int,
	@pMes int,
	@pLoginUsuario nvarchar(100) = NULL
	AS
BEGIN
	SET NOCOUNT ON;

	-- ═══════════════════════════════════════════════════════════════
	-- BLOQUE RLS: Filtrado de #Sumarigrama por permisos de usuario
	-- ═══════════════════════════════════════════════════════════════
	DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20)

	SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad 
	FROM dbo.WEB_Usuarios WITH (NOLOCK) 
	WHERE Usuario = @pLoginUsuario

	CREATE TABLE #Sumarigrama (
		[Año] SMALLINT NOT NULL,
		[CodCentro] VARCHAR (3) NULL,
		[CodSubDirGeneral] VARCHAR (3) NULL,
		[CodDDirNegocio] VARCHAR (3) NULL,
		[CodSubDirNegocioArea] VARCHAR (3) NULL,
		[CodDelegacion] VARCHAR (3) NULL
	);

	IF @vPuesto = 'DG' OR @vPuesto IS NULL OR @pLoginUsuario IS NULL
	BEGIN
		-- Visión global total para DG o si no se provee login
		INSERT INTO #Sumarigrama (Año, CodCentro, CodSubDirGeneral, CodDDirNegocio, CodSubDirNegocioArea, CodDelegacion)
		SELECT Año, CodCentro, CodSubDirGeneral, CodDDirNegocio, CodSubDirNegocioArea, CodDelegacion
		FROM dbo.Sumarigrama WHERE Año = @pAño
	END
	ELSE
	BEGIN
		-- Visión restringida (RLS) según jerarquía
		INSERT INTO #Sumarigrama (Año, CodCentro, CodSubDirGeneral, CodDDirNegocio, CodSubDirNegocioArea, CodDelegacion)
		SELECT S.Año, S.CodCentro, S.CodSubDirGeneral, S.CodDDirNegocio, S.CodSubDirNegocioArea, S.CodDelegacion
		FROM dbo.Sumarigrama S 
		WHERE S.Año = @pAño
		  AND (
			  (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad) OR
			  (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad) OR
			  (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad) OR
			  (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad) OR
			  (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)
		  )
	END
	-- ═══════════════════════════════════════════════════════════════

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
	FROM #Sumarigrama INNER JOIN
		 #vwWEB_OFERTAS_CA_Local vwOfertas ON #Sumarigrama.CodCentro = vwOfertas.CodCentro 		
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
							 #Sumarigrama ON vwRegularizacionesQ.CodCentro = #Sumarigrama.CodCentro
	GROUP BY vwRegularizacionesQ.CodCentro
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  o.CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(o.FAdjudicacion,@pAño,@pMes,o.ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(o.FAdjudicacion,@pAño,@pMes,o.ImporteContratado)) as ImporteContratadoAcumulado,
			0 
	FROM    dbo.OfertasSQL o
	INNER JOIN #Sumarigrama s ON o.CodCentro = s.CodCentro
	WHERE  (year(o.FAdjudicacion)=@pAño) AND month(o.FAdjudicacion) <= @pMes 
	GROUP BY o.CodCentro	
	
	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT h.CodCentro,0, 0,sum(h.Importe) 
	FROM dbo.HistoricoContratacionGrupoSQL h
	INNER JOIN #Sumarigrama s ON h.CodCentro = s.CodCentro
	WHERE  h.Año=@pAño-1 AND h.Mes <= @pMes 
	GROUP BY h.CodCentro
	
	SELECT cg.NombreGerente, cg.SumarizaGerentes, cg.CodCentro, cg.Mercado, cg.Orden, sum(isnull(c.ImporteContratado,0)) as ImporteContratado, Sum(isnull(c.ImporteContratadoAcumulado,0)) as ImporteContratadoAcumulado, sum(isnull(c.ImporteContratadoAcumuladoAñoAnterior,0)) as ImporteContratadoAcumuladoAñoAnterior, sum(isnull(obj.Importe,0)) as Objetivos, @pAño AS Año, @pLoginUsuario AS LoginUsuario 
	FROM dbo.CentrosGerentesSQL cg
	LEFT JOIN #Sumarigrama s ON cg.CodCentro = s.CodCentro
	LEFT JOIN @vContratacion c ON c.CodCentro = cg.CodCentro AND cg.Año = @pAño
	LEFT JOIN dbo.vwObjetivosActividadSQL_Nacional_Internacional obj ON cg.CodCentro = obj.CodCentro AND obj.Año = @pAño
	WHERE cg.Año = @pAño
	  AND (@vPuesto = 'DG' OR @vPuesto IS NULL OR @pLoginUsuario IS NULL OR s.CodCentro IS NOT NULL)
	GROUP BY cg.NombreGerente, cg.SumarizaGerentes, cg.CodCentro, cg.Mercado, cg.Orden
	ORDER BY cg.CodCentro;

	DROP TABLE #Sumarigrama;
		
END