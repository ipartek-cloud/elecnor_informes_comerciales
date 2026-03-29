
-- =============================================
-- Author:		Carlos García García
-- Create date: 2014-06-05
-- Modify date: 2014-06-16 Permite filtrar por diferentes campos
-- Modify date: 2014-06-19 Permite filtrar por fechas
-- Modify date: 2014-06-19 Permite filtrar por importe y subdirecciones
-- Description:	Obtiene las ofertas de AS400 que hay que mostrar en la web de Gestión Comercial Internacional
-- =============================================
CREATE PROCEDURE [dbo].[spWEB_GCI_ObtenerOfertasInternacionales]
	@IdPais as varchar(3) = NULL, 
    @Concepto as varchar(255) = NULL, 
    @ZonaComercial as int = NULL, 
	@ProyectoSingular as bit = NULL, 
	@OfertaAsunto as bit = NULL,
	@OfertaPreparacion as bit = NULL, 
	@OfertaPresentada as bit = NULL, 
	@OfertaDenegada as bit = NULL, 
	@OfertaAdjudicada as bit = NULL,
	@fechaDesde as datetime = NULL, 
	@operacionFecha as varchar(5) = NULL, 
	@idResponsableComercial as varchar(3) = NULL, 
	@ImporteDesde AS money = NULL, 
    @ImporteHasta as money = NULL, 
    @OperacionImporte as varchar(10) = NULL,
    @SDGEnergia as bit = NULL, 
    @SDGRedes as bit = NULL, 
    @SDGInstalacionesCentro as bit = NULL, 
	@SDGInstalacionesNorteAmerica as bit = NULL, 
	@SDGInstalacionesNordeste as bit = NULL, 
	@SDGInstalacionesSur as bit = NULL, 
	@SDGInstalacionesEste as bit = NULL, 
	@SDGIngenieria as bit = NULL	
AS
BEGIN
	SET NOCOUNT ON;

	--REGION DECLARACIÓN E INICIALIZACIÓN DE VARIABLES
	BEGIN 
		DECLARE @SQLQuery AS NVARCHAR(MAX)
		DECLARE @SQLQueryFase AS NVARCHAR(MAX)
		DECLARE @SQLQuerySelect AS NVARCHAR(MAX)
		DECLARE @SQLQueryArchivadas as NVARCHAR(MAX)
		DECLARE @SQLFiltroFase as NVARCHAR(MAX)
		DECLARE @SQLFiltroArchivada as NVARCHAR(MAX)
		DECLARE @ParamDefinition AS NVARCHAR(2000) 
		DECLARE @SQLQueryWhere AS NVARCHAR(MAX)
		   
		SET @SQLQuery = ''
		SET @SQLQueryFase = ''
		SET @SQLQuerySelect = ''
		SET @SQLQueryArchivadas = ''
		SET @SQLFiltroFase = ''
		SET @SQLFiltroArchivada = ''
		SET @SQLQueryWhere = ''
	END	
	--END DE LA REGION DECLARACIÓN E INICIALIZACIÓN DE VARIABLES
	--WHEN (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) AND (ADJUDICADA <> ''S'' AND AÑOAD IS NULL AND MESAD IS NULL)	THEN ''Presentada''
    --REGION: DEFINE EL SELECT QUE SE USARÁ TANTO PARA SACAR LOS OFERTAS VIVAS COMO LAS OFERTAS ARCHIVADAS
	BEGIN
						--CONVERT (DATETIME, CAST(añopres AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(mespres AS VARCHAR(2)), 104) as fechapres,	
						--CAST([AñoPres] AS varchar(4))+''-''+ RIGHT (''00''+ltrim(str(MesPres)),2 ) AS FechaPresentacion 
		SET @SQLQuerySelect = 	'SELECT CASE 
											WHEN Ofertar = ''''   THEN CONVERT (DATETIME, CAST(AñoGra AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+ltrim(str(MesGra)),2 ) AS VARCHAR(2)), 104) 
											WHEN Ofertar = ''NO'' THEN CONVERT (DATETIME, CAST(AñoGra AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+ltrim(str(MesGra)),2 ) AS VARCHAR(2)), 104) 
											WHEN Ofertar = ''SI'' AND(AÑOPRES IS NULL AND MESPRES IS NULL) THEN CONVERT (DATETIME, CAST(AñoGra AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + RIGHT (''00''+ltrim(str(MesGra)),2 ), 104) 
											WHEN Adjudicada = ''N'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(MesPres AS VARCHAR(2)), 104) 
											WHEN Adjudicada = ''S'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN CONVERT (DATETIME, CAST(AñoAd AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(MesAd AS VARCHAR(2)), 104) 
											WHEN Adjudicada = ''''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(MesPres AS VARCHAR(2)), 104) 
										END AS FechaPresentacion, 
										LTRIM(RTRIM([Sumarigrama].NombreDirNegocio)) as Intervinientes, 
										CASE 
											WHEN Ofertar = '''' THEN ''Asunto'' 
											WHEN Ofertar = ''NO'' THEN ''Abandonada'' 
											WHEN Ofertar = ''SI'' AND (AÑOPRES IS NULL AND MESPRES IS NULL) THEN ''Preparación'' 
											WHEN Adjudicada = ''N'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ''Denegada'' 
											WHEN Adjudicada = ''S'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ''Adjudicada'' 
											WHEN Adjudicada = ''''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ''Presentada''
										END as Nombrefase, 
										CAST(CodOfer AS VARCHAR(10)) AS CodOferta, 
										LTRIM(RTRIM(DesOfer)) AS Proyecto,
										LTRIM(RTRIM(NomProvincia)) as NombrePais,
										LTRIM(RTRIM(ClienAgrupado)) as Cliente, 
										Responsable as CodResponsableDeNegocio, 
										CodResponsableComercial,
										CASE 
											WHEN Ofertar = '''' THEN ImpAprox 
											WHEN Ofertar = ''NO'' THEN ImpAprox 
											WHEN (AÑOPRES IS NULL AND MESPRES IS NULL) THEN ImpAprox 
											WHEN Adjudicada = ''N'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpPres 
											WHEN Adjudicada = ''S'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpAdj 
											WHEN Adjudicada = ''''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpPres 
										END AS ImporteEstimadoEnEuros,
										ImpAprox, ImpAdj, ImpPres 
										FROM	[RP_SIC].[dbo].[@@@Ofertas2005] as Ofertas LEFT JOIN  [RP_SIC].[dbo].[Sumarigrama] ON Ofertas.CT = [RP_SIC].[dbo].[Sumarigrama].CodCentro LEFT JOIN [RP_SIC].[dbo].[GCIPaises] P ON Ofertas.CodProvincia = P.IdPais LEFT JOIN [RP_SIC].[DBO].[GCIZonas] Z ON P.IdZona = Z.IdZona LEFT JOIN [RP_SIC].[DBO].[GCIZonasComerciales] ZC ON Z.IdZonacomercial = ZC.IdZonaComercial LEFT JOIN ResponsablesComercialesPorPais RCP on RCP.CodPais = Ofertas.CodProvincia 
										WHERE	
											Mercado = ''Internacional''
											AND BAJA <> ''B'' 
											AND (  
												   (ImpAprox >= 10000000 AND Ofertar =''''    AND  (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+LTRIM(STR(MesGra)),2 ) AS VARCHAR(2)), 104) >= ''2014-01-01'') 
												OR (ImpAprox >= 10000000 AND Ofertar = ''NO'' AND  (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+LTRIM(STR(MesGra)),2 ) AS VARCHAR(2)), 104) >= ''2014-01-01'')) 
												OR (ImpAprox >= 10000000 AND Ofertar = ''SI'' AND AÑOPRES IS NULL AND MESPRES IS NULL AND (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+LTRIM(STR(MesGra)),2 ) AS VARCHAR(2)), 104) >= ''2013-01-01'')) 
												OR (ImPPres  >= 10000000 AND Adjudicada = ''N'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL)	AND (CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+LTRIM(STR(MESPRES)),2 ) AS VARCHAR(2)), 104) >= ''2013-01-01'')) 
												OR (ImPPres  >= 10000000 AND Adjudicada = ''''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL)	AND (CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+LTRIM(STR(MESPRES)),2 ) AS VARCHAR(2)), 104) >= ''2013-01-01'')) 
												OR (ImpAdj   >= 10000000 AND Adjudicada = ''S'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) AND (CONVERT (DATETIME, CAST(AÑOAD   AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+LTRIM(STR(MESAD)),2 )   AS VARCHAR(2)), 104) >= ''2013-01-01''))
												)
											)'
		--SET @SQLQueryFase = @SQLQuerySelect 
								
		IF @idPais Is Not NULL 
		BEGIN 
			Set @SQLQuerySelect = @SQLQuerySelect + ' 
										AND (Ofertas.CodProvincia =  ''' + @IdPais + ''')' 
			Set @SQLQueryWhere = @SQLQueryWhere + ' 
										AND (Ofertas.CodProvincia =  ''' + @IdPais + ''')' 

		END
		
										
		IF @ProyectoSingular Is Not NULL 
		BEGIN 
			Set @SQLQuerySelect = @SQLQuerySelect + ' 
										AND ((Ofertas.ImpAprox >=  50000000) OR
											 (Ofertas.ImpPres >=  50000000) OR
											 (Ofertas.ImpAdj  >= 50000000)) ' 
			Set @SQLQueryWhere = @SQLQueryWhere + ' 
										AND ((Ofertas.ImpAprox >=  50000000) OR
											 (Ofertas.ImpPres >=  50000000) OR
											 (Ofertas.ImpAdj  >= 50000000)) ' 		
		END
		
		IF @OperacionImporte Is Not Null And @ImporteDesde IS NOT NULL
		BEGIN
			--para cada fase hace un @query propio, de manera que filtre por sólo esa fase y su importe correspondiente
			SET @SQLQuerySelect = @SQLQuerySelect + 
										  ' AND (
												 (Ofertar = ''''															AND Ofertas.ImpAprox ' + @OperacionImporte + ' ' + CAST(@ImporteDesde AS VARCHAR) + ') OR
												 (Ofertar = ''NO''															AND Ofertas.ImpAprox ' + @OperacionImporte + ' ' + CAST(@ImporteDesde AS VARCHAR) + ') OR
												 ((AÑOPRES IS NULL AND MESPRES IS NULL)										AND Ofertas.ImpAprox ' + @OperacionImporte + ' ' + CAST(@ImporteDesde AS VARCHAR) + ') OR
												 ((Adjudicada = ''N'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))	AND Ofertas.ImpPres  ' + @OperacionImporte + ' ' + CAST(@ImporteDesde AS VARCHAR) + ') OR
												 ((Adjudicada = ''S'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))	AND Ofertas.ImpAdj   ' + @OperacionImporte + ' ' + CAST(@ImporteDesde AS VARCHAR) + ') OR
												 ((Adjudicada = ''''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))	AND Ofertas.ImpPres  ' + @OperacionImporte + ' ' + CAST(@ImporteDesde AS VARCHAR) + '))'
		END
		
		IF @ZonaComercial Is Not NULL 
		BEGIN 
			Set @SQLQuerySelect = @SQLQuerySelect + '
										AND (ZC.idZonaComercial =  @ZonaComercial )' 
		END

		--If @SDGEnergia Is NULL 
		--	AND @SDGRedes Is NULL 
		--	AND @SDGInstalacionesCentro Is NULL 
		--	AND @SDGInstalacionesNorteAmerica Is NULL 
		--	AND @SDGInstalacionesNordeste Is NULL
		--	AND @SDGInstalacionesSur Is NULL 
		--	AND @SDGInstalacionesEste Is NULL 
		--	AND @SDGIngenieria Is NULL Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio = '''')' 
			
		If		(@SDGEnergia Is NULL OR @SDGEnergia = 0)
			AND (@SDGRedes Is NULL OR @SDGRedes = 0) 
			AND (@SDGInstalacionesCentro Is NULL OR @SDGInstalacionesCentro = 0) 
			AND (@SDGInstalacionesNorteAmerica Is NULL OR @SDGInstalacionesNorteAmerica = 0) 
			AND (@SDGInstalacionesNordeste Is NULL OR @SDGInstalacionesNordeste = 0) 
			AND (@SDGInstalacionesSur Is NULL OR @SDGInstalacionesSur = 0 )  
			AND (@SDGInstalacionesEste Is NULL OR @SDGInstalacionesEste = 0 )  
			AND (@SDGIngenieria Is NULL OR @SDGIngenieria = 0 )  
			BEGIN
				Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio = '''' OR NombreDirNegocio IS NULL)' 
			END
			ELSE
			BEGIN
				If (@SDGEnergia Is NULL OR @SDGEnergia = 0) Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio <>  ''Energía'')'  
				If (@SDGRedes Is NULL OR @SDGRedes = 0)Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio <>  ''Grandes Redes'')'  
				If (@SDGInstalacionesCentro Is NULL OR @SDGInstalacionesCentro = 0) Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio <>  ''Centro'')'  
				If (@SDGInstalacionesNorteAmerica Is NULL OR @SDGInstalacionesNorteAmerica = 0) Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio <>  ''Norteamérica'')'  
				If (@SDGInstalacionesNordeste Is NULL OR @SDGInstalacionesNordeste = 0) Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio <>  ''Nordeste'')'  
				If (@SDGInstalacionesSur Is NULL OR @SDGInstalacionesSur = 0) Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio <>  ''Sur'')'  
				If (@SDGInstalacionesEste Is NULL OR @SDGInstalacionesESte = 0) Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio <>  ''Este'')'  
				If (@SDGIngenieria Is NULL OR @SDGIngenieria = 0) Set @SQLQuerySelect = @SQLQuerySelect + ' AND (NombreDirNegocio <>  ''Ingeniería'')'  
			END
				
		IF @FechaDesde Is NOT NULL AND @operacionFecha IS NOT NULL
		BEGIN	
		  SET @SQLQuerySelect = @SQLQuerySelect + ' AND (CONVERT (DATETIME, CAST(añopres AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(mespres AS VARCHAR(2)), 104) ' + @operacionFecha + ' @FechaDesde )'
			--SET @SQLQuerySelect = @SQLQuerySelect + 
			--							  ' AND (
			--									 (Ofertar = ''''															AND (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+LTRIM(STR(MesGra)),2 ) AS VARCHAR(2)), 104) ' + @operacionFecha + ' @FechaDesde)) OR 
			--									 (Ofertar = ''NO''															AND (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(RIGHT (''00''+LTRIM(STR(MesGra)),2 ) AS VARCHAR(2)), 104) ' + @operacionFecha + ' @FechaDesde)) OR
			--									 ((AÑOPRES IS NULL AND MESPRES IS NULL)										AND (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + RIGHT (''00''+LTRIM(STR(MesGra)),2 ), 104)					  ' + @operacionFecha + ' @FechaDesde)) OR
			--									 ((Adjudicada = ''N'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))	AND (CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(MesPres AS VARCHAR(2)), 104)							  ' + @operacionFecha + ' @FechaDesde)) OR
			--									 ((Adjudicada = ''S'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))	AND (CONVERT (DATETIME, CAST(AñoAd   AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(MesAd AS VARCHAR(2)), 104)								  ' + @operacionFecha + ' @FechaDesde)) OR
			--									 ((Adjudicada = ''''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))	AND (CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + ''-'' + ''01'' + ''-'' + CAST(MesPres AS VARCHAR(2)), 104)							  ' + @operacionFecha + ' @FechaDesde))
			--									) '
		END
		
		IF @idResponsableComercial Is NOT NULL
		BEGIN
			SET @SQLQuerySelect = @SQLQuerySelect + 
										' AND (CodResponsableComercial =  ''' + @idResponsableComercial + ''')' 
		END
		
		DECLARE @filtrosDeFase as int
		SET @filtrosDeFase = 0
		If @OfertaAsunto IS NOT NULL SET @filtrosDeFase = @filtrosDeFase + 1
		If @OfertaPreparacion is NOT NULL SET @filtrosDeFase = @filtrosDeFase + 1
		If @OfertaPresentada IS NOT NULL SET @filtrosDeFase = @filtrosDeFase + 1
		If @OfertaDenegada IS NOT NULL SET @filtrosDeFase = @filtrosDeFase + 1
		If @OfertaAdjudicada IS NOT NULL SET @filtrosDeFase = @filtrosDeFase + 1
	    
		If @filtrosDeFase = 1
		BEGIN
			IF @OfertaAsunto Is Not NULL Set @SQLQueryFase = @SQLQueryFase + ' AND (Ofertar = ''NO'' OR Ofertar = '''')' 
			IF @OfertaPreparacion is NOT NULL Set @SQLQueryFase = @SQLQueryFase + ' AND ((AÑOPRES IS NULL AND MESPRES IS NULL) AND (Ofertar = ''SI''))' 
			IF @OfertaPresentada is NOT NULL Set @SQLQueryFase = @SQLQueryFase + '  AND (Adjudicada = '''') AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL AND AÑOGRA IS NOT NULL)' 			
			IF @OfertaDenegada is NOT NULL Set @SQLQueryFase = @SQLQueryFase + '    AND (Adjudicada = ''N'') AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL)' 
			IF @OfertaAdjudicada  is NOT NULL Set @SQLQueryFase = @SQLQueryFase + ' AND (Adjudicada = ''S'') AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL)' 
		END
		--PRINT 'FILTRO FASE: ' + @SQLQueryFase
		--PRINT '----------------------------' 
		SET @SQLFiltroFase = ''
		IF @filtrosDeFase > 1
		BEGIN
			SET @SQLQueryFase = @SQLQueryFase + '
										AND ('
			IF @OfertaAsunto Is NOT NULL 
			BEGIN
				IF @SQLFiltroFase = ''
				BEGIN
					Set @SQLFiltroFase = @SQLFiltroFase + ' 
										(Ofertar = ''NO'' OR Ofertar = '''')' 
				END
			END
				
			IF @OfertaPreparacion Is NOT NULL 
			BEGIN 
				IF @SQLFiltroFase <> ''
				BEGIN
					SET @SQLFiltroFase = @SQLFiltroFase + ' OR ' 
				END
				SET @SQLFiltrofase = @SQLFiltroFase + ' 
											((AÑOPRES IS NULL AND MESPRES IS NULL) AND (Ofertar = ''SI''))' 
			END
			
			IF @OfertaPresentada Is NOT NULL 
			BEGIN
				IF @SQLFiltroFase <> ''
				BEGIN 
					SET @SQLFiltroFase = @SQLFiltroFase + ' OR '
				END
				
				--(AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) AND (ADJUDICADA <> ''S'' AND AÑOAD IS NULL AND MESAD IS NULL)' 
				SET @SQLFiltroFase = @SQLFiltroFase + ' 
											(Adjudicada = '''' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))' 
			END
			
			IF @OfertaDenegada IS NOT NULL 
			BEGIN
		
				IF @SQLFiltroFase <> ''
				BEGIN
					SET @SQLFiltroFase = @SQLFiltroFase + ' OR '
				END
				SET @SQLFiltroFase = @SQLFiltroFase + ' 
											(Adjudicada = ''N'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))' 
			END
			
			IF @OfertaAdjudicada IS NOT NULL 
			BEGIN
		
				IF @SQLFiltroFase <> ''
				BEGIN
					SET @SQLFiltroFase = @SQLFiltroFase + ' OR '
				END
				SET @SQLFiltroFase = @SQLFiltroFase + '
											(Adjudicada = ''S'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))' 
			end
			
			SET @SQLQueryFase= @SQLQueryFase + LTRIM(RTRIM(@SQLFiltroFase)) + ')'
		END	
			
		SET @SQLQuerySelect = @SQLQuerySelect + @SQLQueryFase + ' ORDER BY DesOfer'					
	    --print @SQLFiltroFase
		PRINT LEN(@sqlqueryselect)
		
		declare @ultimaparteSelect as varchar(max)
		set @ultimaparteSelect = substring(@sqlqueryselect, 4001, len(@SQLQuerySelect))
		PRINT @SQLQuerySelect
		PRINT @ultimaparteSelect
								

	 --PRINT @SQLQueryFase
	 SET @ParamDefinition =' @IdPais varchar(3), 
							@Concepto varchar(255),
							@ZonaComercial as int, 
							@ProyectoSingular as bit, 
							@OfertaAsunto as bit,
							@OfertaPreparacion as bit,
							@OfertaPresentada as bit, 
							@OfertaDenegada as bit, 
							@OfertaAdjudicada as bit,
							@FechaDesde as datetime, 
							@operacionFecha as varchar(5), 
							@idResponsableComercial as varchar(3),
							@ImporteDesde AS money,
							@ImporteHasta as money,
							@OperacionImporte as varchar(10),
							@SDGEnergia as bit,
							@SDGRedes as bit,
							@SDGInstalacionesCentro as bit,
							@SDGInstalacionesNorteAmerica as bit,
							@SDGInstalacionesNordeste as bit,
							@SDGInstalacionesSur as bit,
							@SDGInstalacionesEste as bit,
							@SDGIngenieria as bit'							

	
    Execute sp_Executesql    
				@SQLQuerySelect, 
                @ParamDefinition, 
				@IdPais, 
				@Concepto, 
				@ZonaComercial, 
				@ProyectoSingular ,
				@OfertaAsunto,
				@OfertaPreparacion,
				@OfertaPresentada,
				@OfertaDenegada,
				@OfertaAdjudicada,
				@FechaDesde,
				@operacionFecha, 
				@idResponsableComercial,
				@ImporteDesde,
				@ImporteHasta,
				@OperacionImporte,
				@SDGEnergia,
				@SDGRedes,
				@SDGInstalacionesCentro,
				@SDGInstalacionesNorteAmerica,
				@SDGInstalacionesNordeste,
				@SDGInstalacionesSur,
				@SDGInstalacionesEste,
				@SDGIngenieria				
    END
END







