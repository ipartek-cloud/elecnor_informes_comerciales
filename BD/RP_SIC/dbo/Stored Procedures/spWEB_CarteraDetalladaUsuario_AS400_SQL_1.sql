
CREATE PROCEDURE [dbo].[spWEB_CarteraDetalladaUsuario_AS400_SQL]
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
	DECLARE @PoSIC_TESTion as int
	
	SET @PoSIC_TESTion=CHARINDEX('_',@Usuario)-1
	IF  @PoSIC_TESTion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@PoSIC_TESTion)
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
	CREATE NONCLUSTERED INDEX [#vwWEB_OFERTAS_CA_Local_CodCentro_CodOferta] ON #vwWEB_OFERTAS_CA_Local (CodCentro, CodOferta) INCLUDE (Tipo)	


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
								--((substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 1, 4 ) < ' + str(@pAño) + ') OR 
								-- (substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+OFCA.FECHAD,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
								--) AND
								NOT (OFCA.ADELE <> ''''S'''' AND Enlaces.CDOFT IS NULL) AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 )>=2005
							ORDER BY CDCEN, OFCA.CDOFT, WS10
							'') '
-- Paco 30/06/2020 Comentado el filtro de fechas para que saque oferta no adjudicadas en la fecha de la solicitud pero con obras enlazadas que sí tienen produccion (la caartera sale negativa porque la adjuducacion a la fecha es 0)

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
	--	CREATE TABLE #vRegularizaciones (CodCentro varchar(3),CodOferta varchar(10), ImporteRegularizacion float)

	--	INSERT into #vRegularizaciones(CodCentro,CodOferta,ImporteRegularizacion) 
	--	SELECT cdcen,cdoft,sum(Impre)
	--			FROM Regularizaciones
	--			WHERE (dbo.Regularizaciones.AñoR=@pAño AND
	--				  dbo.Regularizaciones.MesR>@pMes) 
	--				  OR
	--				  (dbo.Regularizaciones.AñoR>@pAño)
	--	GROUP BY cdcen,cdoft

	--PRINT 'Time 4º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	CREATE TABLE #WEB_CarteraUsuarioCentro_TMP (CodCentro char(3),CodOferta varchar(10), CodCliente varchar(10), FAdjudicacion datetime,DesOfer varchar(50),ImporteContratado float,ImporteProd float,ImporteFactura float,ImporteFot float,TipoOferta varchar(1),Tipo int)	
	--CREATE CLUSTERED INDEX ix_WEB_CarteraUsuarioCentro_TMP ON #WEB_CarteraUsuarioCentro_TMP ([CodOferta])

	-- OFERTAS - REGULARIZACIONES Posteriores
	INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,CodCliente,FAdjudicacion,DesOfer,ImporteContratado)	
	SELECT  1,Tipo,[#vwWEB_OFERTAS_CA].CodCentro,[#vwWEB_OFERTAS_CA].CodOferta, CodCliente, FAdjudicacion,DesOfer,isnull(ImporteTotal,0)-isnull(ImporteRegularizacion,0)	
	FROM #vwWEB_OFERTAS_CA LEFT JOIN (

			SELECT cdcen AS CodCentro,cdoft AS CodOferta,sum(Impre) AS ImporteRegularizacion
			FROM IC10AP
			WHERE ((AR=@pAño AND MR>@pMes) OR (AR>@pAño)) AND Usuario=@Usuario
			GROUP BY cdcen,cdoft
	
	
	) REG ON [#vwWEB_OFERTAS_CA].CodOferta=REG.CodOferta

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
	SELECT @Usuario,TipoOferta,isnull([#WEB_CarteraUsuarioCentro_TMP].CodOferta,''),DesOfer,
		   replace(right(convert(varchar(10),FAdjudicacion,103),7),'/','_'),
		   isnull(ImporteContratado,0),Obra,ObraL,isnull(NombreObra,''),isnull(dbo.fnFormatFecha(FechaApertura),''),isnull(dbo.fnFormatFecha(FechaCierre),''),
		   isnull(ImporteProduccion,0),isnull(vwTIPOUNO_Produccion_Detallado.ImporteFactura,0),isnull(vwTIPOUNO_Produccion_Detallado.ImporteFot,0), Est,
		   CodCliente
	FROM #WEB_CarteraUsuarioCentro_TMP
	      LEFT JOIN (

					SELECT   ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO_Detallado.CTRO AS CodCentro, vwTipoUNO_Detallado.CDOFT AS CodOferta, 
							  ObrasActualesSQL.OBRA, ObrasActualesSQL.OBRAL, 
							  vwTipoUNO_Detallado.OBRA + '-' + vwTipoUNO_Detallado.OBRAL + ' ' + ObrasActualesSQL.DSOBR AS NombreObra, SUM(ObrasActualesSQL.SOP) AS ImporteProduccion,
							  SUM(ObrasActualesSQL.SOF) AS ImporteFactura, SUM(ObrasActualesSQL.SOL) AS ImporteFot, ObrasActualesSQL.STOBR AS Est, vwTipoUNO_Detallado.FECHAAPERTURA, vwTipoUNO_Detallado.FECHACIERRE
					FROM (
							SELECT   CTRO, CDOFT, OBRA, OBRAL, FECHAAPERTURA, FECHACIERRE 
							from CO005BP 
							WHERE Usuario=@Usuario 
								--AND CDOFT <> 1
								AND CDOFT NOT IN ('0000000001','0000000002') -- Paco 01/12/2021 para incluir las obras Tipo 2 en el tratamiento de las obras Tipo 1
					) vwTipoUNO_Detallado INNER JOIN ObrasActualesSQL ON vwTipoUNO_Detallado.CTRO = ObrasActualesSQL.CTR AND 
					  vwTipoUNO_Detallado.OBRA = ObrasActualesSQL.OBRA AND vwTipoUNO_Detallado.OBRAL = ObrasActualesSQL.OBRAL
					GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO_Detallado.CTRO, vwTipoUNO_Detallado.OBRA, vwTipoUNO_Detallado.OBRAL, 
							 ObrasActualesSQL.DSOBR, ObrasActualesSQL.STOBR, vwTipoUNO_Detallado.CDOFT, vwTipoUNO_Detallado.FECHAAPERTURA, 
							 vwTipoUNO_Detallado.FECHACIERRE, ObrasActualesSQL.OBRA, ObrasActualesSQL.OBRAL
		  
		  ) vwTIPOUNO_Produccion_Detallado ON [#WEB_CarteraUsuarioCentro_TMP].CodOferta=vwTIPOUNO_Produccion_Detallado.CodOferta AND [#WEB_CarteraUsuarioCentro_TMP].CodCentro=vwTIPOUNO_Produccion_Detallado.CodCentro
	WHERE (Año=@pAño AND Mes=@pMes) OR isnull(Año,0)=0 -- Adjudicadas OR Sin Obra	

	PRINT 'Time 8º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
-------------------------------------
-- Paco 2016-05-05
-- Para incluir producciones del mes de obras de ofertas que tienen fecha de adjudicacion futura
-- Ahora se estaban excluyendo porque solo se consideraban ofertas adjudicadas hasta el mes en cuestion

	INSERT INTO WEB_CarteraDetalladaUsuarioCentro
           (Usuario, Tipo, CodOferta, DescripcionOferta, FAdjudicacion, ImporteContratado, Obra, ObraL, NombreObra, FApertura, FCierre, ImporteProduccion, ImporteFactura, ImporteFot,Est, CodCliente)
	SELECT @Usuario,C.Tipo,isnull(B.CodOferta,''),C.DesOfer,
			CASE WHEN Year(C.FAdjudicacion)>@pAño OR (Year(C.FAdjudicacion)=@pAño AND Month(C.FAdjudicacion)>@pMes)
				THEN ''
				ELSE replace(right(convert(varchar(10),C.FAdjudicacion,103),7),'/','_') 
			END,
			isnull(ImporteContratado,0),Obra,ObraL,isnull(NombreObra,''),isnull(dbo.fnFormatFecha(FechaApertura),''),isnull(dbo.fnFormatFecha(FechaCierre),''),
			isnull(ImporteProduccion,0),isnull(B.ImporteFactura,0),isnull(B.ImporteFot,0), Est,
			A.CodCliente
	FROM #WEB_CarteraUsuarioCentro_TMP A RIGHT JOIN (
	
					SELECT   ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO_Detallado.CTRO AS CodCentro, vwTipoUNO_Detallado.CDOFT AS CodOferta, 
							  ObrasActualesSQL.OBRA, ObrasActualesSQL.OBRAL, 
							  vwTipoUNO_Detallado.OBRA + '-' + vwTipoUNO_Detallado.OBRAL + ' ' + ObrasActualesSQL.DSOBR AS NombreObra, SUM(ObrasActualesSQL.SOP) AS ImporteProduccion,
							  SUM(ObrasActualesSQL.SOF) AS ImporteFactura, SUM(ObrasActualesSQL.SOL) AS ImporteFot, ObrasActualesSQL.STOBR AS Est, vwTipoUNO_Detallado.FECHAAPERTURA, vwTipoUNO_Detallado.FECHACIERRE
					FROM (
							SELECT   CTRO, CDOFT, OBRA, OBRAL, FECHAAPERTURA, FECHACIERRE 
							from CO005BP 
							WHERE Usuario=@Usuario 
								--AND CDOFT <> 1
								AND CDOFT NOT IN ('0000000001','0000000002') -- Paco 01/12/2021 para incluir las obras Tipo 2 en el tratamiento de las obras Tipo 1
					) vwTipoUNO_Detallado INNER JOIN ObrasActualesSQL ON vwTipoUNO_Detallado.CTRO = ObrasActualesSQL.CTR AND 
					  vwTipoUNO_Detallado.OBRA = ObrasActualesSQL.OBRA AND vwTipoUNO_Detallado.OBRAL = ObrasActualesSQL.OBRAL
					GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO_Detallado.CTRO, vwTipoUNO_Detallado.OBRA, vwTipoUNO_Detallado.OBRAL, 
							 ObrasActualesSQL.DSOBR, ObrasActualesSQL.STOBR, vwTipoUNO_Detallado.CDOFT, vwTipoUNO_Detallado.FECHAAPERTURA, 
							 vwTipoUNO_Detallado.FECHACIERRE, ObrasActualesSQL.OBRA, ObrasActualesSQL.OBRAL
	
	) B on A.CodOferta=B.CodOferta AND A.CodCentro =B.CodCentro INNER JOIN 
		#vwWEB_OFERTAS_CA_Local C ON B.CodOferta=C.CodOferta AND B.CodCentro=C.CodCentro
	WHERE  (Año=@pAño AND Mes=@pMes) and A.CodOferta is null AND B.CodCentro IN (SELECT CodCentro FROM #Centros) 		

	PRINT 'Time 9º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	--TIPO1
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est, CodCliente)
	SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,dbo.fnFormatFecha(FechaApertura),dbo.fnFormatFecha(FechaCierre),ImporteProduccion,ImporteFactura,ImporteFot,Est, CodCliente
	FROM (
	
			SELECT ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO.CTRO AS CodCentro, 'E' AS TipoOferta, CDOFT AS CodOferta, 0 AS ContratoMarco, '' AS DescripcionOferta, '-' AS FAdjudicacion, 0 AS ImporteContratado, 
				   vwTipoUNO.OBRA + '-' + vwTipoUNO.OBRAL + ' ' + ObrasActualesSQL.DSOBR AS NombreObra, SUM(ObrasActualesSQL.SOP) AS ImporteProduccion, ObrasActualesSQL.SOF AS ImporteFactura, ObrasActualesSQL.SOL AS ImporteFot, ObrasActualesSQL.STOBR AS Est, 
				   vwTipoUNO.FechaApertura, vwTipoUNO.FechaCierre, ObrasActualesSQL.CDCLI AS CodCliente
			FROM ( 
					SELECT   CTRO, CDOFT, OBRA, OBRAL, FECHAAPERTURA, FECHACIERRE 
					from CO005BP 
					WHERE Usuario=@Usuario 
						--AND CDOFT = 1
						AND CDOFT IN ('0000000001','0000000002') -- Paco 01/12/2021 para incluir las obras Tipo 2 en el tratamiento de las obras Tipo 1
					) vwTipoUNO INNER JOIN ObrasActualesSQL ON vwTipoUNO.CTRO = ObrasActualesSQL.CTR AND vwTipoUNO.OBRA = ObrasActualesSQL.OBRA AND vwTipoUNO.OBRAL = ObrasActualesSQL.OBRAL
			GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO.CTRO, vwTipoUNO.OBRA, vwTipoUNO.OBRAL, ObrasActualesSQL.DSOBR, 
					 ObrasActualesSQL.STOBR, vwTipoUNO.FechaApertura, vwTipoUNO.FechaCierre, ObrasActualesSQL.SOL, ObrasActualesSQL.SOF, ObrasActualesSQL.CDCLI	
					, CDOFT
	) vw
	WHERE Año=@pAño AND Mes=@pMes AND CodCentro IN (SELECT CodCentro FROM #Centros)

	PRINT 'Time 10º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ********************************************* OBRAS HISTORICO ********************************************* */	
	-- Actualizamos las Vivas ya que existen siempre pero con importes a cero, si no, no estaria en historico.
	CREATE TABLE #WEB_CarteraDetalladaUsuarioCentro  (CodOferta varchar(10), Obra varchar(100), ObraL varchar(100), CodCentro varchar(3)
														, ImporteProduccion float, ImporteFactura float, ImporteFot float
														, FApertura varchar(10), FCierre varchar(5))
	
	--CREATE TABLE #Enlaces (CodCentro varchar(3), CodObra varchar(100), CodOferta varchar(10))	
	--SET @SQL_AS400_select = 'INSERT INTO #Enlaces (CodCentro, CodObra, CodOferta)
	--						 SELECT CTRO AS CodCentro, OBRA CodObra, CDOFT AS CodOferta
	--						'
	--SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
	--													''SELECT DISTINCT CTRO, OBRA, CDOFT
	--													 FROM S44DD901.FICOSCO.CO005BP AS Enlaces 
	--												 '')'
	--SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') Enlaces'
	--EXEC (@SQL_AS400)
	

	INSERT INTO #WEB_CarteraDetalladaUsuarioCentro
	SELECT WEB_CarteraDetalladaUsuarioCentro.CodOferta, 
			WEB_CarteraDetalladaUsuarioCentro.Obra, 
			WEB_CarteraDetalladaUsuarioCentro.ObraL,
			vwProduccion_Detallado_Historico.CodCentro,
			vwProduccion_Detallado_Historico.ImporteProduccion,
			vwProduccion_Detallado_Historico.ImporteFactura,
			vwProduccion_Detallado_Historico.ImporteFot,
			vwProduccion_Detallado_Historico.FApertura,
			vwProduccion_Detallado_Historico.FCierre
	--INTO #WEB_CarteraDetalladaUsuarioCentro
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
	FROM WEB_CarteraDetalladaUsuarioCentro 
		INNER JOIN (
					SELECT id, RIGHT('0000000000' + IdOferta, 10) CDOFT, CentroCRM CTR, IdCentro+IdObra OBRA, '' OBRAL, Obra DSOBR, 
							RIGHT('00'+CAST(MONTH(FechaApertura) as varchar(2)), 2) + '_' + RIGHT(CAST(YEAR(FechaApertura) AS varchar(4)), 2) FAPERTURA,
							RIGHT('00'+CAST(MONTH(FechaCierre) as varchar(2)), 2) + '_' + RIGHT(CAST(YEAR(FechaCierre) AS varchar(4)), 2) FCIERRE,
							ProduccionOrigen SOP, FacturacionOrigen SOF, FOTOrigen SOL, Tipo TipoOferta
					-- , * 
					FROM ObrasFilialesSQL
					WHERE (Año=@pAño AND Mes=@pMes)
		) ObrasOtrasSQL ON WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros) AND
		  WEB_CarteraDetalladaUsuarioCentro.Tipo=ObrasOtrasSQL.TipoOferta 
-----------------------------
-- Paco 18/01/2024
--		  AND isnull(WEB_CarteraDetalladaUsuarioCentro.NombreObra,'')<>''
		  AND isnull(ObrasOtrasSQL.DSOBR,'')<>''
-----------------------------
	GROUP BY TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente

	PRINT 'Time 13º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	--------------------------------------------------------------------------------
	-- Paco 22/02/2016
	-- Paco 20/04/2016 Incluído relacion con table temporal de Ofertas dadas de baja para EXCLUIR SIEMPRE las ofertas de baja

	--INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est,CodCliente)
	--SELECT @Usuario,TipoOferta,CDOFT CodOferta,Isnull(DescripcionOferta,''),IsNull(FAdjudicacion,''),IsNull(ImporteContratado,0),TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente
	--FROM WEB_CarteraDetalladaUsuarioCentro RIGHT JOIN ObrasOtrasSQL ON
	--	 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	--	 LEFT JOIN #OfertasDeBaja OB ON ObrasOtrasSQL.CDOFT = OB.CodOferta
	--WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario IS NULL AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros)
	--		AND OB.CodOferta is null
	--GROUP BY TipoOferta,CDOFT,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente
	
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est,CodCliente)
	SELECT @Usuario,TipoOferta,CDOFT CodOferta,Isnull(DescripcionOferta,''),IsNull(FAdjudicacion,''),IsNull(ImporteContratado,0),TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente
	FROM (SELECT * FROM WEB_CarteraDetalladaUsuarioCentro WHere Usuario=@Usuario AND CodOferta NOT IN ('1','2')) WEB_CarteraDetalladaUsuarioCentro 
			RIGHT JOIN (
						SELECT id, RIGHT('0000000000' + IdOferta, 10) CDOFT, CentroCRM CTR, IdCentro+IdObra OBRA, '' OBRAL, Obra DSOBR, 
								RIGHT('00'+CAST(MONTH(FechaApertura) as varchar(2)), 2) + '_' + RIGHT(CAST(YEAR(FechaApertura) AS varchar(4)), 2) FAPERTURA,
								RIGHT('00'+CAST(MONTH(FechaCierre) as varchar(2)), 2) + '_' + RIGHT(CAST(YEAR(FechaCierre) AS varchar(4)), 2) FCIERRE,
								ProduccionOrigen SOP, FacturacionOrigen SOF, FOTOrigen SOL, Tipo TipoOferta
						-- , * 
						FROM ObrasFilialesSQL
						WHERE (Año=@pAño AND Mes=@pMes)
			) ObrasOtrasSQL ON WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
			LEFT JOIN #OfertasDeBaja OB ON ObrasOtrasSQL.CDOFT = OB.CodOferta
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario IS NULL 
			AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros)
			AND OB.CodOferta is null
	GROUP BY TipoOferta,CDOFT,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est,CodCliente
	
	PRINT 'Time 14º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	--------------------------------------------------------------------------------
	-- Paco 13/12/2022. desde aquí
	-- Para que aparezca la descripcion de ls ofertas ejecutadas por la filial y que aún no han sido adjudicadas
	-- en Area 3 CT 757, en noviembre la oferta 2275700003 que no estaba adjudicada no mostraba su descipción, cuando existía en la tabla ObrasOtrasSQL
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET DescripcionOferta = Isnull(DSOBR,'')
	--SELECT @Usuario,TipoOferta,CDOFT CodOferta,
	--	Isnull(DSOBR,''),
	--	IsNull(FAdjudicacion,'')
	FROM (SELECT * FROM WEB_CarteraDetalladaUsuarioCentro WHere Usuario=@Usuario) WEB_CarteraDetalladaUsuarioCentro 
		INNER JOIN (
					SELECT id, RIGHT('0000000000' + IdOferta, 10) CDOFT, CentroCRM CTR, IdCentro+IdObra OBRA, '' OBRAL, Obra DSOBR, 
							RIGHT('00'+CAST(MONTH(FechaApertura) as varchar(2)), 2) + '_' + RIGHT(CAST(YEAR(FechaApertura) AS varchar(4)), 2) FAPERTURA,
							RIGHT('00'+CAST(MONTH(FechaCierre) as varchar(2)), 2) + '_' + RIGHT(CAST(YEAR(FechaCierre) AS varchar(4)), 2) FCIERRE,
							ProduccionOrigen SOP, FacturacionOrigen SOF, FOTOrigen SOL, Tipo TipoOferta
					-- , * 
					FROM ObrasFilialesSQL
		) ObrasOtrasSQL ON WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	WHERE ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros)
		AND TipoOferta='F' AND IsNull(FAdjudicacion,'')=''
		AND CodOferta NOT IN ('0000000001','0000000002')
	-- Paco 13/12/2022. hasta aquí
	--------------------------------------------------------------------------------
-----------------------------
-- Paco 18/01/2024. desde aqui
	DELETE 
	--select CodOferta 
	FROM  WEB_CarteraDetalladaUsuarioCentro 
	WHERE CodOferta IN (
						SELECT CodOferta 
						FROM WEB_CarteraDetalladaUsuarioCentro 
						WHERE  isnull(NombreObra,'')<>'' and Usuario=@Usuario
						) 
			AND isnull(NombreObra,'')='' and Usuario=@Usuario
	--order by CodOferta
-- Paco 18/01/2024. hasta aqui
-----------------------------

	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ImporteProduccion=SOP,
	    ImporteFactura=SOF,
		ImporteFot=SOL,
		NombreObra= TipoOferta+[dbo].[fnObra](TipoOferta,ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  + DSOBR,
		FApertura=replace(ObrasOtrasSQL.FApertura,'/','_'),
		FCierre=replace(ObrasOtrasSQL.FCierre,'/','_')
	FROM WEB_CarteraDetalladaUsuarioCentro 
			INNER JOIN (
						SELECT id, RIGHT('0000000000' + IdOferta, 10) CDOFT, CentroCRM CTR, IdCentro+IdObra OBRA, '' OBRAL, Obra DSOBR, 
								RIGHT('00'+CAST(MONTH(FechaApertura) as varchar(2)), 2) + '_' + RIGHT(CAST(YEAR(FechaApertura) AS varchar(4)), 2) FAPERTURA,
								RIGHT('00'+CAST(MONTH(FechaCierre) as varchar(2)), 2) + '_' + RIGHT(CAST(YEAR(FechaCierre) AS varchar(4)), 2) FCIERRE,
								ProduccionOrigen SOP, FacturacionOrigen SOF, FOTOrigen SOL, Tipo TipoOferta
						-- , * 
						FROM ObrasFilialesSQL
						WHERE (Año=@pAño AND Mes=@pMes)
			) ObrasOtrasSQL ON WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND ObrasOtrasSQL.CTR IN (SELECT CodCentro FROM #Centros) AND
		  WEB_CarteraDetalladaUsuarioCentro.Tipo=ObrasOtrasSQL.TipoOferta AND isnull(WEB_CarteraDetalladaUsuarioCentro.NombreObra,'')=''

	PRINT 'Time 15º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ****************************************** CONTRATOS MARCO ********************************************* */
	
-------------------------------------------------------------
-- Paco 2022-05-04
-- Se marca como contrato marco T (Trimestral) porque según Angelm, en esa tabla (ContratosMarcoenCRM) sólo están los contratos trimestrales
-- esto afecta al Informe Cartera Pendiente Ejecutar
 
	--UPDATE WEB_CarteraDetalladaUsuarioCentro
	--SET ContratoMarco= vwCart_DiferidaOfertasContratosSQL.Tipo
	--FROM dbo.WEB_CarteraDetalladaUsuarioCentro INNER JOIN
 --        dbo.vwCart_DiferidaOfertasContratosSQL ON dbo.WEB_CarteraDetalladaUsuarioCentro.CodOferta = dbo.vwCart_DiferidaOfertasContratosSQL.CodOferta
	--WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario

	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ContratoMarco= 'T'
	FROM dbo.WEB_CarteraDetalladaUsuarioCentro CDUC INNER JOIN
         ContratosMarcoenCRM CMCRM ON CDUC.CodOferta = CMCRM.CodOferta
	WHERE CDUC.Usuario= @Usuario
-- Fin Paco 2022-05-04
-------------------------------------------------------------

	PRINT 'Time 16º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ****************************************** Nombre Clientes ********************************************* */
	
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET NombreCliente=isnull(C.NAUX,'')
	FROM dbo.WEB_CarteraDetalladaUsuarioCentro INNER JOIN (	
		--SELECT AUX, NAUX FROM OPENQUERY(SIC, 'SELECT AUX, NAUX FROM S44DD901.FICOS.CGA06AP AS Clientes WHERE CIA = ''001'' AND CNAUX = ''C''')	
		SELECT * FROM Clientes_Aux_NAux
	) C ON dbo.WEB_CarteraDetalladaUsuarioCentro.CodCliente =C.AUX
	--WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario

	PRINT 'Time 17º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ****************************************** ImporteCarteraAgrupacion ********************************************* */
	
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ImporteCarteraAgrupacion=dbo.fnImporteCartera_CarteraDetallada (@Usuario,Tipo)	
	WHERE Usuario= @Usuario

	PRINT 'Time 18º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

    /* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha	


	PRINT 'Time 19º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH		
		 --SELECT 
   --     ERROR_NUMBER() AS ErrorNumber,
   --     ERROR_MESSAGE() AS ErrorMessage,
   --     ERROR_SEVERITY() AS ErrorSeverity,
   --     ERROR_STATE() AS ErrorState,
   --     ERROR_PROCEDURE() AS ErrorProcedure,
   --     ERROR_LINE() AS ErrorLine;
        
   -- -- Si necesitas devolver algo específico
   -- RETURN -1; -- o el código que necesites
		RETURN ERROR_NUMBER()
	END CATCH
	
END