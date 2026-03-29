
--[dbo].[spWEB_CarteraUsuario] 'svadillo',2015,2

CREATE PROCEDURE [dbo].[spWEB_CarteraUsuario_TEMP]
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
	
	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	SELECT @Usuario_Puesto=Puesto, @Usuario_CodEntidad=CodEntidad FROM dbo.WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha	
	IF isnull(@Usuario_Puesto,'')='' RETURN -99999
	
	DELETE FROM WEB_CarteraUsuarioCentro_TMP WHERE Usuario like '%' +@Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_CarteraUsuarioCentro WHERE Usuario like '%' +@Usuario_Sin_Fecha + '%'
	
	/* ****************************** IMPORTES CONTRATACION d CENTRO DENTRO d PERIODO *********************************** */
		
	/* 
	   Cartera= Contratacion-Produccion

	   Contratacion = Ofertas de Alta(<>B & NO Adjudicada & No Obra).ImporteTotal (Anterior a la Fecha Seleccionada) - Regularizaciones Posteriores a Fecha Seleccionada --> Importe segun Tipo Oferta (Elecnor-Filial-Ute-Sucursal)
	                  Mas
					  OfertasSQL -->Importe Tipo 'Filial' 
	*/

	/* ***************************************************************************************************************** */
	/* ******************************************** CONTRATACION  ****************************************************** */
	/* ***************************************************************************************************************** */

	-- OFERTAS
		CREATE TABLE #vwWEB_OFERTAS_CA (CodCentro varchar(3),CodOferta varchar(10),Adjudicada char(1), ImporteTotal float, Tipo char(10))
		-- Insertamos Ofertas que No son Baja
		INSERT INTO #vwWEB_OFERTAS_CA(CodCentro,CodOferta, ImporteTotal,Adjudicada,Tipo) SELECT CodCentro,CodOferta,ImporteTotal,Adjudicada,Tipo FROM vwWEB_OFERTAS_CA WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes))
		-- Borramos Ofertas Sin Adjudicar y Sin Obra: NO Adjudica (Adele<>'S'), NO Obra (No Enlace.CodOferta)	
		DELETE #vwWEB_OFERTAS_CA FROM #vwWEB_OFERTAS_CA INNER JOIN vwWEB_OFERTAS_CA_SinAdjudicacion_SinObras ON [#vwWEB_OFERTAS_CA].CodOferta=vwWEB_OFERTAS_CA_SinAdjudicacion_SinObras.CodOferta
		
		--select * from @vwWEB_OFERTAS_CA where CodCentro=527

	-- REGULARIZACIONES Posteriores
	CREATE TABLE #vRegularizaciones (CodCentro varchar(3),CodOferta varchar(10), ImporteRegularizacion float)

	INSERT into #vRegularizaciones(CodCentro,CodOferta,ImporteRegularizacion) 
	SELECT cdcen,cdoft,sum(Impre)
			FROM Regularizaciones
			WHERE (year(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR))=@pAño AND
				  Month(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR))>@pMes) 
				  OR
				  (year(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR))>@pAño)
	GROUP BY cdcen,cdoft
	order by cdoft

	-- OFERTAS - REGULARIZACIONES Posteriores
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)	
	SELECT  1,@Usuario,[#vwWEB_OFERTAS_CA].CodCentro,	
			sum(dbo.fnImporteCartera('E',Tipo,ImporteTotal,[#vRegularizaciones].ImporteRegularizacion)) as ImporteElecnor,
			sum(dbo.fnImporteCartera('F',Tipo,ImporteTotal,[#vRegularizaciones].ImporteRegularizacion)) as ImporteFilial,
			sum(dbo.fnImporteCartera('U',Tipo,ImporteTotal,[#vRegularizaciones].ImporteRegularizacion)) as ImporteUte,
			sum(dbo.fnImporteCartera('S',Tipo,ImporteTotal,[#vRegularizaciones].ImporteRegularizacion)) as ImporteSucursal			
	FROM #vwWEB_OFERTAS_CA LEFT JOIN #vRegularizaciones ON
									 [#vwWEB_OFERTAS_CA].CodCentro=[#vRegularizaciones].CodCentro AND
									 [#vwWEB_OFERTAS_CA].CodOferta=[#vRegularizaciones].CodOferta
	GROUP BY [#vwWEB_OFERTAS_CA].CodCentro
		
	-- OFERTASsql que no estan marcas como Baja en OfertasBajasSQL
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)	
	SELECT  2,@Usuario,dbo.OfertasSQL.CodCentro,0,sum(ImporteContratado) as ImporteFilial,0,0
	FROM  dbo.OfertasSQL LEFT JOIN dbo.OfertasBajasSQL ON dbo.OfertasSQL.CodCentro=dbo.OfertasBajasSQL.CodCentro AND dbo.OfertasSQL.CodOferta=dbo.OfertasBajasSQL.CodOferta
	WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND isnull(dbo.OfertasBajasSQL.CodOferta,'')='' 
	GROUP BY dbo.OfertasSQL.CodCentro
	
	/* ***************************************************************************************************************** */
	/* ******************************************** PRODUCCION  ******************************************************** */
	/* ***************************************************************************************************************** */

	/* ***************************************************************************************************************** */
	/*								Obras VIVAS - Obras Historicas - Obras Otras					     					 */
	/* ***************************************************************************************************************** */	

	/* ***************************************************************************************************************** */
	/* ******************************************** OBRAS VIVAS ******************************************************** */
	/* ***************************************************************************************************************** */

	-- Produccion de Elecnor (Ofertas.Tipo='E' <-JOIN-> Enlaces <-JOIN-> OfertasActualesSQL.SOP)

/* -------------- INICIO cambio        Paco 2015-07-14 */
/* 
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT  10,@Usuario,WEB_CarteraUsuarioCentro_TMP.CodCentro,(sum(TotalSOP)*-1) as ImporteElecnor,0,0,0
	FROM WEB_CarteraUsuarioCentro_TMP INNER JOIN (
		SELECT vwEnlaces_Obras_SOP.CodCentro, SUM(vwEnlaces_Obras_SOP.TotalSOP) AS TotalSOP
		FROM   @vwWEB_OFERTAS_CA INNER JOIN
			   vwEnlaces_Obras_SOP ON [@vwWEB_OFERTAS_CA].CodOferta = vwEnlaces_Obras_SOP.CDOFT AND 
			   [@vwWEB_OFERTAS_CA].CodCentro = vwEnlaces_Obras_SOP.CodCentro
		WHERE  ([@vwWEB_OFERTAS_CA].Tipo = 'E') AND Año=@pAño AND Mes=@pMes
		GROUP BY vwEnlaces_Obras_SOP.CodCentro) vw on 
			WEB_CarteraUsuarioCentro_TMP.CodCentro=vw.CodCentro
	WHERE WEB_CarteraUsuarioCentro_TMP.Usuario=@Usuario
	GROUP BY WEB_CarteraUsuarioCentro_TMP.CodCentro
*/
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT  10,@Usuario,vw1.CodCentro,(sum(TotalSOP)*-1) as ImporteElecnor,0,0,0
	FROM (SELECT DISTINCT Usuario, CodCentro FROM WEB_CarteraUsuarioCentro_TMP) vw1 INNER JOIN (
		SELECT vwEnlaces_Obras_SOP.CodCentro, SUM(vwEnlaces_Obras_SOP.TotalSOP) AS TotalSOP
		FROM   #vwWEB_OFERTAS_CA INNER JOIN
			   vwEnlaces_Obras_SOP ON [#vwWEB_OFERTAS_CA].CodOferta = vwEnlaces_Obras_SOP.CDOFT AND 
			   [#vwWEB_OFERTAS_CA].CodCentro = vwEnlaces_Obras_SOP.CodCentro
		WHERE  ([#vwWEB_OFERTAS_CA].Tipo = 'E') AND Año=@pAño AND Mes=@pMes
		GROUP BY vwEnlaces_Obras_SOP.CodCentro) vw on 
			vw1.CodCentro=vw.CodCentro
	WHERE vw1.Usuario=@Usuario
	GROUP BY vw1.CodCentro
/* -------------- FIN cambio        Paco 2015-07-14 */

	-- Ofertas TIPO1 (Solo Enlaces & CodOferta=1 <-JOIN-> OfertasActualesSQL (Año,Mes)) = Produccion Elecnor

/* -------------- INICIO cambio        Paco 2015-07-14 */
/*
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT  11,@Usuario,WEB_CarteraUsuarioCentro_TMP.CodCentro,(sum(TotalSOP)*-1) as ImporteElecnor,0,0,0	
	FROM WEB_CarteraUsuarioCentro_TMP INNER JOIN vwTIPOUNO_ProduccionElecnor on 
	WEB_CarteraUsuarioCentro_TMP.CodCentro=vwTIPOUNO_ProduccionElecnor.CodCentro
	WHERE Año=@pAño AND Mes=@pMes AND TotalSOP<>0 and Usuario=@Usuario AND Tipo<>10 -- Se acaban de insertar el mas veces el mismo Centro con importe negativo
	GROUP BY WEB_CarteraUsuarioCentro_TMP.CodCentro
*/
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT  11,@Usuario,vw1.CodCentro,(sum(TotalSOP)*-1) as ImporteElecnor,0,0,0	
	FROM (SELECT DISTINCT Usuario, CodCentro FROM WEB_CarteraUsuarioCentro_TMP WHERE Tipo<>10) vw1 INNER JOIN vwTIPOUNO_ProduccionElecnor on 
	vw1.CodCentro=vwTIPOUNO_ProduccionElecnor.CodCentro
	WHERE Año=@pAño AND Mes=@pMes AND TotalSOP<>0 and Usuario=@Usuario -- Se acaban de insertar el mas veces el mismo Centro con importe negativo
	GROUP BY vw1.CodCentro

/* -------------- FIN cambio        Paco 2015-07-14 */
	/* ****************************************************************************************************************** */
	/* ******************************************** OBRAS HISTORICO ***************************************************** */
	/* ****************************************************************************************************************** */
		
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT 20,@Usuario,ObrasHistoricasSQL.CTR, SUM(ObrasHistoricasSQL.SOP)*-1,0,0,0
	FROM   #vwWEB_OFERTAS_CA INNER JOIN
		   ObrasHistoricasSQL ON [#vwWEB_OFERTAS_CA].CodOferta = ObrasHistoricasSQL.CDOFT AND 
		   [#vwWEB_OFERTAS_CA].CodCentro = ObrasHistoricasSQL.CTR
	WHERE  [#vwWEB_OFERTAS_CA].Tipo = 'E' AND ObrasHistoricasSQL.CTR in (SELECT CodCentro FROM WEB_CarteraUsuarioCentro_TMP WHERE WEB_CarteraUsuarioCentro_TMP.Usuario=@Usuario GROUP BY CodCentro)
	GROUP BY ObrasHistoricasSQL.CTR

	/* ****************************************************************************************************************** */
	/* ******************************************** OBRAS OTRAS ********************************************************* */
	/* ****************************************************************************************************************** */
		
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT 30, @Usuario, ObrasOtrasSQL.CTR, 
			dbo.fnImporteCartera('E',TipoOferta,ObrasOtrasSQL.SOP,0)*-1,
			dbo.fnImporteCartera('F',TipoOferta,ObrasOtrasSQL.SOP,0)*-1,
			dbo.fnImporteCartera('U',TipoOferta,ObrasOtrasSQL.SOP,0)*-1,
			dbo.fnImporteCartera('S',TipoOferta,ObrasOtrasSQL.SOP,0)*-1	
	FROM   #vwWEB_OFERTAS_CA INNER JOIN
		   ObrasOtrasSQL ON [#vwWEB_OFERTAS_CA].CodOferta = ObrasOtrasSQL.CDOFT AND 
		   [#vwWEB_OFERTAS_CA].CodCentro = ObrasOtrasSQL.CTR AND [#vwWEB_OFERTAS_CA].Tipo = ObrasOtrasSQL.TipoOferta 
	WHERE  ObrasOtrasSQL.CTR in (SELECT CodCentro FROM WEB_CarteraUsuarioCentro_TMP WHERE WEB_CarteraUsuarioCentro_TMP.Usuario=@Usuario GROUP BY CodCentro)
	

	/* ******************************************** CENTROS ASIGNADOS ************************************************** */	
	
--	DECLARE @vCentrosAsignadosUsuario TABLE (CodCentro varchar(3))
	CREATE TABLE #vCentrosAsignadosUsuario  (CodCentro varchar(3))
	
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
	
	-- Insertamos Centros + ((Importes Ofertas & OfertasSQL)-(TIPO1 & Produccion de Elecnor{Ofertas Vivas})	)
	INSERT INTO WEB_CarteraUsuarioCentro (Usuario,Año,Mes,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)	
	SELECT @Usuario,@pAño,@pMes,WEB_CarteraUsuarioCentro_TMP.CodCentro,
		   (Sum(ImporteElecnor)/1000),
		   (Sum(ImporteFilial)/1000),
		   (Sum(ImporteUte)/1000),
		   (Sum(ImporteSucursal)/1000)	
	FROM WEB_CarteraUsuarioCentro_TMP INNER JOIN #vCentrosAsignadosUsuario ON WEB_CarteraUsuarioCentro_TMP.CodCentro=[#vCentrosAsignadosUsuario].CodCentro
	WHERE Usuario=@Usuario 
	GROUP BY WEB_CarteraUsuarioCentro_TMP.CodCentro	
	
	-- Insertamos Centros SIN Contratacion pero que pueden tener Objetivos
	INSERT INTO WEB_CarteraUsuarioCentro (Usuario,Año,Mes,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT @Usuario,@pAño,@pMes,[#vCentrosAsignadosUsuario].CodCentro,0,0,0,0
	FROM #vCentrosAsignadosUsuario LEFT JOIN 
		( SELECT WEB_CarteraUsuarioCentro.* 
		  FROM WEB_CarteraUsuarioCentro
		  WHERE Usuario=@Usuario) w ON w.CodCentro=[#vCentrosAsignadosUsuario].CodCentro
	WHERE  isnull(Usuario,'')=''
	GROUP BY [#vCentrosAsignadosUsuario].CodCentro,Usuario
	
	-- Actualizamos Sumarigrama de Centros Asigandos a Usuario
	UPDATE WEB_CarteraUsuarioCentro 
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
	WHERE  dbo.WEB_CarteraUsuarioCentro.CodCentro = dbo.Sumarigrama.CodCentro AND dbo.WEB_CarteraUsuarioCentro.Usuario = @Usuario			
	
	-- Actualizamos Ajustes de Centro
	UPDATE WEB_CarteraUsuarioCentro
	SET Ajustado=CentroCarteraAjustadaSQL.Ajustado
	FROM CentroCarteraAjustadaSQL
	WHERE CentroCarteraAjustadaSQL.CodCentro=WEB_CarteraUsuarioCentro.CodCentro

	-- Actualizamos CarteraPdteMesActual + CarteraPdteMesAnterior
	UPDATE WEB_CarteraUsuarioCentro
	SET ImporteCarteraPdteMesActual=w.Importe
	FROM (	SELECT CodCentro, Sum(CarteraPdteProducirSQL.Importe) as Importe 
			FROM CarteraPdteProducirSQL 
			WHERE CarteraPdteProducirSQL.Año= @pAño AND CarteraPdteProducirSQL.Mes=@pMes
			GROUP BY CarteraPdteProducirSQL.CodCentro) w
	WHERE dbo.WEB_CarteraUsuarioCentro.CodCentro = w.CodCentro AND dbo.WEB_CarteraUsuarioCentro.Usuario = @Usuario 
	
	IF @pMes=1
		BEGIN
			SET @pAño=@pAño-1
			SET @pMes=12
		END
	ELSE
		BEGIN
			SET @pMes=@pMes-1
		END

	UPDATE WEB_CarteraUsuarioCentro
	SET ImporteCarteraPdteMesAnterior=w.Importe
	FROM (	SELECT CodCentro, Sum(CarteraPdteProducirSQL.Importe) as Importe 
			FROM CarteraPdteProducirSQL 
			WHERE CarteraPdteProducirSQL.Año= @pAño AND CarteraPdteProducirSQL.Mes=@pMes
			GROUP BY CarteraPdteProducirSQL.CodCentro) w
	WHERE dbo.WEB_CarteraUsuarioCentro.CodCentro = w.CodCentro AND dbo.WEB_CarteraUsuarioCentro.Usuario = @Usuario 	

	/* ******************************* BORRAMOS TEMPORAL ***************************** */
	DELETE FROM WEB_CarteraUsuarioCentro_TMP WHERE Usuario like '%' +@Usuario_Sin_Fecha + '%'
	
	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha
	
	/* ********************************* RESULTADO *********************************** */	
	--SELECT WEB_CarteraUsuarioCentro.*  FROM WEB_CarteraUsuarioCentro WHERE Usuario = @Usuario	
	--AND CodCentro=539
	
	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END