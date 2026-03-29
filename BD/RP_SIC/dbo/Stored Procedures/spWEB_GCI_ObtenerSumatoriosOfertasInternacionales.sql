
-- =============================================
-- Author:		Carlos García García
-- Create date: 2014-06-05
-- Description:	Obtiene el sumatorio de los importes y el sumatorio de filas de las ofertas de AS400 que hay que mostrar en la web de Gestión Comercial Internacional
-- =============================================
CREATE PROCEDURE [dbo].[spWEB_GCI_ObtenerSumatoriosOfertasInternacionales]
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
	@idResponsableComercial as varchar(3) = NULL
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
		   
		SET @SQLQuery = ''
		SET @SQLQueryFase = ''
		SET @SQLQuerySelect = ''
		SET @SQLQueryArchivadas = ''
		SET @SQLFiltroFase = ''
		SET @SQLFiltroArchivada = ''
	END	
	--END DE LA REGION DECLARACIÓN E INICIALIZACIÓN DE VARIABLES
--WHEN (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) AND (ADJUDICADA <> ''S'' AND AÑOAD IS NULL AND MESAD IS NULL)	THEN ''Presentada''
    --REGION: DEFINE EL SELECT QUE SE USARÁ TANTO PARA SACAR LOS OFERTAS VIVAS COMO LAS OFERTAS ARCHIVADAS
	BEGIN
		SET @SQLQuerySelect = 	'SELECT	SUM (IMPPRES) AS SUMATORIOIMPORTE,
										COUNT(IMPPRES) AS CANTIDADOFERTAS
								FROM	[RP_SIC].[dbo].[@@@Ofertas2005] as Ofertas 		
										LEFT JOIN  [RP_SIC].[dbo].[Sumarigrama] ON Ofertas.CT = [RP_SIC].[dbo].[Sumarigrama].CodCentro 
										LEFT JOIN [RP_SIC].[dbo].[GCIPaises] P ON Ofertas.CodProvincia = P.IdPais
										LEFT JOIN [RP_SIC].[DBO].[GCIZonas] Z ON P.IdZona = Z.IdZona
										LEFT JOIN [RP_SIC].[DBO].[GCIZonasComerciales] ZC ON Z.IdZonacomercial = ZC.IdZonaComercial
										LEFT JOIN ResponsablesComercialesPorPais RCP on RCP.CodPais = Ofertas.CodProvincia
								WHERE	Mercado = ''Internacional''
										AND ImpPres >= 10000000
										AND BAJA <> ''B'''		

		--SET @SQLQueryFase = @SQLQuerySelect 
								
		IF @idPais Is Not NULL 
		BEGIN 
			Set @SQLQuerySelect = @SQLQuerySelect + ' 
										AND (Ofertas.CodProvincia =  ''' + @IdPais + ''')' 
		END
										
		IF @ProyectoSingular Is Not NULL 
		BEGIN 
			Set @SQLQuerySelect = @SQLQuerySelect + ' 
										AND (Ofertas.ImpPres >=  50000000)' 
		END
		
		IF @ZonaComercial Is Not NULL 
		BEGIN 
			Set @SQLQuerySelect = @SQLQuerySelect + '
										AND (ZC.idZonaComercial =  @ZonaComercial )' 
		END
		
		IF @FechaDesde Is NOT NULL
		BEGIN
			SET @SQLQuerySelect = @SQLQuerySelect + 
										' AND (Ofertas.AñoPres ' + @operacionFecha + ' ' + CAST (YEAR(@FechaDesde) AS VARCHAR(4))+' AND Ofertas.MesPres ' + @operacionFecha + ' ' + CAST (MONTH(@FechaDesde) AS VARCHAR(2))+')'
		END
		
		IF @idResponsableComercial Is NOT NULL
		BEGIN
			SET @SQLQuerySelect = @SQLQuerySelect + 
										' AND (CodResponsableComercial = @idResponsableComercial)'
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
			IF @OfertaAsunto Is Not NULL Set @SQLQueryFase = @SQLQueryFase + ' AND (Ofertar = ''NO'')' 
			IF @OfertaPreparacion is NOT NULL Set @SQLQueryFase = @SQLQueryFase + ' AND (AÑOPRES IS NULL AND MESPRES IS NULL)' 
			IF @OfertaPresentada is NOT NULL Set @SQLQueryFase = @SQLQueryFase + '  AND (Adjudicada = '''') AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))' 			
			IF @OfertaDenegada is NOT NULL Set @SQLQueryFase = @SQLQueryFase + '    AND (Adjudicada = ''N'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))' 
			IF @OfertaAdjudicada  is NOT NULL Set @SQLQueryFase = @SQLQueryFase + ' AND (Adjudicada = ''S'' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL))' 

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
										(Ofertar = ''NO'')' 
				END
			END
				
			IF @OfertaPreparacion Is NOT NULL 
			BEGIN 
				IF @SQLFiltroFase <> ''
				BEGIN
					SET @SQLFiltroFase = @SQLFiltroFase + ' OR ' 
				END
				SET @SQLFiltrofase = @SQLFiltroFase + ' 
											(AÑOPRES IS NULL AND MESPRES IS NULL)' 
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
			
		SET @SQLQuerySelect = @SQLQuerySelect + @SQLQueryFase 
	    --print @SQLFiltroFase
			
		PRINT @SQLQuerySelect	
								

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
							@idResponsableComercial as varchar(3)'

	
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
				@idResponsableComercial
				
    END
END







