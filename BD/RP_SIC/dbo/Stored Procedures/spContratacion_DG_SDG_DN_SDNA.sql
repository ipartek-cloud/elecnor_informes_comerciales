CREATE PROCEDURE [dbo].[spContratacion_DG_SDG_DN_SDNA] 		
	@pAño int,
	@pMes int,
	@pLoginUsuario nvarchar(100) = NULL
	AS
BEGIN
    ----------------------------------------------------------
    -- Paco 16/02/2026
    -- Recuperar el Sumarigrama del ejercicio consultado
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
    -- Comprobamos si existe la tabla con el sumarigrama del ejercicio consultado.
    -- Por ejemplo, si consultamos en 2025, comprobamos si existe Sumarigrama2025, en cuyo caso Sumarigrama tiene le sumarigrama del ejercicio siguiente (2026)
    SET @TablaSumarigrama = 'Sumarigrama'+CAST(@pAño as varchar(4))
    
    IF OBJECT_ID(@TablaSumarigrama, 'U') IS NOT NULL
        -- Sumarigrama tiene el ejercicio siguiente y los datos del ejercicio consultado estan en "su" SumarigramaXXXX
        SET @SQL_Sumarigrama = 'SELECT * FROM ' + @TablaSumarigrama
    ELSE
        SET @SQL_Sumarigrama = 'SELECT * FROM Sumarigrama'

    INSERT INTO #Sumarigrama
    EXEC sp_executesql  @SQL_Sumarigrama

    -- ═══════════════════════════════════════════════════════════════
    -- BLOQUE RLS: Filtrado de seguridad sobre #Sumarigrama
    -- ═══════════════════════════════════════════════════════════════
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
    -- ═══════════════════════════════════════════════════════════════
    ----------------------------------------------------------

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



	DECLARE @vContratacionMensualInfraEstructuras TABLE (CodSubDirGeneral int,NombreSubDirGeneral varchar(100),NombreDirNegocio varchar(30),NombreSubDirNegocioArea varchar(100), Pais varchar(50), ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- TODOS
	INSERT INTO @vContratacionMensualInfraEstructuras(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,'', 0 ,0,0
	FROM #Sumarigrama S
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea

	-- OFERTAS
	INSERT INTO @vContratacionMensualInfraEstructuras(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais, sum(ImporteContratado) as ImporteContratado,0,0
	FROM #Sumarigrama S INNER JOIN
		 #vwWEB_OFERTAS_CA_Local vwOfertas ON S.CodCentro = vwOfertas.CodCentro
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion = @pMes 
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais
	
	INSERT INTO @vContratacionMensualInfraEstructuras(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,0, sum(ImporteContratado) as ImporteContratado,0
	FROM #Sumarigrama S INNER JOIN
		 #vwWEB_OFERTAS_CA_Local vwOfertas ON S.CodCentro = vwOfertas.CodCentro
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes 
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacionMensualInfraEstructuras(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,vwRegularizacionesQ.Pais, sum(vwRegularizacionesQ.ImporteContratado) as ImporteContratado,0,0
	FROM         (SELECT   CodCentro, CodOferta, NumRegularizacion, FAlta, DescripcionOferta, CodCliente, Localidad, CodProv, ImporteAprox, 
							FPresentacion, PresupuestoVenta, FAdjudicacion, AñoAdjudicacion, MesAdjudicacion, Adjudicada, ImporteContratado,Pais
				  FROM     #vwRegularizaciones_Local vwRegularizaciones
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion = @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 #Sumarigrama S ON vwRegularizacionesQ.CodCentro = S.CodCentro
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais
	
	INSERT INTO @vContratacionMensualInfraEstructuras(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,vwRegularizacionesQ.Pais, 0, sum(vwRegularizacionesQ.ImporteContratado) as ImporteContratado,0
	FROM         (SELECT   CodCentro, CodOferta, NumRegularizacion, FAlta, DescripcionOferta, CodCliente, Localidad, CodProv, ImporteAprox, 
							FPresentacion, PresupuestoVenta, FAdjudicacion, AñoAdjudicacion, MesAdjudicacion, Adjudicada, ImporteContratado,Pais
				  FROM     #vwRegularizaciones_Local vwRegularizaciones
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 #Sumarigrama S ON vwRegularizacionesQ.CodCentro = S.CodCentro
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais
	
	-- OFERTASsql
	INSERT INTO @vContratacionMensualInfraEstructuras(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)		
	SELECT     CodSubDirGeneral,NombreSubDirGeneral, NombreDirNegocio,NombreSubDirNegocioArea, dbo.Provincias.Pais, sum(dbo.OfertasSQL.ImporteContratado) as ImporteContratado,0,0
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      #Sumarigrama S ON dbo.OfertasSQL.CodCentro = S.CodCentro
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) = @pMes
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais 
	
	INSERT INTO @vContratacionMensualInfraEstructuras(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)		
	SELECT     CodSubDirGeneral,NombreSubDirGeneral, NombreDirNegocio,NombreSubDirNegocioArea, dbo.Provincias.Pais, 0, sum(dbo.OfertasSQL.ImporteContratado) as ImporteContratado,0
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      #Sumarigrama S ON dbo.OfertasSQL.CodCentro = S.CodCentro
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais 
	
		
			
	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacionMensualInfraEstructuras(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Mercado,0, 0,sum(Importe) 
	FROM #Sumarigrama S INNER JOIN
		 dbo.HistoricoContratacionGrupoSQL ON S.CodCentro = dbo.HistoricoContratacionGrupoSQL.CodCentro
	WHERE  dbo.HistoricoContratacionGrupoSQL.Año=@pAño-1 AND Mes <= @pMes 
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Mercado	
	
	SELECT CodSubDirGeneral,NombreSubDirGeneral,C.NombreDirNegocio,NombreSubDirNegocioArea,Pais, sum(ImporteContratado) as ImporteContratado,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
			, ISNULL(O.SumaDeImporte,0) ImporteObjetivo
	FROM @vContratacionMensualInfraEstructuras C
			LEFT JOIN (
						SELECT OAS.Año, S.CodDDirNegocio, S.NombreDirNegocio, CASE WHEN OAS.Mercado='N' THEN 'Nacional' ELSE 'Internacional' END Mercado, Sum(OAS.Importe) AS SumaDeImporte
						FROM #Sumarigrama S INNER JOIN ObjetivosActividadSQL OAS ON S.CodCentro = OAS.CodCentro
						where OAS.Año= @pAño 
						GROUP BY OAS.Año, S.CodDDirNegocio, S.NombreDirNegocio, OAS.Mercado
						) O ON C.NombreDirNegocio=O.NombreDirNegocio AND C.Pais=O.Mercado 
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,C.NombreDirNegocio,NombreSubDirNegocioArea,Pais, ISNULL(O.SumaDeImporte,0)



END