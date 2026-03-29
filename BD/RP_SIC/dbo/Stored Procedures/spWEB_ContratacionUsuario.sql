

--[dbo].[spWEB_ContratacionUsuario] 'anruiz',2019,4

CREATE PROCEDURE [dbo].[spWEB_ContratacionUsuario]
	@Usuario varchar(50), 		
	@pAño int,
	@pMes int
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

	DECLARE @Usuario_Sin_Fecha varchar(50)
	DECLARE @Usuario_Puesto varchar(5)
	DECLARE @Usuario_CodEntidad varchar(3)
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	SELECT @Usuario_Puesto=Puesto, @Usuario_CodEntidad=CodEntidad FROM dbo.WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha	
	IF isnull(@Usuario_Puesto,'')='' RETURN -99999
	
	DELETE FROM WEB_ContratacionUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_ContratacionUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'

	/*
---------------------------------------------------------------- desde AQUÍ
		Paco 2016-02-08

		Creo una copia temporal de los datos de la vista vwWEB_OFERTAS que es la que tarda al acceder a datos del AS400.
		De esta forma las condiciones de filtro que luego aplicabamos en el SQL SERVER sobre las vistas definidas se realizan directamente en el AS400 
		y así se devuelven los datos filtrados
	*/
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

	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_Local (CodCentro, CodOferta, 
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
	
---------------------------------------------------------------- hasta AQUÍ

	/* ****************************** IMPORTES d CENTRO DENTRO d PERIODO *********************************** */
	
	-- OFERTAS
	INSERT INTO WEB_ContratacionUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT  1,@Usuario,CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_MesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoMesAnterior,
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior,
			0 --sum(dbo.fnImporteContratacion_AñoAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoAñoanterior
	FROM #vwWEB_OFERTAS_Local
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes
	GROUP BY CodCentro
	
	-- REGULARIZACIONES
	INSERT INTO WEB_ContratacionUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT  2,@Usuario,CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_MesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoMesAnterior,
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior,
			0 --sum(dbo.fnImporteContratacion_AñoAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoAñoanterior
	FROM         (SELECT dbo.vwWEB_REG.*  
				  FROM     dbo.vwWEB_REG
				  WHERE   (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ
	GROUP BY CodCentro
	
	-- OFERTASsql
	INSERT INTO WEB_ContratacionUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT  3,@Usuario,CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_MesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoMesAnterior,
			sum(dbo.fnImporteContratacion_AcumuladoMesAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoMesAnterior,
			0 --sum(dbo.fnImporteContratacion_AñoAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoAñoanterior
	FROM    dbo.OfertasSQL
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro
	
	-- HISTORICO CONTRATACION para Variacion respecto Año Anterior	
	INSERT INTO WEB_ContratacionUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT  4,@Usuario,CodCentro,0,0,0,0,Sum(Importe)
	FROM dbo.HistoricoContratacionGrupoSQL
	WHERE  Año=@pAño-1 AND Mes <= @pMes
	GROUP BY CodCentro			
	
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
	
	-- Insertamos Centros SIN Contratacion pero que pueden tener Objetivos
	INSERT INTO WEB_ContratacionUsuarioCentro (Usuario,Año,Mes,CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoMesAnterior,ImporteContratadoAcumuladoMesAnterior,ImporteContratadoAcumuladoAñoAnterior)	
	SELECT @Usuario,@pAño,@pMes,[#vCentrosAsignadosUsuario].CodCentro,0,0,0,0,0
	FROM #vCentrosAsignadosUsuario LEFT JOIN 
		( SELECT WEB_ContratacionUsuarioCentro.* 
		  FROM WEB_ContratacionUsuarioCentro
		  WHERE Usuario=@Usuario) w ON w.CodCentro=[#vCentrosAsignadosUsuario].CodCentro
	WHERE  isnull(Usuario,'')=''
	GROUP BY [#vCentrosAsignadosUsuario].CodCentro,Usuario	
	
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

	-- Actualizamos CarteraPdteAñoActual + CarteraPdteAñoAnterior	

	UPDATE WEB_ContratacionUsuarioCentro
	SET ImporteCarteraPdteAñoActual=w.Importe
	FROM (	SELECT CodCentro, Sum(CarteraPdteProducirSQL.Importe) as Importe 
			FROM CarteraPdteProducirSQL 
			WHERE CarteraPdteProducirSQL.Año= @pAño AND CarteraPdteProducirSQL.Mes=@pMes
			GROUP BY CarteraPdteProducirSQL.CodCentro) w
	WHERE dbo.WEB_ContratacionUsuarioCentro.CodCentro = w.CodCentro AND dbo.WEB_ContratacionUsuarioCentro.Usuario = @Usuario 
	
	UPDATE WEB_ContratacionUsuarioCentro
	SET ImporteCarteraPdteAñoAnterior=w.Importe
	FROM (	SELECT CodCentro, Sum(CarteraPdteProducirSQL.Importe) as Importe 
			FROM CarteraPdteProducirSQL 
			WHERE CarteraPdteProducirSQL.Año= @pAño-1 AND CarteraPdteProducirSQL.Mes=@pMes
			GROUP BY CarteraPdteProducirSQL.CodCentro) w
	WHERE dbo.WEB_ContratacionUsuarioCentro.CodCentro = w.CodCentro AND dbo.WEB_ContratacionUsuarioCentro.Usuario = @Usuario 

	-- Carteras Mes Anterior
	IF (@pMes=1)
		SET @pMes=0
	ELSE
		SET @pMes=@pMes-1

	UPDATE WEB_ContratacionUsuarioCentro
	SET ImporteCarteraPdteAñoActualMesAnterior=w.Importe
	FROM (	SELECT CodCentro, Sum(CarteraPdteProducirSQL.Importe) as Importe 
			FROM CarteraPdteProducirSQL 
			WHERE CarteraPdteProducirSQL.Año= @pAño AND CarteraPdteProducirSQL.Mes=@pMes
			GROUP BY CarteraPdteProducirSQL.CodCentro) w
	WHERE dbo.WEB_ContratacionUsuarioCentro.CodCentro = w.CodCentro AND dbo.WEB_ContratacionUsuarioCentro.Usuario = @Usuario 
	
	UPDATE WEB_ContratacionUsuarioCentro
	SET ImporteCarteraPdteAñoAnteriorMesAnterior=w.Importe
	FROM (	SELECT CodCentro, Sum(CarteraPdteProducirSQL.Importe) as Importe 
			FROM CarteraPdteProducirSQL 
			WHERE CarteraPdteProducirSQL.Año= @pAño-1 AND CarteraPdteProducirSQL.Mes=@pMes
			GROUP BY CarteraPdteProducirSQL.CodCentro) w
	WHERE dbo.WEB_ContratacionUsuarioCentro.CodCentro = w.CodCentro AND dbo.WEB_ContratacionUsuarioCentro.Usuario = @Usuario 
	

	/* ******************************* BORRAMOS TEMPORAL ***************************** */	
	DELETE FROM WEB_ContratacionUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	
	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha
	
	/* ********************************* RESULTADO *********************************** */	
	
	CREATE TABLE #WEB_CarteraUsuarioCentro_TMP (CodCentro char(3),CodOferta varchar(10),DesOfer varchar(50),
												ImporteContratado float,ImporteProduccion float,TipoOferta varchar(1))	


-- ELECNOR
	INSERT INTO #WEB_CarteraUsuarioCentro_TMP (CodCentro, CodOferta, DesOfer, ImporteContratado, ImporteProduccion, TipoOferta)
	SELECT Ofer.CDCEN, Ofer.CDOFT, Ofer.DCOF, Ofer.TVEN Contratacion, ROUND(SUM(Ob.SOP),0) Produccion, 'E'
	FROM Enlaces AS E, 
		(SELECT * FROM OfertasE_Filtro) AS Ofer, 
		(SELECT '1' a, CTR, CodObra, SOP FROM Obras_Filtro
			UNION 
		SELECT '2' a,CTR, OBRA+OBRAL CodObra, SOP FROM ObrasHistoricasSQL) AS Ob 
	WHERE E.CDOFT = Ofer.CDOFT AND
		E.CTRO = Ob.CTR AND
		E.OBRA = Ob.CodObra
	GROUP BY Ofer.CDCEN, Ofer.CDOFT, Ofer.DCOF, Ofer.TVEN 

-- UTEs
	INSERT INTO #WEB_CarteraUsuarioCentro_TMP (CodCentro, CodOferta, DesOfer, ImporteContratado, ImporteProduccion, TipoOferta)
	SELECT Ofer.CDCEN, Ofer.CDOFT, Ofer.DCOF, Ofer.TVEN Contratacion, ROUND(SUM(Ob.SOP),0) Produccion, 'U'
	FROM (SELECT * FROM OfertasU_Filtro) AS Ofer, 
		(SELECT CTR, CDOFT, OBRA+OBRAL CodObra, SOP FROM ObrasOtrasSQL) AS Ob 
	WHERE Ofer.CDCEN=Ob.CTR AND Ofer.CDOFT=Ob.CDOFT
	GROUP BY Ofer.CDCEN, Ofer.CDOFT, Ofer.DCOF, Ofer.TVEN 
	
	UPDATE WEB_ContratacionUsuarioCentro
	SET NumOfertasCarteraNegativa = C.NumOfertasCarteraNegativa
	FROM WEB_ContratacionUsuarioCentro W INNER JOIN (
			SELECT q.CodCentro, SUM(CASE WHEN q.Cartera < 0 THEN 1 ELSE 0 END) NumOfertasCarteraNegativa
				FROM (
						SELECT CodCentro, CodOferta, DesOfer, SUM(ImporteContratado) Contratacion, SUM(ImporteProduccion) Produccion,
								SUM(round(ImporteContratado/10,0)-round(ImporteProduccion/10,0)) Cartera
						FROM #WEB_CarteraUsuarioCentro_TMP
						GROUP BY CodCentro, CodOferta, DesOfer
					) q
				GROUP BY q.CodCentro
		) C ON C.CodCentro=W.CodCentro
	WHERE W.Usuario = @Usuario	

	--SELECT WEB_ContratacionUsuarioCentro.*  FROM WEB_ContratacionUsuarioCentro WHERE Usuario = @Usuario	

	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END

