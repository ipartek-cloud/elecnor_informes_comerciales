
CREATE PROCEDURE [dbo].[spSincronizar_ProdFactu_Analitca_SAGE]
	@pMes int = null
AS

SET NOCOUNT ON;

DECLARE @ConnectionString as varchar(100) = 'Server=BDLOGIC;UID=usuarioPRP;PWD=*PRP*;'
DECLARE @Sql as varchar(max)

DECLARE @IdSociedad as varchar(7)
DECLARE @CodPais as varchar(3) 


DECLARE C CURSOR FOR 
	SELECT IdSociedad
	FROM zz_Sociedades 
	WHERE Origen='SAGE200'
	--AND IdSociedad='7570001'
OPEN C
FETCH NEXT FROM C into @IdSociedad

CREATE TABLE #t (IdEmpresa varchar(7), Año int, Mes int, Centro varchar(100), IdCentro varchar(2), IdObra varchar(4), Obra varchar(100), IdOferta varchar(10), Porcentaje float, ProduccionOrigen float, FacturacionOrigen float)

WHILE @@FETCH_STATUS = 0

BEGIN 

	----------------------------------------------------------------------------------------------
	-- Creacion de tabla temporal con las producciones/facturaciones que están en la última Analítica creada MAX(IPKCA_9340043 ...)
	SET @Sql = 'DECLARE @BDAnaliticaActual as varchar(18); 
				DECLARE @Sql as nvarchar(max)

				SELECT @BDAnaliticaActual=BDAnalitica FROM OPENROWSET(''SQLNCLI'', ''' + @ConnectionString + ''', ''SELECT MAX(name) as BDAnalitica FROM sys.databases WHERE name like ''''IPKCA_' + @IdSociedad + '%''''; '')

				DECLARE @pIdEmpresa varchar(7)
				DECLARE @pBDGeneral varchar(100)
				DECLARE @pEjercicio int
				DECLARE @ValidarIdOferta as int

				DECLARE @pMes int = ' + CASE WHEN @pMes IS NULL THEN 'NULL' ELSE CAST(@pMes as varchar(2)) END + '
				DECLARE @FechaInicioAplicacion as datetime
				DECLARE @UltimoMesCerrado int

				DECLARE @pIdAsesor varchar(3)
				
				SET NOCOUNT ON
					
				SET @Sql = N''SELECT @pIdEmpresa = IdEmpresa, 
									@pEjercicio = Ejercicio, 
									@pBDGeneral = BDGeneral, 
									@ValidarIdOferta = ISNULL(ValidarIdOferta, 0), 
									@FechaInicioAplicacion = ISNULL(FechaInicioAplic, ''''19800101'''')
								FROM BDLOGIC.'' + quotename(@BDAnaliticaActual) + ''.dbo.ParametrosAplicacion''
				EXEC sp_executesql @Sql, N''@pIdEmpresa varchar(7) out, @pEjercicio int out, @ValidarIdOferta int out, @pBDGeneral varchar(100) out, @FechaInicioAplicacion datetime out'', @pIdEmpresa out, @pEjercicio out, @ValidarIdOferta out, @pBDGeneral out, @FechaInicioAplicacion out

				SET @pIdAsesor = LEFT(@pIdEmpresa, 3)

				SET @Sql = N''SELECT @UltimoMesCerrado=MAX(MesCerrado) 
								FROM BDLOGIC.'' + quotename(@BDAnaliticaActual) + ''.dbo.AsientosAnaliticos WHERE Tipo=''''A''''''
				EXEC sp_executesql @Sql, N''@UltimoMesCerrado int out'', @UltimoMesCerrado out
				
				-- Si no se pasa mes como parámetro, se filtra para el último mes cerrado
				-- Si no se ha cerrado enero, se filtra enero
				IF @pMes IS NULL 
				BEGIN
					-- Calculo el mes en curso
					IF YEAR(@FechaInicioAplicacion) = @pEjercicio AND @UltimoMesCerrado IS NULL
						SET @pMes = MONTH(@FechaInicioAplicacion)
					ELSE
						SET @pMes = ISNULL(@UltimoMesCerrado, 0) + 1
					-- Le resto 1 para saber el último mes cerrado
					SET @pMes = @pMes - 1
				END
				-- Si no, @pMes es el mes consultado
							
				IF @pMes = 0 
					SET @pMes=1
			
				IF @ValidarIdOferta = 1
				BEGIN
					SET @Sql = ''EXEC  BDLOGIC.'' + @BDAnaliticaActual + ''.dbo.spOfertasAS400''
					EXEC (@Sql)
				END

				SET @Sql = ''EXEC  BDLOGIC.'' + @BDAnaliticaActual + ''.dbo.spRPTCalculoFichaObra ''''O'''', @pBDGeneral, @pIdEmpresa, @pEjercicio, @pMes, ''''00'''', ''''0000'''', ''''99'''', ''''9999'''', null, @pIdAsesor, ''''''''''
				EXEC sp_executesql @Sql, N''@pIdEmpresa varchar(7), @pEjercicio int, @pBDGeneral varchar(100), @pMes int, @pIdAsesor varchar(3)'', @pIdEmpresa, @pEjercicio, @pBDGeneral, @pMes, @pIdAsesor

				--SET @Sql = ''EXEC  BDLOGIC.'' + @BDAnaliticaActual + ''.dbo.spRPTCarteraPendiente''
				--INSERT INTO #t
				--EXEC (@Sql) AT BDLOGIC





				SET @Sql = ''
				SELECT '' + @pIdEmpresa + '' IdEmpresa, '' + cast(@pEjercicio as varchar(4)) + '' AS Año, '' + cast(@pMes as varchar(4)) + '' AS Mes, C.Centro,
					O.IdCentro, O.IdObra, O.Obra, --O.PresIngreso,
					'' + CASE WHEN @ValidarIdOferta=1 THEN ''OO.IdOferta'' ELSE ''O.IdOferta'' END + ''
					, OO.Porcentaje
					, OFi.ProdOrigen ProduccionOrigen, OFi.FOTOrigen + OFi.FATOrigen FacturacionOrigen
				FROM BDLOGIC.'' + @BDAnaliticaActual + ''.dbo.Obras O 
					LEFT JOIN
						(
							SELECT ObraFicha.*
							FROM BDLOGIC.'' + @BDAnaliticaActual + ''.dbo.ObraFicha
							WHERE ObraFicha.Año = '' + cast(@pEjercicio as varchar(4)) + '' AND ObraFicha.Mes = '' + cast(@pMes as varchar(4)) + ''  
						) OFi ON O.IdCentro = OFi.IdCentro AND O.IdObra = OFi.IdObra
					INNER JOIN BDLOGIC.'' + @BDAnaliticaActual + ''.dbo.Centros C on O.IdCentro = C.IdCentro
					
					LEFT JOIN BDLOGIC.'' + @BDAnaliticaActual + ''.dbo.ObraOferta OO ON OFi.IdCentro=OO.IdCentro AND OFi.IdObra=OO.IdObra
				
				WHERE ((O.AñoApertura = '' + cast(@pEjercicio as varchar(4)) + '' ) AND (O.MesApertura <= '' + cast(@pMes as varchar(4)) + ''  ) OR
									  (O.AñoApertura <  '' + cast(@pEjercicio as varchar(4)) + '' ))''
					  
				SET NOCOUNT OFF

				INSERT INTO #t
				EXEC (@Sql)					  
				'
			

	
	PRINT (@Sql)
	EXEC (@Sql)
	
	FETCH NEXT FROM C into @IdSociedad

END


CLOSE C
DEALLOCATE C

	
SELECT * FROM #t