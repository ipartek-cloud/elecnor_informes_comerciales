


CREATE PROCEDURE [dbo].[spWEB_CarteraPdteEjecutar]
	@Usuario varchar(50), 		
	@pAño int,
	@pMes int,
	@pTipo varchar(2),  -- DN/DE	
	@pCodigo varchar(100)
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY
	
	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @Posicion as int

	--SELECT CodCentro FROM Sumarigrama WHERE NombreDelegacion = 'Distribución MADRID' --@@pCodigo
	CREATE TABLE #Centros (CodCentro char(3))
	
	IF (@pTIpo='DN')
		INSERT INTO #Centros 
		SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
		FROM Sumarigrama  WHERE CodDDirNegocio = @pCodigo
	ELSE IF (@pTIpo='DEL')
		INSERT INTO #Centros 
		SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
		FROM Sumarigrama  WHERE CodDelegacion = @pCodigo
		ELSE IF (@pTipo='AREA')
			INSERT INTO #Centros 
			SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
			FROM Sumarigrama  WHERE CodSubDirNegocioArea= @pCodigo
			ELSE IF (@pTipo='SG')
				INSERT INTO #Centros 
				SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
				FROM Sumarigrama  WHERE CodSubDirGeneral= @pCodigo
				ELSE IF (@pTipo='CT')
					INSERT INTO #Centros 
					SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
					FROM Sumarigrama  WHERE CodCentro  = @pCodigo

	--SELECT * from #Centros

	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	--DELETE FROM dbo.WEB_CarteraDetalladaUsuarioCentro WHERE Usuario like '%' + @Usuario_Sin_Fecha + '%'
	DELETE FROM dbo.WEB_CarteraDetalladaUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'
	
	--DECLARE @WEB_CarteraUsuarioCentro_TMP TABLE (CodCentro char(3),CodOferta varchar(10),FAdjudicacion datetime,DesOfer varchar(50),ImporteContratado float,ImporteProd float,ImporteFactura float,ImporteFot float,TipoOferta varchar(1),Tipo int)	
	CREATE TABLE #WEB_CarteraUsuarioCentro_TMP (CodCentro char(3),CodOferta varchar(10),FAdjudicacion datetime,DesOfer varchar(50),ImporteContratado float,ImporteProd float,ImporteFactura float,ImporteFot float,TipoOferta varchar(1),Tipo int)	

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
	CREATE TABLE #vwWEB_OFERTAS_CA_Local  (CodCentro varchar(3),CodOferta varchar(10), FAdjudicacion datetime, Adjudicada char(1), ImporteTotal float, Tipo varchar(10), DesOfer varchar(100))
	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_CA_Local (CodCentro,CodOferta, FAdjudicacion, ImporteTotal,Adjudicada,Tipo, DesOfer)
							SELECT CDCEN AS CodCentro, CDOFT AS CodOferta, 
									CASE WHEN LEN(FECHAD) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAD, 6), 103) 
										ELSE (CASE WHEN FECHAD = ''0'' THEN ''19990101'' ELSE NULL END) 
									END AS FAdjudicacion, 
									TVEN AS ImporteTotal, ADELE AS Adjudicada, WS10 AS Tipo, DCOF AS DesOfer
							'

	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT OFCA.CDCEN, OFCA.CDOFT, OFCA.FECHAA, OFCA.DCOF, OFCA.CDCLI, OFCA.LOCAL, OFCA.PROOF, OFCA.IMAOF, OFCA.CDAC1, OFCA.CDAC2, OFCA.DECOF, OFCA.RPROF, OFCA.FECHPP, OFCA.PREVE, OFCA.FECHAD, OFCA.ADELE, OFCA.PREAD, OFCA.TCOS, OFCA.TVEN, OFCA.USER, OFCA.WS10, OFCA.DESPRO, OFCA.BAJA
									, Enlaces.CDOFT CDOFT_En
							 FROM  S44DD901.ICOMERF.IC09AP As OFCA LEFT OUTER JOIN S44DD901.FICOSCO.CO005BP AS Enlaces ON
									OFCA.CDCEN = Enlaces.CTRO AND OFCA.CDOFT = Enlaces.CDOFT
							 WHERE OFCA.BAJA <> ''''B'''' AND 
								((substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 ) < ' + str(@pAño) + ') OR 
								 (substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
								) AND
								NOT (OFCA.ADELE <> ''''S'''' AND Enlaces.CDOFT IS NULL)
							'')'

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vwWEB_OFERTAS_CA'

	--PRINT (@SQL_AS400)
	EXEC (@SQL_AS400)


	--------------------------------
	-- Paco 20/04/2016 Table temporal de Ofertas dadas de baja para EXCLUIR SIEMPRE las ofertas de baja en relaciones posteriores
	CREATE TABLE #OfertasDeBaja (CodCentro varchar(3),CodOferta varchar(10))
	SET @SQL_AS400_select = 'INSERT INTO #OfertasDeBaja (CodCentro,CodOferta)
							SELECT CDCEN AS CodCentro, CDOFT AS CodOferta
							'

	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT CDCEN, CDOFT, FECHAA, DCOF, CDCLI, LOCAL, PROOF, IMAOF, CDAC1, CDAC2, DECOF, RPROF, FECHPP, PREVE, FECHAD, ADELE, PREAD, TCOS, TVEN, USER, WS10, DESPRO, BAJA
							 FROM S44DD901.ICOMERF.IC09AP
							 WHERE BAJA = ''''B'''' 
							 '')'
	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') OfertasDeBaja'
	--PRINT (@SQL_AS400)
	EXEC (@SQL_AS400)

---------------------------------------------------------------- hasta AQUÍ
	/* ***************************************************************************************************************** */
	/* ******************************************** CONTRATACION  ****************************************************** */
	/* ***************************************************************************************************************** */

	-- OFERTAS
		--DECLARE @vwWEB_OFERTAS_CA TABLE (CodOferta varchar(10),FAdjudicacion datetime,DesOfer varchar(50), ImporteTotal float, Tipo char(10))
		CREATE TABLE #vwWEB_OFERTAS_CA (CodOferta varchar(10),FAdjudicacion datetime,DesOfer varchar(50), ImporteTotal float, Tipo char(10))
		
		-- Insertamos Ofertas que No son Baja
		INSERT INTO #vwWEB_OFERTAS_CA(CodOferta,FAdjudicacion,DesOfer,ImporteTotal,Tipo) 
		SELECT CodOferta,[dbo].[fnQuitar1999](FAdjudicacion) as FAdjudicacion ,DesOfer,ImporteTotal,Tipo 
		FROM #vwWEB_OFERTAS_CA_Local 
		WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND CodCentro IN (SELECT CodCentro FROM #Centros)
		

	-- REGULARIZACIONES Posteriores
		--DECLARE @vRegularizaciones TABLE (CodOferta varchar(10), ImporteRegularizacion float)
	CREATE TABLE #vRegularizaciones (CodCentro varchar(3),CodOferta varchar(10), ImporteRegularizacion float)

	INSERT into #vRegularizaciones(CodCentro,CodOferta,ImporteRegularizacion) 
	SELECT cdcen,cdoft,sum(Impre)
			FROM Regularizaciones
			WHERE (dbo.Regularizaciones.AñoR=@pAño AND
				  dbo.Regularizaciones.MesR>@pMes) 
				  OR
				  (dbo.Regularizaciones.AñoR>@pAño)
	GROUP BY cdcen,cdoft
	--order by cdoft
-----------------------------------

	-- OFERTAS - REGULARIZACIONES Posteriores
	INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,FAdjudicacion,DesOfer,ImporteContratado)	
	SELECT  1,Tipo,'',[#vwWEB_OFERTAS_CA].CodOferta,FAdjudicacion,DesOfer,isnull(ImporteTotal,0)-isnull(ImporteRegularizacion,0)	
	FROM #vwWEB_OFERTAS_CA LEFT JOIN #vRegularizaciones ON [#vwWEB_OFERTAS_CA].CodOferta=[#vRegularizaciones].CodOferta

	-- OFERTASsql que no esten marcadas como bajas OfertasBajasSQL
	-- NO son de Reparto: Mismo Importe
		INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,FAdjudicacion,DesOfer,ImporteContratado)	
		SELECT  2,'F','',dbo.OfertasSQL.CodOferta,FAdjudicacion,DescripcionOferta,ImporteContratado
		FROM  dbo.OfertasSQL LEFT JOIN dbo.OfertasBajasSQL ON dbo.OfertasSQL.CodCentro=dbo.OfertasBajasSQL.CodCentro AND dbo.OfertasSQL.CodOferta=dbo.OfertasBajasSQL.CodOferta
		WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND dbo.OfertasSQL.CodCentro IN (SELECT CodCentro FROM #Centros) 
			  AND isnull(dbo.OfertasBajasSQL.CodOferta,'')='' AND Reparto=0	
	
	
	-- SI son de Reparto: Suma de los Importes
		INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,FAdjudicacion,DesOfer,ImporteContratado)	
		SELECT  2,'F','',dbo.OfertasSQL.CodOferta,Min(FAdjudicacion),DescripcionOferta,sum(ImporteContratado)
		FROM  dbo.OfertasSQL LEFT JOIN dbo.OfertasBajasSQL ON dbo.OfertasSQL.CodCentro=dbo.OfertasBajasSQL.CodCentro AND dbo.OfertasSQL.CodOferta=dbo.OfertasBajasSQL.CodOferta
		WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND dbo.OfertasSQL.CodCentro IN (SELECT CodCentro FROM #Centros)
			  AND isnull(dbo.OfertasBajasSQL.CodOferta,'')='' AND Reparto=1 
		GROUP BY dbo.OfertasSQL.CodOferta,DescripcionOferta	

	
	/* ***************************************************************************************************** */
	/* *********************************************** TOTAL *********************************************** */	
	/* ***************************************************************************************************** */
	
	/* ********************************************* OBRAS VIVAS ********************************************* */
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro
           (Usuario, Tipo, CodOferta, DescripcionOferta, FAdjudicacion, ImporteContratado, Obra, ObraL, NombreObra, FApertura, FCierre, ImporteProduccion, ImporteFactura, ImporteFot,Est)
	SELECT @Usuario,TipoOferta,isnull([#WEB_CarteraUsuarioCentro_TMP].CodOferta,''),DesOfer,
		   replace(right(convert(varchar(10),FAdjudicacion,103),7),'/','_'),
		   isnull(ImporteContratado,0),Obra,ObraL,isnull(NombreObra,''),isnull(dbo.fnFormatFecha(FechaApertura),''),isnull(dbo.fnFormatFecha(FechaCierre),''),
		   isnull(ImporteProduccion,0),isnull(vwTIPOUNO_Produccion_Detallado.ImporteFactura,0),isnull(vwTIPOUNO_Produccion_Detallado.ImporteFot,0), Est
	FROM #WEB_CarteraUsuarioCentro_TMP
	      LEFT JOIN vwTIPOUNO_Produccion_Detallado on [#WEB_CarteraUsuarioCentro_TMP].CodOferta=vwTIPOUNO_Produccion_Detallado.CodOferta AND CAST([#WEB_CarteraUsuarioCentro_TMP].CodCentro AS INT)=CAST(vwTIPOUNO_Produccion_Detallado.CodCentro AS INT) 
	WHERE (Año=@pAño AND Mes=@pMes) OR isnull(Año,0)=0 -- Adjudicadas OR Sin Obra	

		select CodOferta, ImporteContratado, SUM(ImporteProduccion) ImporteProduccion from WEB_CarteraDetalladaUsuarioCentro	
		where   Usuario = @Usuario
		group by CodOferta, ImporteContratado
		return(0)

-------------------------------------
-- Paco 2016-05-05
-- Para incluir producciones del mes de obras de ofertas que tienen fecha de adjudicacion futura
-- Ahora se estaban excluyendo porque solo se consideraban ofertas adjudicadas hasta el mes en cuestion
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro
           (Usuario, Tipo, CodOferta, DescripcionOferta, FAdjudicacion, ImporteContratado, Obra, ObraL, NombreObra, FApertura, FCierre, ImporteProduccion, ImporteFactura, ImporteFot,Est)
	SELECT @Usuario,C.Tipo,isnull(B.CodOferta,''),C.DesOfer,
			CASE WHEN Year(C.FAdjudicacion)>@pAño OR (Year(C.FAdjudicacion)=@pAño AND Month(C.FAdjudicacion)>@pMes)
				THEN ''
				ELSE replace(right(convert(varchar(10),C.FAdjudicacion,103),7),'/','_') 
			END,
			isnull(ImporteContratado,0),Obra,ObraL,isnull(NombreObra,''),isnull(dbo.fnFormatFecha(FechaApertura),''),isnull(dbo.fnFormatFecha(FechaCierre),''),
			isnull(ImporteProduccion,0),isnull(B.ImporteFactura,0),isnull(B.ImporteFot,0), Est
	FROM #WEB_CarteraUsuarioCentro_TMP A RIGHT JOIN 
		vwTIPOUNO_Produccion_Detallado B on A.CodOferta=B.CodOferta AND CAST(A.CodCentro AS INT)=CAST(B.CodCentro AS INT) INNER JOIN 
		#vwWEB_OFERTAS_CA_Local C ON B.CodOferta=C.CodOferta AND B.CodCentro=C.CodCentro
	WHERE (Año=@pAño AND Mes=@pMes) and A.CodOferta is null AND B.CodCentro IN (SELECT CodCentro FROM #Centros) 
-------------------------------------


	--TIPO1
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est)
	SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,dbo.fnFormatFecha(FechaApertura),dbo.fnFormatFecha(FechaCierre),ImporteProduccion,ImporteFactura,ImporteFot,Est
	FROM [dbo].[vwTIPOUNO_ProduccionElecnor_Detallado]
	WHERE Año=@pAño AND Mes=@pMes AND CodCentro IN (SELECT CodCentro FROM #Centros)

	/* ********************************************* OBRAS HISTORICO ********************************************* */	
	-- Actualizamos las Vivas ya que existen siempre pero con importes a cero, si no, no estaria en historico.

/*
-------------------------------- Desde AQUI

*/
	SELECT WEB_CarteraDetalladaUsuarioCentro.CodOferta, 
			WEB_CarteraDetalladaUsuarioCentro.Obra, 
			WEB_CarteraDetalladaUsuarioCentro.ObraL,
			vwProduccion_Detallado_Historico.CodCentro,
			vwProduccion_Detallado_Historico.ImporteProduccion,
			vwProduccion_Detallado_Historico.ImporteFactura,
			vwProduccion_Detallado_Historico.ImporteFot,
			vwProduccion_Detallado_Historico.FApertura,
			vwProduccion_Detallado_Historico.FCierre
	INTO #WEB_CarteraDetalladaUsuarioCentro
		FROM WEB_CarteraDetalladaUsuarioCentro WITH (NOLOCK) INNER JOIN vwProduccion_Detallado_Historico ON
			 WEB_CarteraDetalladaUsuarioCentro.CodOferta=vwProduccion_Detallado_Historico.CodOferta AND
			 WEB_CarteraDetalladaUsuarioCentro.Obra=vwProduccion_Detallado_Historico.Obra AND
			 WEB_CarteraDetalladaUsuarioCentro.ObraL=vwProduccion_Detallado_Historico.ObraL
		WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND vwProduccion_Detallado_Historico.CodCentro IN (SELECT CodCentro FROM #Centros)


	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ImporteProduccion=#WEB_CarteraDetalladaUsuarioCentro.ImporteProduccion,
	    ImporteFactura=#WEB_CarteraDetalladaUsuarioCentro.ImporteFactura,
		ImporteFot=#WEB_CarteraDetalladaUsuarioCentro.ImporteFot,
		FApertura=replace(#WEB_CarteraDetalladaUsuarioCentro.FApertura,'-','_'),
		FCierre=replace(#WEB_CarteraDetalladaUsuarioCentro.FCierre,'-','_')
	FROM WEB_CarteraDetalladaUsuarioCentro WITH (NOLOCK) INNER JOIN #WEB_CarteraDetalladaUsuarioCentro WITH (NOLOCK) ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=#WEB_CarteraDetalladaUsuarioCentro.CodOferta AND
		 WEB_CarteraDetalladaUsuarioCentro.Obra=#WEB_CarteraDetalladaUsuarioCentro.Obra AND
		 WEB_CarteraDetalladaUsuarioCentro.ObraL=#WEB_CarteraDetalladaUsuarioCentro.ObraL
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND #WEB_CarteraDetalladaUsuarioCentro.CodCentro IN (SELECT CodCentro FROM #Centros)
-------------------------------- Hasta AQUI

	/* ********************************************* OBRAS OTRAS ********************************************* */
	-- No tendran Codigo de Obra(la mayoria) y pueden ser de todos los Tipos	, No esta enlazado con Ofertas <--> Obra
	-- En el este caso insertamos las ofertas que anteriormente se a indicado produccion y actualizamos ofertas que no tengan produccion
	
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est)
	SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est
	FROM WEB_CarteraDetalladaUsuarioCentro INNER JOIN ObrasOtrasSQL ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros) AND
		  WEB_CarteraDetalladaUsuarioCentro.Tipo=ObrasOtrasSQL.TipoOferta AND isnull(WEB_CarteraDetalladaUsuarioCentro.NombreObra,'')<>''
	GROUP BY TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est
	

	--------------------------------------------------------------------------------
	-- Paco 22/02/2016
	-- Paco 20/04/2016 Incluído relacion con table temporal de Ofertas dadas de baja para EXCLUIR SIEMPRE las ofertas de baja
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est)
	SELECT @Usuario,TipoOferta,CDOFT CodOferta,Isnull(DescripcionOferta,''),IsNull(FAdjudicacion,''),IsNull(ImporteContratado,0),TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est
	FROM WEB_CarteraDetalladaUsuarioCentro RIGHT JOIN ObrasOtrasSQL ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
		 LEFT JOIN #OfertasDeBaja OB ON ObrasOtrasSQL.CDOFT = OB.CodOferta
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario is null AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros)
			AND OB.CodOferta is null
	GROUP BY TipoOferta,CDOFT,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est

	--------------------------------------------------------------------------------
	 
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ImporteProduccion=SOP,
	    ImporteFactura=SOF,
		ImporteFot=SOL,
		NombreObra= TipoOferta+[dbo].[fnObra](TipoOferta,ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  + DSOBR,
		FApertura=replace(ObrasOtrasSQL.FApertura,'/','_'),
		FCierre=replace(ObrasOtrasSQL.FCierre,'/','_')
	FROM WEB_CarteraDetalladaUsuarioCentro INNER JOIN ObrasOtrasSQL ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros) AND
		  WEB_CarteraDetalladaUsuarioCentro.Tipo=ObrasOtrasSQL.TipoOferta AND isnull(WEB_CarteraDetalladaUsuarioCentro.NombreObra,'')=''


	/* ****************************************** CONTRATOS MARCO ********************************************* */
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ContratoMarco='*'
	WHERE CodOferta IN (SELECT CodOferta FROM vwCart_DiferidaOfertasContratosSQL WHERE Año=@pAño)



    /* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha		

	/* ********************* CALCULO DE LA APORTACION ANUAL ********************************* */

	CREATE TABLE #OfertaDatosAnuales_TMP (CodOferta varchar(10), Produccion_A float, CostoTotal_A float, MargenProduccion_A float, PorcProduccion_A float)	
	INSERT INTO #OfertaDatosAnuales_TMP
	SELECT E.CDOFT, 
			SUM(O.SAP) Produccion_A,
			--O.SAMO CostoMO_A,
			--O.SAMA CostoMateriales_A,
			--O.SAE CostoEquipos_A,
			--O.SAT CostoTransporte_A,
			--O.SAS CostoSubcontrata_A,
			--O.SAV CostoVarios_A,
			--O.SAI CostoIndirectos_A,
			--O.SAPR CostoPrevisto_A,

			SUM(O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR) CostoTotal_A,

			SUM(O.SAP) - SUM((O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR)) MargenProduccion_A,
			CASE WHEN SUM(O.SAP)=0
				THEN 0
				ELSE ROUND(100*(SUM(O.SAP) - SUM((O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR))) / SUM(O.SAP) ,2)
				END PorcProduccion
 
	FROM (
			SELECT *
			FROM OPENQUERY(SIC, '
			SELECT     *
			FROM         S44DD901.FICOSCO.CO005BP AS Enlaces')
		) E INNER JOIN 
		(
			SELECT * FROM Obras
		) O ON E.CTRO=O.CTR AND E.OBRA=O.OBRA+O.OBRAL 
	WHERE O.CTR IN (SELECT CodCentro FROM #Centros)
	GROUP BY E.CDOFT

	/* ********************************* RESULTADO *********************************** */
	

	SELECT q.CodOferta, SUM(q.ImporteContratado) Contratacion, SUM(q.ImporteProduccion) Produccion, SUM(q.ImporteContratado)-SUM(q.ImporteProduccion) CarteraPendiente
						,IsNull(t.Produccion_A,0) Produccion_A, IsNull(t.CostoTotal_A, 0 ) CostoTotal_A, IsNull(t.MargenProduccion_A, 0) MargenProduccion_A, IsNull(t.PorcProduccion_A, 0) PorcProduccion_A
	from (
		select CodOferta, ImporteContratado, SUM(ImporteProduccion) ImporteProduccion from WEB_CarteraDetalladaUsuarioCentro	
		where   Usuario = @Usuario
		group by CodOferta, ImporteContratado) q LEFT JOIN #OfertaDatosAnuales_TMP t ON q.CodOferta=t.CodOferta
	group by q.CodOferta, t.Produccion_A, t.CostoTotal_A, t.MargenProduccion_A, t.PorcProduccion_A
	order by q.CodOferta

	return (0)
	
	 --SELECT WEB_CarteraDetalladaUsuarioCentro.*  
	 --FROM WEB_CarteraDetalladaUsuarioCentro
	 --WHERE Usuario = @Usuario
	 --ORDER BY CodOferta
	 		
	--return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH		
		return ERROR_NUMBER ()
	END CATCH
	
END