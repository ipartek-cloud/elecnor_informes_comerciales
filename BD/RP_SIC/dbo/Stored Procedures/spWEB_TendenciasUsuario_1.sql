

--[dbo].[spWEB_TendenciasUsuario] 'eluque',2019,6

CREATE PROCEDURE [dbo].[spWEB_TendenciasUsuario]
	@Usuario varchar(50), 		
	@pAño int,
	@pMes int
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

	DECLARE @Usuario_Sin_Fecha varchar(50)
	DECLARE @Usuario_Puesto varchar(5)
	DECLARE @Usuario_CodEntidad int
	DECLARE @Posicion as int

	DECLARE @StartTime AS DATETIME = GETDATE()
	
	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	SELECT @Usuario_Puesto=Puesto, @Usuario_CodEntidad=CodEntidad FROM dbo.WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha	
	IF isnull(@Usuario_Puesto,'')='' RETURN -99999
	
	DELETE FROM WEB_ContratacionUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_ContratacionUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'

	-- Copia en local y filtrada de los datos de la vista vwWEB_OFERTAS (acceso al AS400)
	DECLARE @SQL_AS400_select as varchar(1000)
	DECLARE @SQL_AS400_from as varchar(1000)
	DECLARE @SQL_AS400 as varchar(max)

	-- No se muy bien pero el EXEC no me funciona con SELECT INTO. POr eso lo hago con CREATE TABLE + INSERT INTO
	CREATE TABLE #vwWEB_OFERTAS_Local  (CodCentro varchar(3),CodOferta varchar(10), 
										DescripcionOferta varchar(100), 
										CodCliente varchar(100), 
										Localidad varchar (100),
										CodProv varchar(2),
										CodAct1 varchar(5),
										CodAct2 varchar(5),
										CodResponsable varchar(5), 
										FAdjudicacion datetime,
										ImporteContratado float)

	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_Local (CodCentro, CodOferta, DescripcionOferta, CodCliente, Localidad, CodProv, CodAct1, CodAct2, CodResponsable, FAdjudicacion, ImporteContratado)
							 SELECT CDCEN AS CodCentro, CDOFT AS CodOferta, DCOF AS DescripcionOferta, CDCLI AS CodCliente, LOCAL AS Localidad, PROOF AS CodProv, CDAC1 AS CodAct1, CDAC2 AS CodAct2, RPROF AS CodResponsable,  
									CASE WHEN LEN(FECHAD) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAD, 6), 103) 
										ELSE (CASE WHEN FECHAD = ''0'' THEN ''19990101'' ELSE NULL END) 
									END AS FAdjudicacion, 
									PREAD AS ImporteContratado
							'
	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT CDCEN, CDOFT, FECHAA, DCOF, CDCLI, LOCAL, PROOF, IMAOF, CDAC1, CDAC2, DECOF, RPROF, FECHPP, PREVE, FECHAD, ADELE, PREAD, TCOS, TVEN, USER, WS10, DESPRO, BAJA
							 FROM S44DD901.ICOMERF.IC09AP
							 WHERE ADELE = ''''S'''' AND 
								 (substr( digits(dec(19000000+FECHAD,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+FECHAD,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
								'')'	
	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vwWEB_OFERTAS'
	EXEC (@SQL_AS400)

	--PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
---------------------------------------------------------------- hasta AQUÍ

	/* ****************************** IMPORTES d CENTRO DENTRO d PERIODO *********************************** */
	
	-- CONTRATACION AS400
	INSERT INTO WEB_ContratacionUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteContratadoAcumulado,ImporteContratadoAcumuladoMesAnterior)	
	SELECT  1,@Usuario,CodCentro,			
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior
	FROM #vwWEB_OFERTAS_Local
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes
	GROUP BY CodCentro

	--PRINT 'Time 2.1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	-- REGULARIZACIONES
	INSERT INTO WEB_ContratacionUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteContratadoAcumulado,ImporteContratadoAcumuladoMesAnterior)	
	SELECT  2,@Usuario,CodCentro,			
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,		
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior
	FROM         (SELECT dbo.vwWEB_REG.*  
				  FROM     dbo.vwWEB_REG
				  WHERE   (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ
	GROUP BY CodCentro

	--PRINT 'Time 2.2º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	-- OFERTASsql
	INSERT INTO WEB_ContratacionUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteContratadoAcumulado,ImporteContratadoAcumuladoMesAnterior)	
	SELECT  3,@Usuario,CodCentro,			
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,		
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior
	FROM    dbo.OfertasSQL
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro

	--PRINT 'Time 2.3º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	/* ********************************* CENTROS ASIGNADOS *********************************** */	
	
	CREATE TABLE #vCentrosAsignadosUsuario (CodCentro varchar(3))
	
	IF @Usuario_Puesto='DG'
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)		
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodDirGeneral = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='SDG'
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)				
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodSubDirGeneral = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='DN'	
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)			
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodDDirNegocio = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='AREA'
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)				
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodSubDirNegocioArea = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='DEL'	
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)			
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodDelegacion = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='CT'
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)				
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodCentro = @Usuario_CodEntidad		
	ELSE		
		RETURN	-999999
	
	/* **************************** SUMARIGRAMA CON IMPORTES-OBJETIVOS d CENTROS ASIGNADOS *************************** */
	
	-- Insertamos Centros + Importes	
	INSERT INTO WEB_ContratacionUsuarioCentro (Usuario,Año,Mes,CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT @Usuario,@pAño,@pMes,WEB_ContratacionUsuarioCentro_TMP.CodCentro,
		   (Sum(ImporteContratado)/1000),
		   (Sum(ImporteContratadoAcumulado)/1000),
		   (Sum(ImporteContratadoMesAnterior)/1000),
		   (Sum(ImporteContratadoAcumuladoMesAnterior)/1000),
		   (sum(ImporteContratadoAcumuladoAñoAnterior)/1000)	
	FROM WEB_ContratacionUsuarioCentro_TMP INNER JOIN #vCentrosAsignadosUsuario ON WEB_ContratacionUsuarioCentro_TMP.CodCentro=	[#vCentrosAsignadosUsuario].CodCentro
	WHERE Usuario=@Usuario 
	GROUP BY WEB_ContratacionUsuarioCentro_TMP.CodCentro	

	--PRINT 'Time 3º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	-- Insertamos Centros SIN Contratacion pero que pueden tener Objetivos
	INSERT INTO WEB_ContratacionUsuarioCentro (Usuario,Año,Mes,CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT @Usuario,@pAño,@pMes,[#vCentrosAsignadosUsuario].CodCentro,0,0,0,0,0
	FROM #vCentrosAsignadosUsuario LEFT JOIN 
		( SELECT WEB_ContratacionUsuarioCentro.* 
		  FROM WEB_ContratacionUsuarioCentro
		  WHERE Usuario=@Usuario) w ON w.CodCentro=[#vCentrosAsignadosUsuario].CodCentro
	WHERE  isnull(Usuario,'')=''
	GROUP BY [#vCentrosAsignadosUsuario].CodCentro,Usuario	

	--PRINT 'Time 4º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	-- Actualizamos Sumarigrama de Centros Asigandos a Usuario
	UPDATE WEB_ContratacionUsuarioCentro 
	SET CodDirGeneral=dbo.Sumarigrama.CodDirGeneral,
		NombreDirGeneral=dbo.Sumarigrama.NombreDirGeneral,
		CodSubDirGeneral=dbo.Sumarigrama.CodSubDirGeneral, 
        NombreSubDirGeneral= dbo.Sumarigrama.NombreSubDirGeneral,
        CodDDirNegocio=dbo.Sumarigrama.CodDDirNegocio,
        NombreDirNegocio=dbo.Sumarigrama.NombreDirNegocio, 
        CodSubDirNegocioArea=dbo.Sumarigrama.CodSubDirNegocioArea,
        NombreSubDirNegocioArea=dbo.Sumarigrama.NombreSubDirNegocioArea,
        CodDelegacion=dbo.Sumarigrama.CodDelegacion, 
        NombreDelegacion=dbo.Sumarigrama.NombreDelegacion,
        NombreCentro=dbo.Sumarigrama.NombreCentro
	FROM dbo.Sumarigrama		
	WHERE  dbo.WEB_ContratacionUsuarioCentro.CodCentro = dbo.Sumarigrama.CodCentro AND dbo.WEB_ContratacionUsuarioCentro.Usuario = @Usuario		
	
	--PRINT 'Time 5º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

	/* ******************************* BORRAMOS TEMPORAL ***************************** */	
	DELETE FROM WEB_ContratacionUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'	
	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */		
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha

	--PRINT 'Time 6º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	--SELECT WEB_ContratacionUsuarioCentro.*  FROM WEB_ContratacionUsuarioCentro  WHERE Usuario = @Usuario	

	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END