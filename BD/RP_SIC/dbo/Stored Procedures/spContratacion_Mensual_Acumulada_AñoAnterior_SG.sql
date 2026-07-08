
CREATE PROCEDURE [dbo].[spContratacion_Mensual_Acumulada_AñoAnterior_SG] 		
	@pAño int,
	@pMes int,
	@pLoginUsuario nvarchar(100) = NULL
	AS
BEGIN

    ----------------------------------------------------------
    -- RLS: Carga la jerarquía organizativa del año y filtra según el puesto del usuario
    CREATE TABLE #Sumarigrama
    (
        Año                     smallint      not null,
        CodDirGeneral           varchar(3),
        NombreDirGeneral        nvarchar(100) not null,
        CodSubDirGeneral        varchar(3),
        NombreSubDirGeneral     nvarchar(100) not null,
        CodDDirNegocio          varchar(3),
        NombreDirNegocio        nvarchar(30)  not null,
        CodSubDirNegocioArea    varchar(3),
        NombreSubDirNegocioArea nvarchar(100) not null,
        CodDelegacion           varchar(3),
        NombreDelegacion        nvarchar(30)  not null,
        CodCentro               varchar(3),
        NombreCentro            nvarchar(30)  not null,
        OrdenSubDirGeneral      int           not null
    )
	DECLARE @SQL_Sumarigrama as nvarchar(max)
    DECLARE @TablaSumarigrama as varchar(100)
    SET @TablaSumarigrama = 'Sumarigrama'+CAST(@pAño as varchar(4))
    
    IF OBJECT_ID(@TablaSumarigrama, 'U') IS NOT NULL
        SET @SQL_Sumarigrama = 'SELECT * FROM ' + @TablaSumarigrama
    ELSE
        SET @SQL_Sumarigrama = 'SELECT * FROM Sumarigrama'

    INSERT INTO #Sumarigrama
    EXEC sp_executesql  @SQL_Sumarigrama

    IF @pLoginUsuario IS NOT NULL
    BEGIN
        DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20)
        
        SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad 
        FROM dbo.WEB_Usuarios WITH (NOLOCK) 
        WHERE Usuario = @pLoginUsuario
        
        IF @vPuesto IS NOT NULL AND @vPuesto <> 'DG'
        BEGIN
            DELETE FROM #Sumarigrama
            WHERE NOT (
                (@vPuesto = 'SDG'  AND CodSubDirGeneral = @vCodEntidad) OR
                (@vPuesto = 'DN'   AND CodDDirNegocio = @vCodEntidad) OR
                (@vPuesto = 'AREA' AND CodSubDirNegocioArea = @vCodEntidad) OR
                (@vPuesto = 'DEL'  AND CodDelegacion = @vCodEntidad) OR
                (@vPuesto = 'CT'   AND CodCentro = @vCodEntidad)
            )
        END
    END
    ----------------------------------------------------------

    ----------------------------------------------------------
    -- Extrae OFERTAS y Regularizaciones del AS400 vía OPENQUERY
    -- con JOIN a Provincias para obtener el país (Nacional/Internacional)
    DECLARE @SQL_AS400_select as varchar(1000)
	DECLARE @SQL_AS400_from as varchar(1000)
	DECLARE @SQL_AS400 as varchar(max)

	CREATE TABLE #vwWEB_OFERTAS_Local  (CodCentro varchar(3),CodOferta varchar(10), 
										DescripcionOferta varchar(100), 
										CodCliente varchar(100), 
										Localidad varchar (100),
										CodProv varchar(2),
										CodAct1 varchar(5),
										CodAct2 varchar(5),
										CodResponsable varchar(5), 
										FAdjudicacion datetime,
										ImporteContratado float,
										Pais varchar(100),
										Provincia varchar(100))

	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_Local (CodCentro, CodOferta, 
																DescripcionOferta, CodCliente, Localidad, CodProv, CodAct1, CodAct2, CodResponsable, 
																FAdjudicacion, ImporteContratado
																, Pais, Provincia)
							SELECT CDCEN AS CodCentro, CDOFT AS CodOferta, DCOF AS DescripcionOferta, CDCLI AS CodCliente, LOCAL AS Localidad, PROOF AS CodProv, CDAC1 AS CodAct1, CDAC2 AS CodAct2, RPROF AS CodResponsable,  
									CASE WHEN LEN(FECHAD) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAD, 6), 103) 
										ELSE (CASE WHEN FECHAD = ''0'' THEN ''19990101'' ELSE NULL END) 
									END AS FAdjudicacion, 
									PREAD AS ImporteContratado
							,  Provincias.Pais, NMPRO as Provincia
							'
	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, ''
										SELECT     *
										FROM S44DD901.ICOMERF.IC09AP 
										WHERE ADELE = ''''S''''
											 AND (substr( digits(dec(19000000+FECHAD,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+FECHAD,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
									'')'
	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') Ofertas INNER JOIN Provincias ON Ofertas.PROOF = Provincias.CDPRO'

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

	EXEC (@SQL_AS400)
    ----------------------------------------------------------

	DECLARE @vContratacion TABLE (CodCentro varchar(3),ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)

	-- OFERTAS
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  vwOfertas.CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM #Sumarigrama INNER JOIN
		 #vwWEB_OFERTAS_Local vwOfertas ON #Sumarigrama.CodCentro = vwOfertas.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY vwOfertas.CodCentro
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  vwRegularizacionesQ.CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM #vwRegularizaciones_Local AS vwRegularizacionesQ
				INNER JOIN #Sumarigrama ON vwRegularizacionesQ.CodCentro = #Sumarigrama.CodCentro
	GROUP BY vwRegularizacionesQ.CodCentro
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  OfertasSQL.CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM dbo.OfertasSQL INNER JOIN #Sumarigrama ON dbo.OfertasSQL.CodCentro = #Sumarigrama.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY OfertasSQL.CodCentro

	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT dbo.HistoricoContratacionGrupoSQL.CodCentro,0, 0,sum(Importe) 
	FROM #Sumarigrama INNER JOIN
		 dbo.HistoricoContratacionGrupoSQL ON #Sumarigrama.CodCentro = dbo.HistoricoContratacionGrupoSQL.CodCentro
	WHERE  HistoricoContratacionGrupoSQL.Año=@pAño-1 AND Mes <= @pMes 
	GROUP BY dbo.HistoricoContratacionGrupoSQL.CodCentro
	
	SELECT CodCentro,
		   Sum(ImporteContratado) as ImporteContratado,
		   Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado,
		   sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 	
	FROM @vContratacion	
	GROUP BY CodCentro
	
	DROP TABLE #Sumarigrama;

END
