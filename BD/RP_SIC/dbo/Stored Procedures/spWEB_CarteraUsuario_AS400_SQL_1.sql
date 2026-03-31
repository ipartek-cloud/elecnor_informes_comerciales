
CREATE PROCEDURE [dbo].[spWEB_CarteraUsuario_AS400_SQL]
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
	DECLARE @PoSIC_TESTion as int

	DECLARE @StartTime AS DATETIME = GETDATE()
	
	SET @PoSIC_TESTion=CHARINDEX('_',@Usuario)-1
	IF  @PoSIC_TESTion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@PoSIC_TESTion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	SELECT @Usuario_Puesto=Puesto, @Usuario_CodEntidad=CodEntidad FROM dbo.WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha	
	IF isnull(@Usuario_Puesto,'')='' RETURN -99999

	DELETE FROM WEB_CarteraUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_CarteraUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'
	
	/* ****************************** IMPORTES CONTRATACION d CENTRO DENTRO d PERIODO *********************************** */
		
	/* 
	   Cartera= Contratacion-Produccion

	   Contratacion = Ofertas de Alta(<>B & NO Adjudicada & No Obra).ImporteTotal (Anterior a la Fecha Seleccionada) - Regularizaciones Posteriores a Fecha Seleccionada --> Importe segun Tipo Oferta (Elecnor-Filial-Ute-Sucursal)
	                  Mas
					  OfertasSQL -->Importe Tipo 'Filial' 
	*/

	/*
---------------------------------------------------------------- desde AQUÍ
		Paco 2016-02-04

		Creo una copia temporal de los datos de la vista vwWEB_OFERTAS_CA que es la que tarda al acceder a datos del AS400.
		De esta forma las condiciones de filtro que luego aplicabamos en el SQL SERVER sobre las vistas definidas se realizan directamente en el AS400 
		y así se devuelven los datos filtrados
	*/
	-- Copia en local y filtrada de los datos de la vista vwWEB_OFERTAS_CA (acceso al AS400)
	DECLARE @SQL_AS400_select as varchar(1000)
	DECLARE @SQL_AS400_from as varchar(1000)
	DECLARE @SQL_AS400 as varchar(max)

	-- No se muy bien pero el EXEC no me funciona con SELECT INTO. POr eso lo hago con CREATE TABLE + INSERT INTO
--	CREATE TABLE #vwWEB_OFERTAS_CA_Local  (CodCentro varchar(3),CodOferta varchar(10), FAdjudicacion datetime, Adjudicada char(1), ImporteTotal float, Tipo varchar(10), DesOfer varchar(100))
	CREATE TABLE #vwWEB_OFERTAS_CA_Local  (CodCentro varchar(3), CodOferta varchar(10), FAdjudicacion datetime, Adjudicada varchar(1), ImporteTotal float, Tipo varchar(10), DesOfer varchar(100)
											, Baja varchar(1))
	CREATE NONCLUSTERED INDEX [#vwWEB_OFERTAS_CA_Local_CodCentro_CodOferta] ON #vwWEB_OFERTAS_CA_Local (CodCentro, CodOferta) INCLUDE (Tipo)	

	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_CA_Local (CodCentro,CodOferta, FAdjudicacion, ImporteTotal,Adjudicada,Tipo, DesOfer, Baja)
							SELECT CDCEN AS CodCentro, CDOFT AS CodOferta, 
									CASE WHEN LEN(FECHAD) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAD, 6), 103) 
										ELSE (CASE WHEN FECHAD = ''0'' THEN ''19990101'' ELSE NULL END) 
									END AS FAdjudicacion, 
									TVEN AS ImporteTotal, ADELE AS Adjudicada, WS10 AS Tipo, DCOF AS DesOfer
									, BAJA as Baja
							'

	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT OFCA.CDCEN, OFCA.CDOFT, OFCA.FECHAA, OFCA.DCOF, OFCA.CDCLI, OFCA.LOCAL, OFCA.PROOF, OFCA.IMAOF, OFCA.CDAC1, OFCA.CDAC2, OFCA.DECOF, OFCA.RPROF, OFCA.FECHPP, OFCA.PREVE, OFCA.FECHAD, OFCA.ADELE, OFCA.PREAD, OFCA.TCOS, OFCA.TVEN, OFCA.USER, OFCA.WS10, OFCA.DESPRO, OFCA.BAJA
									, Enlaces.CDOFT CDOFT_En
							 FROM  S44DD901.ICOMERF.IC09AP As OFCA LEFT OUTER JOIN S44DD901.FICOSCO.CO005BP AS Enlaces ON
									OFCA.CDCEN = Enlaces.CTRO AND OFCA.CDOFT = Enlaces.CDOFT
							 WHERE 								
								--((substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 1, 4 ) < ' + str(@pAño) + ') OR 
								-- (substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
								--) AND
								NOT (OFCA.ADELE <> ''''S'''' AND Enlaces.CDOFT IS NULL) AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 )>=2005
							'')'
-- Paco 03/07/2020 Comentado el filtro de fechas para que saque oferta no adjudicadas en la fecha de la solicitud pero con obras enlazadas que sí tienen produccion (la caartera sale negativa porque la adjuducacion a la fecha es 0)


	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vwWEB_OFERTAS_CA'
	--PRINT (@SQL_AS400)
	EXEC (@SQL_AS400)
	PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

---------------------------------------------------------------- hasta AQUÍ


	/* ***************************************************************************************************************** */
	/* ******************************************** CONTRATACION  ****************************************************** */
	/* ***************************************************************************************************************** */

	-- OFERTAS
		CREATE TABLE #vwWEB_OFERTAS_CA  (CodCentro varchar(3),CodOferta varchar(10),Adjudicada varchar(1), ImporteTotal float, Tipo varchar(10)
										, Baja varchar(1))

		CREATE NONCLUSTERED INDEX [#vwWEB_OFERTAS_CA_CodCentro_CodOferta] ON #vwWEB_OFERTAS_CA (CodCentro, CodOferta) INCLUDE (Tipo)	

		-- Insertamos Ofertas que No son Baja

		INSERT INTO #vwWEB_OFERTAS_CA(CodCentro,CodOferta, ImporteTotal,Adjudicada,Tipo, Baja) 
		SELECT CodCentro,CodOferta,ImporteTotal,Adjudicada,Tipo, Baja
		FROM #vwWEB_OFERTAS_CA_Local 
		WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes))

		PRINT 'Time 1.1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	

	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)	
	SELECT  1,@Usuario,[#vwWEB_OFERTAS_CA].CodCentro,	
			sum(dbo.fnImporteCartera('E',Tipo,ImporteTotal,REG.ImporteRegularizacion)) as ImporteElecnor,
			sum(dbo.fnImporteCartera('F',Tipo,ImporteTotal,REG.ImporteRegularizacion)) as ImporteFilial,
			sum(dbo.fnImporteCartera('U',Tipo,ImporteTotal,REG.ImporteRegularizacion)) as ImporteUte,
			sum(dbo.fnImporteCartera('S',Tipo,ImporteTotal,REG.ImporteRegularizacion)) as ImporteSucursal			
	FROM #vwWEB_OFERTAS_CA LEFT JOIN (
	
			SELECT cdcen AS CodCentro,cdoft AS CodOferta,sum(Impre) AS ImporteRegularizacion
			FROM IC10AP
			WHERE ((AR=@pAño AND MR>@pMes) OR (AR>@pAño)) AND Usuario=@Usuario
			GROUP BY cdcen,cdoft
	
	) AS REG ON
		[#vwWEB_OFERTAS_CA].CodCentro=REG.CodCentro AND
		[#vwWEB_OFERTAS_CA].CodOferta=REG.CodOferta
	WHERE Baja <> 'B'
	GROUP BY [#vwWEB_OFERTAS_CA].CodCentro

	PRINT 'Time 1.2º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
		
	-- OFERTASsql que no estan marcas como Baja en OfertasBajasSQL
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)	
	SELECT  2,@Usuario,dbo.OfertasSQL.CodCentro,0,sum(ImporteContratado) as ImporteFilial,0,0
	FROM  dbo.OfertasSQL LEFT JOIN dbo.OfertasBajasSQL ON dbo.OfertasSQL.CodCentro=dbo.OfertasBajasSQL.CodCentro AND dbo.OfertasSQL.CodOferta=dbo.OfertasBajasSQL.CodOferta
	WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND isnull(dbo.OfertasBajasSQL.CodOferta,'')='' 
	GROUP BY dbo.OfertasSQL.CodCentro

	PRINT 'Time 1.3º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

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

	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT  10,@Usuario,vw1.CodCentro,(sum(TotalSOP)*-1) as ImporteElecnor,0,0,0
	FROM (SELECT DISTINCT Usuario, CodCentro FROM WEB_CarteraUsuarioCentro_TMP) vw1 INNER JOIN (
		SELECT vwEnlaces_Obras_SOP.CodCentro, SUM(vwEnlaces_Obras_SOP.TotalSOP) AS TotalSOP
		FROM   #vwWEB_OFERTAS_CA INNER JOIN (

					SELECT   ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwEnlaces.CTRO AS CodCentro, vwEnlaces.CDOFT,SUM(ObrasActualesSQL.SOP) AS TotalSOP
					FROM     ( SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario AND CDOFT<>'0000000001' ) vwEnlaces INNER JOIN
							   ObrasActualesSQL ON vwEnlaces.CTRO = ObrasActualesSQL.CTR AND vwEnlaces.OBRA = ObrasActualesSQL.OBRA AND vwEnlaces.OBRAL = ObrasActualesSQL.OBRAL
					WHERE Año=@pAño and Mes=@pMes
					GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwEnlaces.CTRO, vwEnlaces.CDOFT

			   ) vwEnlaces_Obras_SOP ON [#vwWEB_OFERTAS_CA].CodOferta = vwEnlaces_Obras_SOP.CDOFT AND 
			   [#vwWEB_OFERTAS_CA].CodCentro = vwEnlaces_Obras_SOP.CodCentro
		WHERE  ([#vwWEB_OFERTAS_CA].Tipo = 'E') AND Año=@pAño AND Mes=@pMes
				AND Baja <> 'B'
		GROUP BY vwEnlaces_Obras_SOP.CodCentro) vw on 
			vw1.CodCentro=vw.CodCentro
	WHERE vw1.Usuario=@Usuario
	GROUP BY vw1.CodCentro	

	PRINT 'Time 1.4º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	-------------------------------------
-- GP00 05/02/2019
-- Para incluir producciones del mes de obras de ofertas que tienen fecha de adjudicacion futura
-- Ahora se estaban excluyendo porque solo se consideraban ofertas adjudicadas hasta el mes en cuestion

	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT 99,@Usuario,vw1.CodCentro,(sum(TotalSOP)*-1) as ImporteElecnor,0,0,0
	FROM (SELECT DISTINCT Usuario, CodCentro FROM WEB_CarteraUsuarioCentro_TMP) vw1 INNER JOIN (
	SELECT vwEnlaces_Obras_SOP.CodCentro, SUM(vwEnlaces_Obras_SOP.TotalSOP) AS TotalSOP
		FROM   #vwWEB_OFERTAS_CA RIGHT JOIN(

					SELECT   ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwEnlaces.CTRO AS CodCentro, vwEnlaces.CDOFT,SUM(ObrasActualesSQL.SOP) AS TotalSOP
					FROM     ( SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario AND CDOFT<>'0000000001' ) vwEnlaces INNER JOIN
							   ObrasActualesSQL ON vwEnlaces.CTRO = ObrasActualesSQL.CTR AND vwEnlaces.OBRA = ObrasActualesSQL.OBRA AND vwEnlaces.OBRAL = ObrasActualesSQL.OBRAL
					WHERE Año=@pAño and Mes=@pMes
					GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwEnlaces.CTRO, vwEnlaces.CDOFT

			   ) vwEnlaces_Obras_SOP ON [#vwWEB_OFERTAS_CA].CodOferta = vwEnlaces_Obras_SOP.CDOFT AND 
			   [#vwWEB_OFERTAS_CA].CodCentro = vwEnlaces_Obras_SOP.CodCentro
		WHERE   Año=@pAño AND Mes=@pMes AND #vwWEB_OFERTAS_CA.CodOferta IS NULL
		GROUP BY vwEnlaces_Obras_SOP.CodCentro
	) vw on vw1.CodCentro=vw.CodCentro
	WHERE vw1.Usuario=@Usuario
	GROUP BY vw1.CodCentro	

	PRINT 'Time 1.5º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

/* -------------- FIN cambio        Paco 2015-07-14 */

	-- Ofertas TIPO1 (Solo Enlaces & CodOferta=1 <-JOIN-> OfertasActualesSQL (Año,Mes)) = Produccion Elecnor

/* -------------- INICIO cambio        Paco 2015-07-14 */
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT  11,@Usuario,vw1.CodCentro,(sum(TotalSOP)*-1) as ImporteElecnor,0,0,0	
	FROM (SELECT DISTINCT Usuario, CodCentro FROM WEB_CarteraUsuarioCentro_TMP WHERE Tipo<>10) vw1 INNER JOIN(
	
		SELECT ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO.CTRO AS CodCentro, SUM(CASE WHEN (stobr <> 'C') THEN ObrasActualesSQL.SOP ELSE 0 END) AS TotalSOP
		FROM  (SELECT * FROM CO005BP WHERE Usuario=@Usuario AND CDOFT='0000000001')  vwTipoUNO INNER JOIN ObrasActualesSQL ON
													 vwTipoUNO.CTRO = ObrasActualesSQL.CTR AND vwTipoUNO.OBRA = ObrasActualesSQL.OBRA AND vwTipoUNO.OBRAL = ObrasActualesSQL.OBRAL
		GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO.CTRO

	) vwTIPOUNO_ProduccionElecnor on 
	vw1.CodCentro=vwTIPOUNO_ProduccionElecnor.CodCentro
	WHERE Año=@pAño AND Mes=@pMes AND TotalSOP<>0 and Usuario=@Usuario -- Se acaban de insertar el mas veces el mismo Centro con importe negativo
	GROUP BY vw1.CodCentro

	PRINT 'Time 1.6º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

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
			AND Baja <> 'B'
	GROUP BY ObrasHistoricasSQL.CTR

	PRINT 'Time 1.7º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	/* ****************************************************************************************************************** */
	/* ******************************************** OBRAS OTRAS ********************************************************* */
	/* ****************************************************************************************************************** */
	
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT 30, @Usuario, OO.CTR, 
			dbo.fnImporteCartera('E',TipoOferta,OO.SOP,0)*-1,
			dbo.fnImporteCartera('F',TipoOferta,OO.SOP,0)*-1,
			dbo.fnImporteCartera('U',TipoOferta,OO.SOP,0)*-1,
			dbo.fnImporteCartera('S',TipoOferta,OO.SOP,0)*-1	
	FROM   #vwWEB_OFERTAS_CA INNER JOIN
           ObrasOtrasSQL_NO_BAJA AS OO ON [#vwWEB_OFERTAS_CA].CodOferta = OO.CDOFT --AND [#vwWEB_OFERTAS_CA].CodCentro = OO.CTR AND [#vwWEB_OFERTAS_CA].Tipo = OO.TipoOferta 
	WHERE  OO.CTR in (SELECT CodCentro FROM WEB_CarteraUsuarioCentro_TMP WHERE WEB_CarteraUsuarioCentro_TMP.Usuario=@Usuario GROUP BY CodCentro)

	PRINT 'Time 1.8º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
		
	INSERT INTO WEB_CarteraUsuarioCentro_TMP(Tipo,Usuario,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT 40, @Usuario, OO.CTR, 
			dbo.fnImporteCartera('E',TipoOferta,OO.SOP,0)*-1,
			dbo.fnImporteCartera('F',TipoOferta,OO.SOP,0)*-1,
			dbo.fnImporteCartera('U',TipoOferta,OO.SOP,0)*-1,
			dbo.fnImporteCartera('S',TipoOferta,OO.SOP,0)*-1	
	FROM ObrasOtrasSQL_NO_BAJA AS OO LEFT OUTER JOIN #vwWEB_OFERTAS_CA_Local AS OCA ON OO.CDOFT = OCA.CodOferta --AND OO.CTR = OCA.CodCentro AND OO.TipoOferta=OCA.Tipo
	WHERE  OO.CTR in (SELECT CodCentro FROM WEB_CarteraUsuarioCentro_TMP WHERE WEB_CarteraUsuarioCentro_TMP.Usuario=@Usuario GROUP BY CodCentro)
		   and OCA.CodOferta is null AND OCA.CodCentro is null AND OCA.Tipo is null
		   and isnull(OO.OBRA,'')<>''	
	
	PRINT 'Time 2º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	


	/* ******************************************** CENTROS ASIGNADOS ************************************************** */	


	--SELECT * FROM WEB_CarteraUsuarioCentro_TMP WHERE Usuario = 'anruiz_5934' AND CodCentro=127
	
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
	
	PRINT 'Time 2.1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
	
	-- Insertamos Centros SIN Contratacion pero que pueden tener Objetivos
	INSERT INTO WEB_CarteraUsuarioCentro (Usuario,Año,Mes,CodCentro,ImporteElecnor,ImporteFilial,ImporteUte,ImporteSucursal)
	SELECT @Usuario,@pAño,@pMes,[#vCentrosAsignadosUsuario].CodCentro,0,0,0,0
	FROM #vCentrosAsignadosUsuario LEFT JOIN 
		( SELECT WEB_CarteraUsuarioCentro.* 
		  FROM WEB_CarteraUsuarioCentro
		  WHERE Usuario=@Usuario) w ON w.CodCentro=[#vCentrosAsignadosUsuario].CodCentro
	WHERE  isnull(Usuario,'')=''
	GROUP BY [#vCentrosAsignadosUsuario].CodCentro,Usuario

	PRINT 'Time 2.2º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

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
	
	PRINT 'Time 2.3º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'		

	-- Actualizamos Ajustes de Centro
	UPDATE WEB_CarteraUsuarioCentro
	SET Ajustado=CentroCarteraAjustadaSQL.Ajustado
	FROM CentroCarteraAjustadaSQL
	WHERE CentroCarteraAjustadaSQL.CodCentro=WEB_CarteraUsuarioCentro.CodCentro

	PRINT 'Time 2.4º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	-- Actualizamos CarteraPdteMesActual + CarteraPdteMesAnterior
	UPDATE WEB_CarteraUsuarioCentro
	SET ImporteCarteraPdteMesActual=w.Importe
	FROM (	SELECT CodCentro, Sum(CarteraPdteProducirSQL.Importe) as Importe 
			FROM CarteraPdteProducirSQL 
			WHERE CarteraPdteProducirSQL.Año= @pAño AND CarteraPdteProducirSQL.Mes=@pMes
			GROUP BY CarteraPdteProducirSQL.CodCentro) w
	WHERE dbo.WEB_CarteraUsuarioCentro.CodCentro = w.CodCentro AND dbo.WEB_CarteraUsuarioCentro.Usuario = @Usuario 

	PRINT 'Time 2.5º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
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

	PRINT 'Time 2.6º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	--select * from WEB_CarteraUsuarioCentro where CodCentro=127 and   Usuario=@Usuario	

	/* ******************************* BORRAMOS TEMPORAL ***************************** */
	--DELETE FROM WEB_CarteraUsuarioCentro_TMP WHERE Usuario like '%' +@Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_CarteraUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	
	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha
	
	/* ********************************* RESULTADO *********************************** */	
	--SELECT WEB_CarteraUsuarioCentro.*  FROM WEB_CarteraUsuarioCentro WHERE Usuario = @Usuario AND CodCentro=164
	
	return 0 -- NO ERROR
	
	--END TRY
	--BEGIN CATCH
	--print 'Error'
	--	return ERROR_NUMBER ()
	--END CATCH
	
END