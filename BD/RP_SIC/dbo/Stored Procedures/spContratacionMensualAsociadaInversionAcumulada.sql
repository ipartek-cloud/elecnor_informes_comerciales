CREATE PROCEDURE [dbo].[spContratacionMensualAsociadaInversionAcumulada] 	
	@pMercado varchar(50),
	@pAño int,
	@pMes int
	AS
BEGIN
	/*
---------------------------------------------------------------- desde AQUÍ
	*/
	DECLARE @SQL_AS400_select as varchar(max)
	DECLARE @SQL_AS400_from as varchar(max)
	DECLARE @SQL_AS400 as varchar(max)

	CREATE TABLE #vwRegularizaciones_Local  (CodCentro varchar(3),CodOferta varchar(10), NumRegularizacion numeric (3,0), FAlta datetime, DescripcionOferta varchar (100), 
											CodCliente varchar(10), Localidad varchar(100), CodProv varchar(2), ImporteAprox float, FPresentacion datetime, PresupuestoVenta float, 
											FAdjudicacion datetime, AñoAdjudicacion numeric(4,0), MesAdjudicacion numeric(2,0), Adjudicada varchar(1), ImporteContratado float, Pais varchar(100))

	SET @SQL_AS400_select = 'INSERT INTO #vwRegularizaciones_Local (CodCentro, CodOferta, NumRegularizacion, FAlta, DescripcionOferta, CodCliente, Localidad,
																	CodProv, ImporteAprox, FPresentacion, PresupuestoVenta, 
																	FAdjudicacion, AñoAdjudicacion, MesAdjudicacion, Adjudicada, ImporteContratado, Pais)
							SELECT vReg.CDCEN AS CodCentro, vReg.CDOFT AS CodOferta, ISNULL(vReg.NUMRE, 0) AS NumRegularizacion, dbo.fgConvertirFechaDMY(vReg.FECHAA) AS FAlta, 
									vReg.DCOF AS DescripcionOferta, vReg.CDCLI AS CodCliente, vReg.LOCAL AS Localidad, vReg.PROOF AS CodProv, vReg.IMAOF AS ImporteAprox, 
									 dbo.fgConvertirFechaDMY(vReg.FECHPP) AS FPresentacion, vReg.PREVE AS PresupuestoVenta, dbo.fgConvertirFechaDMY(vReg.FECHAR) AS FAdjudicacion, 
									 YEAR(dbo.fgConvertirFechaDMY(vReg.FECHAR)) AS AñoAdjudicacion, MONTH(dbo.fgConvertirFechaDMY(vReg.FECHAR)) AS MesAdjudicacion, 
									 vReg.ADELE AS Adjudicada, vReg.IMPRE AS ImporteContratado, dbo.fnPais(vReg.CDAUT) AS Pais
							'
	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, ''
										SELECT REG.CDCEN, REG.CDOFT, REG.NUMRE, OFE.FECHAA, OFE.DCOF, OFE.CDCLI, OFE.LOCAL, OFE.PROOF, OFE.IMAOF,
												OFE.FECHPP, OFE.PREVE, REG.FECHAR, 
												substr( digits(dec(19000000+REG.FECHAR,8,0)), 1, 4 ) AA, 
												substr( digits(dec(19000000+REG.FECHAR,8,0)), 5, 2 ) MM, 
												substr( digits(dec(19000000+REG.FECHAR,8,0)), 7, 2 ) DD
												,OFE.ADELE, REG.IMPRE, AUT.CDAUT 
										FROM S44DD901.ICOMERF.IC09AP OFE INNER JOIN S44DD901.ICOMERF.IC10AP REG ON OFE.CDOFT = REG.CDOFT
											INNER JOIN S44DD901.ICOMERF.IC05AP PRO ON PRO.CDPRO = OFE.PROOF 
												INNER JOIN S44DD901.ICOMERF.IC11AP AUT ON PRO.CDAUT = AUT.CDAUT
										WHERE (substr( digits(dec(19000000+REG.FECHAR,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+REG.FECHAR,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
									'')'

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vReg '

	--PRINT (@SQL_AS400)
	EXEC (@SQL_AS400)
	
---------------------------------------------------------------- hasta AQUÍ

	set nocount on 

	DECLARE @ContratacionMensual float	
	
	DECLARE @ContratacionMensual_Ofertas as float
	DECLARE @ContratacionMensual_Regularizaciones as float
	DECLARE @ContratacionMensual_OfertasSQL as float
	
	-- Variable de Tabla vwOfertasAI
	DECLARE @vwOfertasAI TABLE ([CDCEN] [char](3) NOT NULL,[CDOFT] varchar(10) NOT NULL,[FECHAA] [numeric](7, 0) NOT NULL,[DCOF] [char](50) NOT NULL,[CDCLI] [char](8) NOT NULL,[LOCAL] [char](30) NOT NULL,[PROOF] [char](2) NOT NULL,[IMAOF] [numeric](9, 0) NOT NULL,
								[CDAC1] [char](2) NOT NULL,[CDAC2] [char](2) NOT NULL,[DECOF] [char](2) NOT NULL,[RPROF] [char](3) NOT NULL,[FECHPP] [numeric](7, 0) NOT NULL,[PREVE] [numeric](9, 0) NOT NULL,[FECHAD] [numeric](7, 0) NOT NULL,[ADELE] [char](1) NOT NULL,[PREAD] [numeric](9, 0) NOT NULL,[TCOS] [numeric](9, 0) NOT NULL,[TVEN] [numeric](9, 0) NOT NULL,[USER] [char](10) NOT NULL,[WS10] [char](10) NOT NULL,[DESPRO] [char](30) NOT NULL,[BAJA] [char](1) NOT NULL)
								
	INSERT INTO	@vwOfertasAI ([CDCEN],[CDOFT],[FECHAA],[DCOF],[CDCLI],[LOCAL],[PROOF],[IMAOF],[CDAC1],[CDAC2],[DECOF],[RPROF],[FECHPP],[PREVE],[FECHAD],[ADELE],[PREAD],[TCOS],[TVEN],[USER],[WS10],[DESPRO],[BAJA])							
	SELECT [CDCEN],[CDOFT],[FECHAA],[DCOF],[CDCLI],[LOCAL],[PROOF],[IMAOF],[CDAC1],[CDAC2],[DECOF],[RPROF],[FECHPP],[PREVE],[FECHAD],[ADELE],[PREAD],[TCOS],[TVEN],[USER],[WS10],[DESPRO],[BAJA]
	FROM dbo.[vwOfertasAI]

	SELECT @ContratacionMensual_Ofertas=sum(isnull(vwOfertasAsociadasInversion.ImporteContratado,0)) 
	FROM	(SELECT v.CDCEN AS CodCentro, v.CDOFT AS CodOferta, 0 AS NumRegularizacion, dbo.fgConvertirFechaDMY(v.FECHAA) AS FAlta, v.DCOF AS DescripcionOferta, v.CDCLI AS CodCliente, 
				 v.LOCAL AS Localidad, v.PROOF AS CodProv, v.IMAOF AS ImporteAprox,v.CDAC1 AS CodAct1, v.CDAC2 AS CodAct2, v.RPROF AS CodResponsable, 
				 dbo.fgConvertirFechaDMY(v.FECHPP) AS FPresentacion, v.PREVE AS PresupuestoVenta,dbo.fgConvertirFechaDMY(v.FECHAD) AS FAdjudicacion, 
				 YEAR(dbo.fgConvertirFechaDMY(v.FECHAD))AS AñoAdjudicacion, MONTH(dbo.fgConvertirFechaDMY(v.FECHAD)) AS MesAdjudicacion, v.ADELE AS Adjudicada, v.PREAD AS ImporteContratado, dbo.Provincias.Pais
			FROM  @vwOfertasAI as v  INNER JOIN dbo.Provincias ON v.PROOF = dbo.Provincias.CDPRO
			WHERE  Provincias.Pais=@pMercado AND YEAR(dbo.fgConvertirFechaDMY(v.FECHAD))=@pAño AND MONTH(dbo.fgConvertirFechaDMY(v.FECHAD)) <= @pMes AND v.ADELE='S') 
			AS vwOfertasAsociadasInversion INNER JOIN dbo.Sumarigrama ON dbo.Sumarigrama.CodCentro = vwOfertasAsociadasInversion.CodCentro
		
	-- REGULARIZACIONES
	SELECT  @ContratacionMensual_Regularizaciones=sum(isnull(vwRegularizacionesQ.ImporteContratado,0))
	FROM         (	
					SELECT    CodCentro, CodOferta, NumRegularizacion, dbo.fgConvertirFechaDMY(v.FECHAA) AS FAlta, DescripcionOferta, 
							  v.CDCLI AS CodCliente, v.LOCAL AS Localidad, v.PROOF AS CodProv, v.IMAOF AS ImporteAprox, v.CDAC1 AS CodAct1, v.CDAC2 AS CodAct2, v.RPROF AS CodResponsable, 
							  dbo.fgConvertirFechaDMY(v.FECHPP) AS FPresentacion, v.PREVE AS PresupuestoVenta, FAdjudicacion, AñoAdjudicacion,
							  MesAdjudicacion, v.ADELE AS Adjudicada, ImporteContratado, dbo.Provincias.Pais
					FROM  @vwOfertasAI as v INNER JOIN
								  #vwRegularizaciones_Local Regularizaciones ON v.CDOFT = Regularizaciones.CodOferta INNER JOIN
								  dbo.Provincias ON v.PROOF = dbo.Provincias.CDPRO                      
					WHERE  Provincias.Pais=@pMercado AND AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes AND v.ADELE='S'		
	) AS vwRegularizacionesQ INNER JOIN dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro							 

	-- OFERTASsql
	SELECT @ContratacionMensual_OfertasSQL=sum(isnull(ImporteContratado,0))    
	FROM  dbo.OfertasSQL INNER JOIN
          dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
          dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta = dbo.OfertaAsociadaInversion.JVAYNB
	WHERE Pais=@pMercado AND AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes 
	
	SET @ContratacionMensual=(isnull(@ContratacionMensual_Ofertas,0) + isnull(@ContratacionMensual_Regularizaciones,0)+ isnull(@ContratacionMensual_OfertasSQL,0))
	
	SELECT isnull(@ContratacionMensual,0) as ContratacionMensualAcumulada

END