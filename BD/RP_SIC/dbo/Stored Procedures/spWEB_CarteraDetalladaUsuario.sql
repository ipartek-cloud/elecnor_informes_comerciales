


-- delete from WEB_CarteraDetalladaUsuarioCentro
-- exec spWEB_CarteraDetalladaUsuario 'eluque_9999', 2019,4, 34, null
-- select * from web_CarteraDetalladaUsuarioCentro  where usuario like 'eluque%' and nombreobra like '335-00 av%' order by codoferta 


CREATE PROCEDURE [dbo].[spWEB_CarteraDetalladaUsuario]
	@Usuario varchar(50), 		
	@pAño int,
	@pMes int,	
	@pCodCentro varchar(3),
	@pTipoEntidad varchar(4) = ''
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY
	
	CREATE TABLE #Centros (CodCentro varchar(3))	

	DECLARE @StartTime AS DATETIME = GETDATE()

	INSERT INTO #Centros 
	SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
	FROM Sumarigrama  WHERE CodCentro = @pCodCentro

	IF (@pTipoEntidad='DN')
		BEGIN
			INSERT INTO #Centros 
			SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
			FROM Sumarigrama  WHERE CodDDirNegocio = @pCodCentro	
		END
	ELSE IF (@pTipoEntidad='DEL')
		BEGIN
			INSERT INTO #Centros 
			SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
			FROM Sumarigrama  WHERE CodDelegacion = @pCodCentro			
		END
	ELSE IF (@pTipoEntidad='AREA')
		BEGIN 
			INSERT INTO #Centros 
			SELECT CASE WHEN LEN(CodCentro)<3 THEN REPLICATE('0',3-LEN(CodCentro)) + CONVERT(varchar,CodCentro) ELSE convert(varchar,CodCentro) END 
			FROM Sumarigrama  WHERE CodSubDirNegocioArea = @pCodCentro				
		END

	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	--DELETE FROM dbo.WEB_CarteraDetalladaUsuarioCentro WHERE Usuario like '%' + @Usuario_Sin_Fecha + '%'
	DELETE FROM dbo.WEB_CarteraDetalladaUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'		

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
	CREATE TABLE #vwWEB_OFERTAS_CA_Local  (CodCentro varchar(3),CodOferta varchar(10), FAdjudicacion datetime, Adjudicada char(1), ImporteTotal float, Tipo varchar(10), DesOfer varchar(100), CodCliente varchar(10))
	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_CA_Local (CodCentro,CodOferta, FAdjudicacion, ImporteTotal,Adjudicada,Tipo, DesOfer,CodCliente)
							 SELECT CDCEN AS CodCentro, CDOFT AS CodOferta, 
									CASE WHEN LEN(FECHAD) > 5 
										THEN CONVERT(datetime, RIGHT(FECHAD, 6), 103) 
										ELSE (CASE WHEN FECHAD = ''0'' THEN ''19990101'' ELSE NULL END) 
									END AS FAdjudicacion, 
									TVEN AS ImporteTotal, ADELE AS Adjudicada, WS10 AS Tipo, DCOF AS DesOfer, CDCLI
							'
	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT CDCEN, OFCA.CDOFT,FECHAD,TVEN,ADELE,WS10,DCOF, CDCLI
							 FROM  S44DD901.ICOMERF.IC09AP As OFCA LEFT OUTER JOIN S44DD901.FICOSCO.CO005BP AS Enlaces ON
									OFCA.CDCEN = Enlaces.CTRO AND OFCA.CDOFT = Enlaces.CDOFT
							 WHERE OFCA.BAJA <> ''''B'''' AND 
								((substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 1, 4 ) < ' + str(@pAño) + ') OR 
								 (substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
								) AND
								NOT (OFCA.ADELE <> ''''S'''' AND Enlaces.CDOFT IS NULL)
							'') '

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vwWEB_OFERTAS_CA'

	--PRINT (@SQL_AS400_from)
	EXEC (@SQL_AS400)

	PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	--------------------------------
	-- Paco 20/04/2016 Table temporal de Ofertas dadas de baja para EXCLUIR SIEMPRE las ofertas de baja en relaciones posteriores
	CREATE TABLE #OfertasDeBaja (CodCentro varchar(3),CodOferta varchar(10))
	SET @SQL_AS400_select = 'INSERT INTO #OfertasDeBaja (CodCentro,CodOferta)
							 SELECT CDCEN AS CodCentro, CDOFT AS CodOferta
							'
	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT CDCEN, CDOFT
							 FROM S44DD901.ICOMERF.IC09AP
							 WHERE substr( digits(dec(19000000+FECHAD,8,0)), 1, 4 )>=2009 AND BAJA = ''''B'''' 
							 '')'
	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') OfertasDeBaja'
	--PRINT (@SQL_AS400)
	EXEC (@SQL_AS400)
	
	PRINT 'Time 2º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

---------------------------------------------------------------- hasta AQUÍ
	/* ***************************************************************************************************************** */
	/* ******************************************** CONTRATACION  ****************************************************** */
	/* ***************************************************************************************************************** */

	-- OFERTAS
		CREATE TABLE #vwWEB_OFERTAS_CA (CodCentro varchar(3),CodOferta varchar(10),CodCliente varchar(10),FAdjudicacion datetime,DesOfer varchar(50), ImporteTotal float, Tipo char(10))

		-- Insertamos Ofertas que No son Baja
		INSERT INTO #vwWEB_OFERTAS_CA(CodCentro, CodOferta, CodCliente,FAdjudicacion, DesOfer, ImporteTotal, Tipo) 
		SELECT CodCentro, CodOferta,CodCliente, [dbo].[fnQuitar1999](FAdjudicacion) as FAdjudicacion ,DesOfer,ImporteTotal,Tipo 
		FROM #vwWEB_OFERTAS_CA_Local 
		WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND CodCentro IN (SELECT CodCentro FROM #Centros)

	PRINT 'Time 3º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	-- REGULARIZACIONES Posteriores
		CREATE TABLE #vRegularizaciones (CodCentro varchar(3),CodOferta varchar(10), ImporteRegularizacion float)

		INSERT into #vRegularizaciones(CodCentro,CodOferta,ImporteRegularizacion) 
		SELECT cdcen,cdoft,sum(Impre)
				FROM Regularizaciones
				WHERE (dbo.Regularizaciones.AñoR=@pAño AND
					  dbo.Regularizaciones.MesR>@pMes) 
					  OR
					  (dbo.Regularizaciones.AñoR>@pAño)
		GROUP BY cdcen,cdoft

	PRINT 'Time 4º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	CREATE TABLE #WEB_CarteraUsuarioCentro_TMP (CodCentro char(3),CodOferta varchar(10), CodCliente varchar(10), FAdjudicacion datetime,DesOfer varchar(50),ImporteContratado float,ImporteProd float,ImporteFactura float,ImporteFot float,TipoOferta varchar(1),Tipo int)	
	--CREATE CLUSTERED INDEX ix_WEB_CarteraUsuarioCentro_TMP ON #WEB_CarteraUsuarioCentro_TMP ([CodOferta])

	-- OFERTAS - REGULARIZACIONES Posteriores
	INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,CodCliente,FAdjudicacion,DesOfer,ImporteContratado)	
	SELECT  1,Tipo,[#vwWEB_OFERTAS_CA].CodCentro,[#vwWEB_OFERTAS_CA].CodOferta, CodCliente, FAdjudicacion,DesOfer,isnull(ImporteTotal,0)-isnull(ImporteRegularizacion,0)	
	FROM #vwWEB_OFERTAS_CA LEFT JOIN #vRegularizaciones ON [#vwWEB_OFERTAS_CA].CodOferta=[#vRegularizaciones].CodOferta

	PRINT 'Time 5º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
		
	-- OFERTASsql que no esten marcadas como bajas OfertasBajasSQL
	-- NO son de Reparto: Mismo Importe
		INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,CodCliente,FAdjudicacion,DesOfer,ImporteContratado)	
		SELECT  2,'F',dbo.OfertasSQL.CodCentro,dbo.OfertasSQL.CodOferta,CodCliente,FAdjudicacion,DescripcionOferta,ImporteContratado
		FROM  dbo.OfertasSQL LEFT JOIN dbo.OfertasBajasSQL ON dbo.OfertasSQL.CodCentro=dbo.OfertasBajasSQL.CodCentro AND dbo.OfertasSQL.CodOferta=dbo.OfertasBajasSQL.CodOferta
		WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND dbo.OfertasSQL.CodCentro IN (SELECT CodCentro FROM #Centros) 
			  AND isnull(dbo.OfertasBajasSQL.CodOferta,'')='' AND Reparto=0	

	PRINT 'Time 6º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	-- SI son de Reparto: Suma de los Importes
		INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,CodCliente,FAdjudicacion,DesOfer,ImporteContratado)	
		SELECT  2,'F',dbo.OfertasSQL.CodCentro,dbo.OfertasSQL.CodOferta,CodCliente,Min(FAdjudicacion),DescripcionOferta,sum(ImporteContratado)
		FROM  dbo.OfertasSQL LEFT JOIN dbo.OfertasBajasSQL ON dbo.OfertasSQL.CodCentro=dbo.OfertasBajasSQL.CodCentro AND dbo.OfertasSQL.CodOferta=dbo.OfertasBajasSQL.CodOferta
		WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND dbo.OfertasSQL.CodCentro IN (SELECT CodCentro FROM #Centros) 
			  AND isnull(dbo.OfertasBajasSQL.CodOferta,'')='' AND Reparto=1 
		GROUP BY dbo.OfertasSQL.CodCentro, dbo.OfertasSQL.CodOferta,CodCliente,DescripcionOferta		

	PRINT 'Time 7º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ***************************************************************************************************** */
	/* *********************************************** TOTAL *********************************************** */	
	/* ***************************************************************************************************** */
	
	/* ********************************************* OBRAS VIVAS ********************************************* */
	
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro
           (Usuario, Tipo, CodOferta, DescripcionOferta, FAdjudicacion, ImporteContratado, Obra, ObraL, NombreObra, FApertura, FCierre, ImporteProduccion, ImporteFactura, ImporteFot,Est, CodCliente)
	--SELECT @Usuario,TipoOferta,isnull([#WEB_CarteraUsuarioCentro_TMP].CodOferta,0),DesOfer,
	--	   replace(right(convert(varchar(10),FAdjudicacion,103),7),'/','_'),
	--	   isnull(ImporteContratado,0),Obra,ObraL,isnull(NombreObra,''),isnull(dbo.fnFormatFecha(FechaApertura),''),isnull(dbo.fnFormatFecha(FechaCierre),''),
	--	   isnull(ImporteProduccion,0),isnull(vwTIPOUNO_Produccion_Detallado.ImporteFactura,0),isnull(vwTIPOUNO_Produccion_Detallado.ImporteFot,0), Est,
	--	   CodCliente
	--FROM #WEB_CarteraUsuarioCentro_TMP
	--      LEFT JOIN vwTIPOUNO_Produccion_Detallado ON [#WEB_CarteraUsuarioCentro_TMP].CodOferta=vwTIPOUNO_Produccion_Detallado.CodOferta AND CAST([#WEB_CarteraUsuarioCentro_TMP].CodCentro AS INT)=CAST(vwTIPOUNO_Produccion_Detallado.CodCentro AS INT) 
	--WHERE (Año=@pAño AND Mes=@pMes) OR isnull(Año,0)=0 -- Adjudicadas OR Sin Obra		
	SELECT @Usuario,TipoOferta,isnull([#WEB_CarteraUsuarioCentro_TMP].CodOferta,0),DesOfer,
		   replace(right(convert(varchar(10),FAdjudicacion,103),7),'/','_'),
		   isnull(ImporteContratado,0),Obra,ObraL,isnull(NombreObra,''),
		   
		   CASE WHEN ISNULL(FechaApertura,0)<>0
		   THEN right(LEFT(REPLACE(STR(FechaApertura,4),' ','0'),4),2) +'_'+ left(LEFT(REPLACE(STR(FechaApertura,4),' ','0'),4),2)
		   ELSE ''
		   END FechaAperturaFormat2,
		   CASE WHEN ISNULL(FechaCierre,0)<>0
		   THEN right(LEFT(REPLACE(STR(FechaCierre,4),' ','0'),4),2) +'_'+ left(LEFT(REPLACE(STR(FechaCierre,4),' ','0'),4),2)
		   ELSE ''
		   END FechaCierreFormat2,

		   isnull(ImporteProduccion,0),isnull(vwTIPOUNO_Produccion_Detallado.ImporteFactura,0),isnull(vwTIPOUNO_Produccion_Detallado.ImporteFot,0), Est,
		   CodCliente
	FROM #WEB_CarteraUsuarioCentro_TMP
	      LEFT JOIN vwTIPOUNO_Produccion_Detallado ON [#WEB_CarteraUsuarioCentro_TMP].CodOferta=vwTIPOUNO_Produccion_Detallado.CodOferta AND CAST([#WEB_CarteraUsuarioCentro_TMP].CodCentro AS INT)=CAST(vwTIPOUNO_Produccion_Detallado.CodCentro AS INT) 
	WHERE (Año=@pAño AND Mes=@pMes) OR isnull(Año,0)=0 -- Adjudicadas OR Sin Obra	

	PRINT 'Time 8º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
-------------------------------------
-- Paco 2016-05-05
-- Para incluir producciones del mes de obras de ofertas que tienen fecha de adjudicacion futura
-- Ahora se estaban excluyendo porque solo se consideraban ofertas adjudicadas hasta el mes en cuestion

	INSERT INTO WEB_CarteraDetalladaUsuarioCentro
           (Usuario, Tipo, CodOferta, DescripcionOferta, FAdjudicacion, ImporteContratado, Obra, ObraL, NombreObra, FApertura, FCierre, ImporteProduccion, ImporteFactura, ImporteFot,Est, CodCliente)
	--SELECT @Usuario,C.Tipo,isnull(B.CodOferta,0),C.DesOfer,
	--		CASE WHEN Year(C.FAdjudicacion)>@pAño OR (Year(C.FAdjudicacion)=@pAño AND Month(C.FAdjudicacion)>@pMes)
	--			THEN ''
	--			ELSE replace(right(convert(varchar(10),C.FAdjudicacion,103),7),'/','_') 
	--		END,
	--		isnull(ImporteContratado,0),Obra,ObraL,isnull(NombreObra,''),isnull(dbo.fnFormatFecha(FechaApertura),''),isnull(dbo.fnFormatFecha(FechaCierre),''),
	--		isnull(ImporteProduccion,0),isnull(B.ImporteFactura,0),isnull(B.ImporteFot,0), Est,
	--		A.CodCliente
	--FROM #WEB_CarteraUsuarioCentro_TMP A RIGHT JOIN 
	--	vwTIPOUNO_Produccion_Detallado B on A.CodOferta=B.CodOferta AND CAST(A.CodCentro AS INT)=CAST(B.CodCentro AS INT) INNER JOIN 
	--	#vwWEB_OFERTAS_CA_Local C ON B.CodOferta=C.CodOferta AND B.CodCentro=C.CodCentro
	--WHERE  (Año=@pAño AND Mes=@pMes) and A.CodOferta is null AND B.CodCentro IN (SELECT CodCentro FROM #Centros) 
	SELECT @Usuario,C.Tipo,isnull(B.CodOferta,''),C.DesOfer,
			CASE WHEN Year(C.FAdjudicacion)>@pAño OR (Year(C.FAdjudicacion)=@pAño AND Month(C.FAdjudicacion)>@pMes)
				THEN ''
				ELSE replace(right(convert(varchar(10),C.FAdjudicacion,103),7),'/','_') 
			END,
			isnull(ImporteContratado,0),Obra,ObraL,isnull(NombreObra,''),

		   CASE WHEN ISNULL(FechaApertura,0)<>0
		   THEN right(LEFT(REPLACE(STR(FechaApertura,4),' ','0'),4),2) +'_'+ left(LEFT(REPLACE(STR(FechaApertura,4),' ','0'),4),2)
		   ELSE ''
		   END FechaAperturaFormat2,
		   CASE WHEN ISNULL(FechaCierre,0)<>0
		   THEN right(LEFT(REPLACE(STR(FechaCierre,4),' ','0'),4),2) +'_'+ left(LEFT(REPLACE(STR(FechaCierre,4),' ','0'),4),2)
		   ELSE ''
		   END FechaCierreFormat2,

			isnull(ImporteProduccion,0),isnull(B.ImporteFactura,0),isnull(B.ImporteFot,0), Est,
			A.CodCliente
	FROM #WEB_CarteraUsuarioCentro_TMP A RIGHT JOIN 
		vwTIPOUNO_Produccion_Detallado B on A.CodOferta=B.CodOferta AND CAST(A.CodCentro AS INT)=CAST(B.CodCentro AS INT) INNER JOIN 
		#vwWEB_OFERTAS_CA_Local C ON B.CodOferta=C.CodOferta AND B.CodCentro=C.CodCentro
	WHERE  (Año=@pAño AND Mes=@pMes) and A.CodOferta is null AND B.CodCentro IN (SELECT CodCentro FROM #Centros) 


	PRINT 'Time 9º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	--TIPO1
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est, CodCliente)
	--SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,dbo.fnFormatFecha(FechaApertura),dbo.fnFormatFecha(FechaCierre),ImporteProduccion,ImporteFactura,ImporteFot,Est, CodCliente
	--FROM [dbo].[vwTIPOUNO_ProduccionElecnor_Detallado]
	--WHERE Año=@pAño AND Mes=@pMes AND CodCentro IN (SELECT CodCentro FROM #Centros)
	SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,
	
		   CASE WHEN ISNULL(FechaApertura,0)<>0
		   THEN right(LEFT(REPLACE(STR(FechaApertura,4),' ','0'),4),2) +'_'+ left(LEFT(REPLACE(STR(FechaApertura,4),' ','0'),4),2)
		   ELSE ''
		   END FechaAperturaFormat2,
		   CASE WHEN ISNULL(FechaCierre,0)<>0
		   THEN right(LEFT(REPLACE(STR(FechaCierre,4),' ','0'),4),2) +'_'+ left(LEFT(REPLACE(STR(FechaCierre,4),' ','0'),4),2)
		   ELSE ''
		   END FechaCierreFormat2,
	
	ImporteProduccion,ImporteFactura,ImporteFot,Est, CodCliente
	FROM [dbo].[vwTIPOUNO_ProduccionElecnor_Detallado]
	WHERE Año=@pAño AND Mes=@pMes AND CodCentro IN (SELECT CodCentro FROM #Centros)

	PRINT 'Time 10º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ********************************************* OBRAS HISTORICO ********************************************* */	
	-- Actualizamos las Vivas ya que existen siempre pero con importes a cero, si no, no estaria en historico.

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

	PRINT 'Time 11º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

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

	PRINT 'Time 12º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
-------------------------------- Hasta AQUI

	/* ********************************************* OBRAS OTRAS ********************************************* */
	-- No tendran Codigo de Obra(la mayoria) y pueden ser de todos los Tipos	, No esta enlazado con Ofertas <--> Obra
	-- En el este caso insertamos las ofertas que anteriormente se a indicado produccion y actualizamos ofertas que no tengan produccion
	
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est, Codcliente)
	SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente
	FROM WEB_CarteraDetalladaUsuarioCentro INNER JOIN ObrasOtrasSQL ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros) AND
		  WEB_CarteraDetalladaUsuarioCentro.Tipo=ObrasOtrasSQL.TipoOferta AND isnull(WEB_CarteraDetalladaUsuarioCentro.NombreObra,'')<>''
	GROUP BY TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente

	PRINT 'Time 13º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	--------------------------------------------------------------------------------
	-- Paco 22/02/2016
	-- Paco 20/04/2016 Incluído relacion con table temporal de Ofertas dadas de baja para EXCLUIR SIEMPRE las ofertas de baja

	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est,CodCliente)
	SELECT @Usuario,TipoOferta,CDOFT CodOferta,Isnull(DescripcionOferta,''),IsNull(FAdjudicacion,''),IsNull(ImporteContratado,0),TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente
	FROM WEB_CarteraDetalladaUsuarioCentro RIGHT JOIN ObrasOtrasSQL ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
		 LEFT JOIN #OfertasDeBaja OB ON ObrasOtrasSQL.CDOFT = OB.CodOferta
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario IS NULL AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros)
			AND OB.CodOferta is null
	GROUP BY TipoOferta,CDOFT,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente
	
	PRINT 'Time 14º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

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

	PRINT 'Time 15º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ****************************************** CONTRATOS MARCO ********************************************* */
	
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ContratoMarco= vwCart_DiferidaOfertasContratosSQL.Tipo
	FROM dbo.WEB_CarteraDetalladaUsuarioCentro INNER JOIN
         dbo.vwCart_DiferidaOfertasContratosSQL ON dbo.WEB_CarteraDetalladaUsuarioCentro.CodOferta = dbo.vwCart_DiferidaOfertasContratosSQL.CodOferta
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario

	PRINT 'Time 16º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ****************************************** Nombre Clientes ********************************************* */
	
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET NombreCliente=isnull(Clientes.NAUX,'')
	FROM dbo.WEB_CarteraDetalladaUsuarioCentro INNER JOIN
         Clientes ON dbo.WEB_CarteraDetalladaUsuarioCentro.CodCliente =Clientes.AUX
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario

	PRINT 'Time 17º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ****************************************** ImporteCarteraAgrupacion ********************************************* */
	
	--UPDATE WEB_CarteraDetalladaUsuarioCentro
	--SET ImporteCarteraAgrupacion=dbo.fnImporteCartera_CarteraDetallada (@Usuario,Tipo)	
	--WHERE Usuario= @Usuario

	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ImporteCarteraAgrupacion=ISNULL(vCDU.ImporteCartera, 0)
	FROM WEB_CarteraDetalladaUsuarioCentro WUC LEFT JOIN [vwCarteraDetalladaUsuarioCentro_ImporteCartera] vCDU ON WUC.Usuario=vCDU.Usuario AND WUC.Tipo=vCDU.Tipo
	WHERE WUC.Usuario= @Usuario	
	
	PRINT 'Time 18º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

    /* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha	

	PRINT 'Time 19º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH		
		return ERROR_NUMBER ()
	END CATCH
	
END
