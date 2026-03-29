
/*
 exec [dbo].[spWEB_ContratacionActividadUsuario] 'eluque',2018,6
 exec [dbo].[spWEB_ContratacionActividadUsuario] 'AVALDIZAN',2018,5
 exec [dbo].[spWEB_ContratacionActividadUsuario] 'AHENAREJOS',2018,5 
 */

CREATE PROCEDURE [dbo].[spWEB_ContratacionActividadUsuario]
	@Usuario varchar(50), 		
	@pAño int,
	@pMes int
	AS
BEGIN

	SET NOCOUNT ON;
	
	--BEGIN TRY

	DECLARE @Usuario_Sin_Fecha varchar(50)
	DECLARE @Usuario_Puesto varchar(5)
	DECLARE @Usuario_CodEntidad varchar(3)
	DECLARE @Posicion as int
	DECLARE @CodCentros VARCHAR(8000) 
	
	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	SELECT @Usuario_Puesto=Puesto, @Usuario_CodEntidad=CodEntidad FROM dbo.WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha	
	IF isnull(@Usuario_Puesto,'')='' RETURN -99999
	
	DELETE FROM WEB_ContratacionActividadesUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_ContratacionActividadUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_ContratacionActividadUsuario WHERE Usuario like @Usuario_Sin_Fecha + '%'

	-- Copia en local y filtrada de los datos de la vista vwWEB_OFERTAS (acceso al AS400)
	DECLARE @SQL_AS400_select as varchar(1000)
	DECLARE @SQL_AS400_from as varchar(1000)
	DECLARE @SQL_AS400 as varchar(max)

	CREATE TABLE #vwWEB_OFERTAS_Local  (CodCentro varchar(3),
										CodOferta varchar(10), 
										DescripcionOferta varchar(100), 
										CodCliente varchar(100), 
										Localidad varchar (100),
										CodProv varchar(2),
										CodAct1 varchar(5),
										CodAct2 varchar(5),
										CodResponsable varchar(5), 
										FAdjudicacion datetime,
										ImporteContratado float)

	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_Local ( CodCentro, CodOferta, 
																DescripcionOferta, CodCliente, Localidad, CodProv, CodAct1, CodAct2, CodResponsable, 
																FAdjudicacion, ImporteContratado)
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

	/* ****************************** IMPORTES d CENTRO DENTRO d PERIODO *********************************** */
	
	-- OFERTAS
	INSERT INTO WEB_ContratacionActividadesUsuarioCentro_TMP(Tipo,Usuario,CodCentro,CDAC1,CDAC2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT  1,@Usuario,CodCentro,CodAct1,CodAct2,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_MesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoMesAnterior,
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior,
			0 
	FROM #vwWEB_OFERTAS_Local
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes
	GROUP BY CodCentro,CodAct1,CodAct2	
	
	-- REGULARIZACIONES
	INSERT INTO WEB_ContratacionActividadesUsuarioCentro_TMP(Tipo,Usuario,CodCentro,CDAC1,CDAC2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT  2,@Usuario,CodCentro,CodAct1,CodAct2,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_MesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoMesAnterior,
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior,
			0 
	FROM         (SELECT dbo.vwWEB_REG.*  
				  FROM     dbo.vwWEB_REG
				  WHERE   (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizaciones
	GROUP BY CodCentro,CodAct1,CodAct2	
	
	-- OFERTASsql
	INSERT INTO WEB_ContratacionActividadesUsuarioCentro_TMP(Tipo,Usuario,CodCentro,CDAC1,CDAC2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT  3,@Usuario,CodCentro,CodAct1,CodAct2,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_MesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoMesAnterior,
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior,
			0 
	FROM    dbo.OfertasSQL
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro,CodAct1,CodAct2
	
	-- HISTORICO CONTRATACION para Variacion respecto Año Anterior	
	INSERT INTO WEB_ContratacionActividadesUsuarioCentro_TMP(Tipo,Usuario,CodCentro,CDAC1,CDAC2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT  4,@Usuario,CodCentro,CodAct1,CodAct2,0,0,0,0,Sum(Importe)
	FROM dbo.HistoricoContratacionGrupoSQL
	WHERE  Año=@pAño-1 AND Mes <= @pMes
	GROUP BY CodCentro,CodAct1,CodAct2			
	
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
	
	SELECT @CodCentros = COALESCE(@CodCentros + ', ', '') + cast(CodCentro as varchar(5)) FROM [#vCentrosAsignadosUsuario]

	/* **************************** SUMARIGRAMA CON IMPORTES d CENTROS ASIGNADOS *************************** */
	
	-- Insertamos Centros Asignados + Importes: 	
	INSERT INTO WEB_ContratacionActividadUsuarioCentro (Usuario,Año,Mes,CodCentro,CDAC1,CDAC2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT @Usuario,@pAño,@pMes,WEB_ContratacionActividadesUsuarioCentro_TMP.CodCentro,CDAC1,CDAC2,
		   (Sum(ImporteContratado)/1000),
		   (Sum(ImporteContratadoAcumulado)/1000),
		   (Sum(ImporteContratadoMesAnterior)/1000),
		   (Sum(ImporteContratadoAcumuladoMesAnterior)/1000),
		   (sum(ImporteContratadoAcumuladoAñoAnterior)/1000)	
	FROM WEB_ContratacionActividadesUsuarioCentro_TMP INNER JOIN #vCentrosAsignadosUsuario ON WEB_ContratacionActividadesUsuarioCentro_TMP.CodCentro=[#vCentrosAsignadosUsuario].CodCentro
	WHERE Usuario=@Usuario 
	GROUP BY WEB_ContratacionActividadesUsuarioCentro_TMP.CodCentro,CDAC1,CDAC2		

	-- Actualizamos Sumarigrama de Centros Asigandos a Usuario
	UPDATE WEB_ContratacionActividadUsuarioCentro 
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
	WHERE  dbo.WEB_ContratacionActividadUsuarioCentro.CodCentro = dbo.Sumarigrama.CodCentro AND dbo.WEB_ContratacionActividadUsuarioCentro.Usuario = @Usuario	

	/* ******************************* BORRAMOS TEMPORAL ***************************** */	
	DELETE FROM WEB_ContratacionActividadesUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	
	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha	

	/* Contratacion */
	INSERT INTO WEB_ContratacionActividadUsuario([Usuario],[Año],[Mes],[CDAC1],[CDAC2],[DSACT],[Agrupacion],[ImporteContratado],[ImporteContratadoAcumulado],[ImporteContratadoMesAnterior],[ImporteContratadoAcumuladoMesAnterior],[ImporteContratadoAcumuladoAñoAnterior])
	SELECT [Usuario],[Año],[Mes],[CDAC1],[CDAC2],[dbo].[fnActividadDescripcion]([CDAC1],[CDAC2]),[dbo].[fnActividadAgrupacion]([CDAC1],[CDAC2]),SUM([ImporteContratado]), SUM([ImporteContratadoAcumulado]), SUM([ImporteContratadoMesAnterior]), SUM([ImporteContratadoAcumuladoMesAnterior]), SUM([ImporteContratadoAcumuladoAñoAnterior])
	FROM WEB_ContratacionActividadUsuarioCentro
	WHERE Usuario = @Usuario
	GROUP BY [Usuario],[Año],[Mes],[CDAC1],[CDAC2]	

	/* Objetivos & ImporteContratadoAcumuladoAgrupacion */
	UPDATE WEB_ContratacionActividadUsuario
	SET Objetivos = dbo.fnObjetivos_Actividad_Agrupacion_Centros_Usuario([Año],[Agrupacion],@CodCentros),
		ObjetivosMensual = round(dbo.fnObjetivos_Actividad_Agrupacion_Centros_Usuario([Año],[Agrupacion],@CodCentros)/12,0),
		ImporteContratadoMesAnteriorAgrupacion = dbo.fnImporteContratadoMesAnteriorAgrupacion([Usuario],[Agrupacion]),
		ImporteContratadoAgrupacion = dbo.fnImporteContratadoAgrupacion([Usuario],[Agrupacion]),
		ImporteContratadoAcumuladoMesAnteriorAgrupacion = dbo.fnImporteContratadoAcumuladoMesAnteriorAgrupacion([Usuario],[Agrupacion]),
		ImporteContratadoAcumuladoAgrupacion = dbo.fnImporteContratadoAcumuladoAgrupacion([Usuario],[Agrupacion])
	WHERE Usuario = @Usuario 	
	
	/* Objetivos SIN Contratacion */
	INSERT INTO [dbo].[WEB_ContratacionActividadUsuario]([Usuario],[Año],[Mes],[CDAC1],[CDAC2],[DSACT],[Agrupacion],[Objetivos], [ObjetivosMensual])
	SELECT @Usuario, @pAño, @pMes, '','','',vw.Agrupacion, vw.Importe, round( vw.Importe/12,0)
	FROM   dbo.fnObjetivos_Actividad_Centros_Usuario_AGRUP(@pAño,@CodCentros) AS vw LEFT OUTER JOIN (SELECT Agrupacion FROM dbo.WEB_ContratacionActividadUsuario WHERE (Usuario = @Usuario) GROUP BY Agrupacion) AS vw2 ON vw.Agrupacion = vw2.Agrupacion
	WHERE  (ISNULL(vw2.Agrupacion,'')='')

	DELETE FROM WEB_ContratacionActividadUsuario WHERE Usuario=@Usuario AND (Objetivos=0 AND ImporteContratadoAcumulado=0) -- OR isnull(DSACT,'')=''
		
	SELECT * FROM [dbo].[WEB_ContratacionActividadUsuario]  WHERE Usuario = @Usuario 
	--SELECT Agrupacion, objetivos,ImporteContratadoAcumuladoAgrupacion,ip FROM [dbo].[WEB_ContratacionActividadUsuario]  WHERE Usuario = @Usuario group by	 Agrupacion, objetivos,ImporteContratadoAcumuladoAgrupacion,ip
	--SELECT @CodCentros

	return 0 -- NO ERROR
	
	--END TRY
	--BEGIN CATCH
	--	return ERROR_NUMBER ()
	--END CATCH
	
END