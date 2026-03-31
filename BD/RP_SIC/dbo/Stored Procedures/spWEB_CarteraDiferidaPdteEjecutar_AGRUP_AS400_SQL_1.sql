CREATE PROCEDURE [dbo].[spWEB_CarteraDiferidaPdteEjecutar_AGRUP_AS400_SQL]
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

  --  IF UPPER(@Usuario_Sin_Fecha)='ELUQUE' -- Para depuración
		--BEGIN
		--	UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
		--	SET Usuario=@Usuario			
		--	WHERE Usuario like 'eluque%'

		--	RETURN 0
		--END

	SELECT @Usuario_Puesto=Puesto, @Usuario_CodEntidad=CodEntidad FROM dbo.WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha	
	IF isnull(@Usuario_Puesto,'')='' RETURN -99999

	CREATE TABLE #CarteraDiferida(
		[CodDirGeneral] [int] NOT NULL,
		[NombreDirGeneral] [nvarchar](100) NOT NULL,
		[CodSubDirGeneral] [int] NOT NULL,
		[NombreSubDirGeneral] [nvarchar](100) NOT NULL,
		[CodDDirNegocio] [decimal](3, 0) NOT NULL,
		[NombreDirNegocio] [nvarchar](30) NOT NULL,
		[CodSubDirNegocioArea] [int] NOT NULL,
		[NombreSubDirNegocioArea] [nvarchar](100) NOT NULL,
		[CodDelegacion] [decimal](3, 0) NOT NULL,
		[NombreDelegacion] [nvarchar](30) NOT NULL,
		[CodCentro] [decimal](3, 0) NOT NULL,
		[NombreCentro] [nvarchar](30) NOT NULL,
		[Contrato] [varchar](255) NULL,
		[Cliente] [varchar](255) NULL,
		[Gerencia] [varchar](100) NULL,
		[AGRUP] [varchar](100) NULL,
		[FInicio] [datetime] NULL,
		[FFinal] [datetime] NULL,
		[FFinalEfectiva] [datetime] NULL,
		[CodOferta] [numeric](10, 0) NOT NULL,
		[Tipo] [varchar](1) NULL,
		[Mercado] [varchar](1) NULL,
		[CartInicio] [int] NULL,
		[NTrimestres] [int] NULL,
		[MontoTrimestre] [int] NULL,
		[MontoAnual] [int] NULL,
		[PrevistoAño] [int] NULL,
		[Nuevo] [int] NULL,
		[Contrat] [float] NOT NULL,
		[TrimSQL] [float] NOT NULL,
		[Regu] [float] NOT NULL,
		[A2019] [float] NULL,
		[A2020] [int] NULL,
		[A2021] [int] NULL,
		[Prorrogable] [varchar](50) NULL
		)
		CREATE CLUSTERED INDEX ix_CarteraDiferida_CodOferta ON #CarteraDiferida ([CodOferta]);

		CREATE TABLE #RestoOfertas(
		[CodCentro] [decimal](3, 0) NOT NULL,
		[Cliente] [varchar](255) NULL,
		[Gerencia] [varchar](100) NULL,
		[CodOferta] [numeric](10, 0) NOT NULL
		)
		--CREATE CLUSTERED INDEX ix_RestoOfertas_CodOferta ON #RestoOfertas ([CodOferta]);

		CREATE TABLE #Cart_DiferidaContratosSQL (
			ID int,
			Contrato varchar(255),
			Cliente varchar(255)  NULL,
			CodigoContratoClient varchar(255) ,
			Gerencia varchar(100) ,
			Prorrogable varchar(50) ,
			Tipo varchar(1) ,
			Mercado varchar(1),
			FInicio datetime,
			FFinal datetime,
			FFinalEfectiva datetime,
			Zona varchar(250)
		 )
		 --CREATE CLUSTERED INDEX ix_Cart_DiferidaContratosSQL ON #Cart_DiferidaContratosSQL (ID);
		
		DECLARE @NumGerencias int
		SELECT @NumGerencias=isnull(COUNT(Usuario),0) FROM [dbo].[WEB_UsuariosGerencias] WHERE Usuario=@Usuario

	    IF @NumGerencias=0 -- Si no Tiene Gerencias puede ver Todas
			BEGIN
				INSERT INTO #Cart_DiferidaContratosSQL([ID],[Contrato],[Cliente],[CodigoContratoClient],[Gerencia],[Prorrogable],[Tipo],[Mercado],[FInicio],[FFinal],[FFinalEfectiva],[Zona]) 
				SELECT [ID],[Contrato],[Cliente],isnull([CodigoContratoClient],''),[Gerencia],isnull([Prorrogable],''),[Tipo],[Mercado],[FInicio],[FFinal],[FFinalEfectiva],isnull([Zona],'')
				FROM [dbo].[Cart_DiferidaContratosSQL]
				WHERE Vigente=1 and Tipo<>'C' -- Solo 'T' o 'A'
			END
		ELSE	-- solamante las Indicadas
			BEGIN
				INSERT INTO #Cart_DiferidaContratosSQL([ID],[Contrato],[Cliente],[CodigoContratoClient],[Gerencia],[Prorrogable],[Tipo],[Mercado],[FInicio],[FFinal],[FFinalEfectiva],[Zona]) 
				SELECT [ID],[Contrato],[Cliente],isnull([CodigoContratoClient],''),[Gerencia],isnull([Prorrogable],''),[Tipo],[Mercado],[FInicio],[FFinal],[FFinalEfectiva],isnull([Zona],'')
				FROM [dbo].[Cart_DiferidaContratosSQL]
				WHERE Vigente=1 AND Gerencia IN(SELECT Gerencia FROM [dbo].[WEB_UsuariosGerencias] WHERE Usuario=@Usuario ) and Tipo<>'C'
			END	
			
	/*                                                           PASO de 2018 a 2019 a 2020                                                                          */		
    /* dbo.fnContratacionAcumulada_SQL_AS400_2018(@pMes) --> vwContratacion_SQL_AS400_2018 --> ( dbo.vwContratacion_AS400_2018 , dbo.vwContratacion_SQL_20189) */				
	/* dbo.fnContratacionAcumulada_SQL_AS400_2019(@pMes) --> vwContratacion_SQL_AS400_2019 --> ( dbo.vwContratacion_AS400_2019 , dbo.vwContratacion_SQL_2019) */
	/* dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes) --> vwContratacion_SQL_AS400_2020 --> ( dbo.vwContratacion_AS400_2020 , dbo.vwContratacion_SQL_2020) */
	
	/* vwContratacionOfertas_SQL_AS400_2018	--> vwContratacionOfertas_AS400_2018 + vwContratacionOfertas_SQL_2018 */			
	/* vwContratacionOfertas_SQL_AS400_2019	--> vwContratacionOfertas_AS400_2019 + vwContratacionOfertas_SQL_2019 */			
	/* vwContratacionOfertas_SQL_AS400_2020	--> vwContratacionOfertas_AS400_2020 + vwContratacionOfertas_SQL_2020 */			


	IF (@Usuario_Puesto='DG')
		BEGIN	
		    -- CONTRATOS MARCO	
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaOfertasContratos_2016SQL.NomAgrupado, dbo.CentrosGerentesSQL.NombreGerente AS Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro INNER JOIN
                       dbo.CentrosGerentesSQL ON dbo.Sumarigrama.CodCentro = dbo.CentrosGerentesSQL.CodCentro  AND dbo.Sumarigrama.Año = dbo.CentrosGerentesSQL.Año LEFT OUTER JOIN
					   (
					        --SELECT CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
							SELECT CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CODOFER
					   
					   ) AS vwContratacion_SQL_AS400_2020 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			WHERE CodDirGeneral = @Usuario_CodEntidad and Vigente=1
			
			PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- CONTRATOS MARCO --> ('Contratos Nacionales' que no estan en CentrosGerentesSQL)	(Duplicamos los que estan en Instalaciones I, Instalaciones II, etc)
			--INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			--SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDir_2020Negocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente, Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			--ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			--dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			--FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
			--		   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
			--		   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
			--		   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro  LEFT OUTER JOIN
			--		   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
			--			FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)) AS vwContratacion_SQL_AS400_2020 ON 
			--			dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
			--			(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			--WHERE CodDirGeneral = @Usuario_CodEntidad AND Cart_DiferidaContratosSQL.Gerencia = 'Contratos Nacionales' and Vigente=1		
		
			--PRINT 'Time 1.0º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- RESTO (Facturacion-Produccion --> ObrasActualesSQL-Enlaces)
			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT DISTINCT dbo.CentrosGerentesSQL.NombreGerente, dbo.ClientesSQL.NomAgrupado, dbo.ObrasActualesSQL.CTR, vwEnlaces_Detallado.CDOFT
			FROM  dbo.ObrasActualesSQL INNER JOIN
				 (				 
				 	 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario
					 UNION
					 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BPH WHERE Usuario=@Usuario and añocierre=18
				 
				 ) as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  --vwEnlaces_ALL as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  dbo.ObrasActualesSQL.OBRA = vwEnlaces_Detallado.OBRA AND dbo.ObrasActualesSQL.OBRAL = vwEnlaces_Detallado.OBRAL INNER JOIN
				  dbo.CentrosGerentesSQL ON dbo.ObrasActualesSQL.CTR = dbo.CentrosGerentesSQL.CodCentro AND dbo.ObrasActualesSQL.Año = dbo.CentrosGerentesSQL.Año  INNER JOIN
				  dbo.ClientesSQL ON dbo.ObrasActualesSQL.CDCLI = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
				  #CarteraDiferida ON vwEnlaces_Detallado.CDOFT = #CarteraDiferida.CodOferta
			WHERE dbo.ObrasActualesSQL.Año = @pAño AND dbo.ObrasActualesSQL.Mes = @pMes AND #CarteraDiferida.CodOferta IS NULL

			PRINT 'Time 1.1º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
			
			-- RESTO (Contratacion --> OfertasSQL + AS400)
			--INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			--SELECT dbo.CentrosGerentesSQL.NombreGerente, dbo.ClientesSQL.NomAgrupado, dbo.vwContratacionOfertas_SQL_AS400_2020.CodCentro, dbo.vwContratacionOfertas_SQL_AS400_2020.CODOFER
			--FROM   dbo.vwContratacionOfertas_SQL_AS400_2020 INNER JOIN
   --                dbo.CentrosGerentesSQL ON dbo.vwContratacionOfertas_SQL_AS400_2020.CodCentro = dbo.CentrosGerentesSQL.CodCentro INNER JOIN
   --                dbo.ClientesSQL ON dbo.vwContratacionOfertas_SQL_AS400_2020.CODCLIENTE = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
			--	   #RestoOfertas ON dbo.vwContratacionOfertas_SQL_AS400_2020.CODOFER = #RestoOfertas.CodOferta
			--WHERE  #RestoOfertas.CodOferta IS NULL			

			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT CentrosGerentesSQL.NombreGerente, ClientesSQL.NomAgrupado, vwContratacionOfertas_SQL_AS400_2020.CodCentro, vwContratacionOfertas_SQL_AS400_2020.CODOFER
			FROM  (
			
			  SELECT DISTINCT CT as CodCentro, CODOFER, CODCLIENTE FROM OFERREGU WHERE AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@Usuario
			  UNION ALL
			  SELECT DISTINCT CodCentro, CodOferta as CODOFER, CodCliente FROM dbo.OfertasSQL WHERE AñoAdjudicacion = @pAño
			
			) vwContratacionOfertas_SQL_AS400_2020 INNER JOIN
                   CentrosGerentesSQL ON vwContratacionOfertas_SQL_AS400_2020.CodCentro = CentrosGerentesSQL.CodCentro AND CentrosGerentesSQL.CodCentro = 2020 INNER JOIN
                   ClientesSQL ON vwContratacionOfertas_SQL_AS400_2020.CODCLIENTE = ClientesSQL.CodCliente LEFT OUTER JOIN
				   #RestoOfertas ON vwContratacionOfertas_SQL_AS400_2020.CODOFER = #RestoOfertas.CodOferta
			WHERE  #RestoOfertas.CodOferta IS NULL	
			
			PRINT 'Time 1.2º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
			
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Resto', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro,
			        '' as Contrato, #RestoOfertas.Cliente, #RestoOfertas.Gerencia, '' as FInicio, '' as FFinal, '' as FFinalEfectiva, #RestoOfertas.CodOferta,'X' as Tipo, '' as Mercado, 0 as CartInicio, 0 as NTrimestres, 0 as MontoTrimestre, 0 as MontoAnual, 0 AS PrevistoAño, 0 AS Nuevo,
					ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat,ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
					0  AS A2019,0 AS A2020, 0 AS A2021, '' as Prorrogable
			FROM    #RestoOfertas INNER JOIN
					dbo.Sumarigrama ON #RestoOfertas.CodCentro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					(
					  ---SELECT CodCentro, CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
					  SELECT CT as CodCentro, CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CT,CODOFER
					  
					) AS vwContratacion_SQL_AS400_2020
					ON #RestoOfertas.CodCentro = vwContratacion_SQL_AS400_2020.CodCentro AND #RestoOfertas.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
					(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado
					ON #RestoOfertas.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta		
			WHERE CodDirGeneral = @Usuario_CodEntidad AND [#RestoOfertas].CodOferta NOT IN (SELECT CodOferta FROM #CarteraDiferida)		

			PRINT 'Time 1.3º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

		END
	ELSE IF (@Usuario_Puesto='SDG')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2019_Mayo & vwCarteraDiferidaAnual_2019_Mayo
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaOfertasContratos_2016SQL.NomAgrupado, dbo.CentrosGerentesSQL.NombreGerente AS Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro INNER JOIN
                       dbo.CentrosGerentesSQL ON dbo.Sumarigrama.CodCentro = dbo.CentrosGerentesSQL.CodCentro  AND dbo.Sumarigrama.Año = dbo.CentrosGerentesSQL.Año LEFT OUTER JOIN
					   (
					        --SELECT CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
							SELECT CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CODOFER
					   
					   ) AS vwContratacion_SQL_AS400_2020 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			WHERE CodSubDirGeneral = @Usuario_CodEntidad and Vigente=1			
						
			PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- CONTRATOS MARCO --> ('Contratos Nacionales' que no estan en CentrosGerentesSQL)	(Duplicamos los que estan en Instalaciones I, Instalaciones II, etc)
			--INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			--SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente, Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			--ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			--dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			--FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
			--		   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
			--		   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
			--		   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro  LEFT OUTER JOIN
			--		   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
			--			FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)) AS vwContratacion_SQL_AS400_2020 ON 
			--			dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
			--			(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			--WHERE CodDirGeneral = @Usuario_CodEntidad AND Cart_DiferidaContratosSQL.Gerencia = 'Contratos Nacionales' and Vigente=1		
		
			--PRINT 'Time 1.0º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- RESTO (Facturacion-Produccion --> ObrasActualesSQL-Enlaces)
			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT DISTINCT dbo.CentrosGerentesSQL.NombreGerente, dbo.ClientesSQL.NomAgrupado, dbo.ObrasActualesSQL.CTR, vwEnlaces_Detallado.CDOFT
			FROM  dbo.ObrasActualesSQL INNER JOIN
				 (				 
				 	 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario
					 UNION
					 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BPH WHERE Usuario=@Usuario and añocierre=18
				 
				 ) as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  --vwEnlaces_ALL as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  dbo.ObrasActualesSQL.OBRA = vwEnlaces_Detallado.OBRA AND dbo.ObrasActualesSQL.OBRAL = vwEnlaces_Detallado.OBRAL INNER JOIN
				  dbo.CentrosGerentesSQL ON dbo.ObrasActualesSQL.CTR = dbo.CentrosGerentesSQL.CodCentro AND dbo.ObrasActualesSQL.Año = dbo.CentrosGerentesSQL.Año  INNER JOIN
				  dbo.ClientesSQL ON dbo.ObrasActualesSQL.CDCLI = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
				  #CarteraDiferida ON vwEnlaces_Detallado.CDOFT = #CarteraDiferida.CodOferta
			WHERE dbo.ObrasActualesSQL.Año = @pAño AND dbo.ObrasActualesSQL.Mes = @pMes AND #CarteraDiferida.CodOferta IS NULL

			PRINT 'Time 1.1º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT CentrosGerentesSQL.NombreGerente, ClientesSQL.NomAgrupado, vwContratacionOfertas_SQL_AS400_2020.CodCentro, vwContratacionOfertas_SQL_AS400_2020.CODOFER
			FROM  (
			
			  SELECT DISTINCT CT as CodCentro, CODOFER, CODCLIENTE FROM OFERREGU WHERE AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@Usuario
			  UNION ALL
			  SELECT DISTINCT CodCentro, CodOferta as CODOFER, CodCliente FROM dbo.OfertasSQL WHERE AñoAdjudicacion = @pAño
			
			) vwContratacionOfertas_SQL_AS400_2020 INNER JOIN
                   CentrosGerentesSQL ON vwContratacionOfertas_SQL_AS400_2020.CodCentro = CentrosGerentesSQL.CodCentro AND CentrosGerentesSQL.CodCentro = 2020 INNER JOIN
                   ClientesSQL ON vwContratacionOfertas_SQL_AS400_2020.CODCLIENTE = ClientesSQL.CodCliente LEFT OUTER JOIN
				   #RestoOfertas ON vwContratacionOfertas_SQL_AS400_2020.CODOFER = #RestoOfertas.CodOferta
			WHERE  #RestoOfertas.CodOferta IS NULL	
			
			PRINT 'Time 1.2º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
			
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Resto', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro,
			        '' as Contrato, #RestoOfertas.Cliente, #RestoOfertas.Gerencia, '' as FInicio, '' as FFinal, '' as FFinalEfectiva, #RestoOfertas.CodOferta,'X' as Tipo, '' as Mercado, 0 as CartInicio, 0 as NTrimestres, 0 as MontoTrimestre, 0 as MontoAnual, 0 AS PrevistoAño, 0 AS Nuevo,
					ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat,ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
					0  AS A2019,0 AS A2020, 0 AS A2021, '' as Prorrogable
			FROM    #RestoOfertas INNER JOIN
					dbo.Sumarigrama ON #RestoOfertas.CodCentro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					(
					  ---SELECT CodCentro, CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
					  SELECT CT as CodCentro, CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CT,CODOFER
					  
					) AS vwContratacion_SQL_AS400_2020
					ON #RestoOfertas.CodCentro = vwContratacion_SQL_AS400_2020.CodCentro AND #RestoOfertas.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
					(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado
					ON #RestoOfertas.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta		
			WHERE CodSubDirGeneral = @Usuario_CodEntidad AND [#RestoOfertas].CodOferta NOT IN (SELECT CodOferta FROM #CarteraDiferida)

		END
	ELSE IF (@Usuario_Puesto='DN')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2019_Mayo & vwCarteraDiferidaAnual_2019_Mayo
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaOfertasContratos_2016SQL.NomAgrupado, dbo.CentrosGerentesSQL.NombreGerente AS Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro INNER JOIN
                       dbo.CentrosGerentesSQL ON dbo.Sumarigrama.CodCentro = dbo.CentrosGerentesSQL.CodCentro  AND dbo.Sumarigrama.Año = dbo.CentrosGerentesSQL.Año LEFT OUTER JOIN
					   (
					        --SELECT CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
							SELECT CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CODOFER
					   
					   ) AS vwContratacion_SQL_AS400_2020 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			WHERE CodDDirNegocio = @Usuario_CodEntidad and Vigente=1			
			PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- CONTRATOS MARCO --> ('Contratos Nacionales' que no estan en CentrosGerentesSQL)	(Duplicamos los que estan en Instalaciones I, Instalaciones II, etc)
			--INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			--SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente, Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			--ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			--dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			--FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
			--		   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
			--		   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
			--		   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro  LEFT OUTER JOIN
			--		   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
			--			FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)) AS vwContratacion_SQL_AS400_2020 ON 
			--			dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
			--			(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			--WHERE CodDirGeneral = @Usuario_CodEntidad AND Cart_DiferidaContratosSQL.Gerencia = 'Contratos Nacionales' and Vigente=1		
		
			--PRINT 'Time 1.0º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- RESTO (Facturacion-Produccion --> ObrasActualesSQL-Enlaces)
			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT DISTINCT dbo.CentrosGerentesSQL.NombreGerente, dbo.ClientesSQL.NomAgrupado, dbo.ObrasActualesSQL.CTR, vwEnlaces_Detallado.CDOFT
			FROM  dbo.ObrasActualesSQL INNER JOIN
				 (				 
				 	 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario
					 UNION
					 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BPH WHERE Usuario=@Usuario and añocierre=18
				 
				 ) as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  --vwEnlaces_ALL as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  dbo.ObrasActualesSQL.OBRA = vwEnlaces_Detallado.OBRA AND dbo.ObrasActualesSQL.OBRAL = vwEnlaces_Detallado.OBRAL INNER JOIN
				  dbo.CentrosGerentesSQL ON dbo.ObrasActualesSQL.CTR = dbo.CentrosGerentesSQL.CodCentro AND dbo.ObrasActualesSQL.Año = dbo.CentrosGerentesSQL.Año  INNER JOIN
				  dbo.ClientesSQL ON dbo.ObrasActualesSQL.CDCLI = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
				  #CarteraDiferida ON vwEnlaces_Detallado.CDOFT = #CarteraDiferida.CodOferta
			WHERE dbo.ObrasActualesSQL.Año = @pAño AND dbo.ObrasActualesSQL.Mes = @pMes AND #CarteraDiferida.CodOferta IS NULL

			PRINT 'Time 1.1º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'			

			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT CentrosGerentesSQL.NombreGerente, ClientesSQL.NomAgrupado, vwContratacionOfertas_SQL_AS400_2020.CodCentro, vwContratacionOfertas_SQL_AS400_2020.CODOFER
			FROM  (
			
			  SELECT DISTINCT CT as CodCentro, CODOFER, CODCLIENTE FROM OFERREGU WHERE AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@Usuario
			  UNION ALL
			  SELECT DISTINCT CodCentro, CodOferta as CODOFER, CodCliente FROM dbo.OfertasSQL WHERE AñoAdjudicacion = @pAño
			
			) vwContratacionOfertas_SQL_AS400_2020 INNER JOIN
                   CentrosGerentesSQL ON vwContratacionOfertas_SQL_AS400_2020.CodCentro = CentrosGerentesSQL.CodCentro AND CentrosGerentesSQL.CodCentro = 2020 INNER JOIN
                   ClientesSQL ON vwContratacionOfertas_SQL_AS400_2020.CODCLIENTE = ClientesSQL.CodCliente LEFT OUTER JOIN
				   #RestoOfertas ON vwContratacionOfertas_SQL_AS400_2020.CODOFER = #RestoOfertas.CodOferta
			WHERE  #RestoOfertas.CodOferta IS NULL	
			
			PRINT 'Time 1.2º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
			
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Resto', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro,
			        '' as Contrato, #RestoOfertas.Cliente, #RestoOfertas.Gerencia, '' as FInicio, '' as FFinal, '' as FFinalEfectiva, #RestoOfertas.CodOferta,'X' as Tipo, '' as Mercado, 0 as CartInicio, 0 as NTrimestres, 0 as MontoTrimestre, 0 as MontoAnual, 0 AS PrevistoAño, 0 AS Nuevo,
					ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat,ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
					0  AS A2019,0 AS A2020, 0 AS A2021, '' as Prorrogable
			FROM    #RestoOfertas INNER JOIN
					dbo.Sumarigrama ON #RestoOfertas.CodCentro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					(
					  ---SELECT CodCentro, CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
					  SELECT CT as CodCentro, CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CT,CODOFER
					  
					) AS vwContratacion_SQL_AS400_2020
					ON #RestoOfertas.CodCentro = vwContratacion_SQL_AS400_2020.CodCentro AND #RestoOfertas.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
					(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado
					ON #RestoOfertas.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta	
			WHERE CodDDirNegocio = @Usuario_CodEntidad AND [#RestoOfertas].CodOferta NOT IN (SELECT CodOferta FROM #CarteraDiferida)

		END
	ELSE IF (@Usuario_Puesto='AREA')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2019_Mayo & vwCarteraDiferidaAnual_2019_Mayo
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaOfertasContratos_2016SQL.NomAgrupado, dbo.CentrosGerentesSQL.NombreGerente AS Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro INNER JOIN
                       dbo.CentrosGerentesSQL ON dbo.Sumarigrama.CodCentro = dbo.CentrosGerentesSQL.CodCentro  AND dbo.Sumarigrama.Año = dbo.CentrosGerentesSQL.Año LEFT OUTER JOIN
					   (
					        --SELECT CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
							SELECT CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CODOFER
					   
					   ) AS vwContratacion_SQL_AS400_2020 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			WHERE CodSubDirNegocioArea = @Usuario_CodEntidad and Vigente=1
						
			PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- CONTRATOS MARCO --> ('Contratos Nacionales' que no estan en CentrosGerentesSQL)	(Duplicamos los que estan en Instalaciones I, Instalaciones II, etc)
			--INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			--SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente, Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			--ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			--dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			--FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
			--		   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
			--		   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
			--		   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro  LEFT OUTER JOIN
			--		   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
			--			FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)) AS vwContratacion_SQL_AS400_2020 ON 
			--			dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
			--			(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			--WHERE CodDirGeneral = @Usuario_CodEntidad AND Cart_DiferidaContratosSQL.Gerencia = 'Contratos Nacionales' and Vigente=1		
		
			--PRINT 'Time 1.0º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- RESTO (Facturacion-Produccion --> ObrasActualesSQL-Enlaces)
			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT DISTINCT dbo.CentrosGerentesSQL.NombreGerente, dbo.ClientesSQL.NomAgrupado, dbo.ObrasActualesSQL.CTR, vwEnlaces_Detallado.CDOFT
			FROM  dbo.ObrasActualesSQL INNER JOIN
				 (				 
				 	 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario
					 UNION
					 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BPH WHERE Usuario=@Usuario and añocierre=18
				 
				 ) as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  --vwEnlaces_ALL as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  dbo.ObrasActualesSQL.OBRA = vwEnlaces_Detallado.OBRA AND dbo.ObrasActualesSQL.OBRAL = vwEnlaces_Detallado.OBRAL INNER JOIN
				  dbo.CentrosGerentesSQL ON dbo.ObrasActualesSQL.CTR = dbo.CentrosGerentesSQL.CodCentro AND dbo.ObrasActualesSQL.Año = dbo.CentrosGerentesSQL.Año  INNER JOIN
				  dbo.ClientesSQL ON dbo.ObrasActualesSQL.CDCLI = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
				  #CarteraDiferida ON vwEnlaces_Detallado.CDOFT = #CarteraDiferida.CodOferta
			WHERE dbo.ObrasActualesSQL.Año = @pAño AND dbo.ObrasActualesSQL.Mes = @pMes AND #CarteraDiferida.CodOferta IS NULL

			PRINT 'Time 1.1º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT CentrosGerentesSQL.NombreGerente, ClientesSQL.NomAgrupado, vwContratacionOfertas_SQL_AS400_2020.CodCentro, vwContratacionOfertas_SQL_AS400_2020.CODOFER
			FROM  (
			
			  SELECT DISTINCT CT as CodCentro, CODOFER, CODCLIENTE FROM OFERREGU WHERE AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@Usuario
			  UNION ALL
			  SELECT DISTINCT CodCentro, CodOferta as CODOFER, CodCliente FROM dbo.OfertasSQL WHERE AñoAdjudicacion = @pAño
			
			) vwContratacionOfertas_SQL_AS400_2020 INNER JOIN
                   CentrosGerentesSQL ON vwContratacionOfertas_SQL_AS400_2020.CodCentro = CentrosGerentesSQL.CodCentro AND CentrosGerentesSQL.CodCentro = 2020 INNER JOIN
                   ClientesSQL ON vwContratacionOfertas_SQL_AS400_2020.CODCLIENTE = ClientesSQL.CodCliente LEFT OUTER JOIN
				   #RestoOfertas ON vwContratacionOfertas_SQL_AS400_2020.CODOFER = #RestoOfertas.CodOferta
			WHERE  #RestoOfertas.CodOferta IS NULL	
			
			PRINT 'Time 1.2º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
			
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Resto', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro,
			        '' as Contrato, #RestoOfertas.Cliente, #RestoOfertas.Gerencia, '' as FInicio, '' as FFinal, '' as FFinalEfectiva, #RestoOfertas.CodOferta,'X' as Tipo, '' as Mercado, 0 as CartInicio, 0 as NTrimestres, 0 as MontoTrimestre, 0 as MontoAnual, 0 AS PrevistoAño, 0 AS Nuevo,
					ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat,ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
					0  AS A2019,0 AS A2020, 0 AS A2021, '' as Prorrogable
			FROM    #RestoOfertas INNER JOIN
					dbo.Sumarigrama ON #RestoOfertas.CodCentro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					(
					  ---SELECT CodCentro, CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
					  SELECT CT as CodCentro, CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CT,CODOFER
					  
					) AS vwContratacion_SQL_AS400_2020
					ON #RestoOfertas.CodCentro = vwContratacion_SQL_AS400_2020.CodCentro AND #RestoOfertas.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
					(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado
					ON #RestoOfertas.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta	
			WHERE CodSubDirNegocioArea = @Usuario_CodEntidad AND [#RestoOfertas].CodOferta NOT IN (SELECT CodOferta FROM #CarteraDiferida)

		END
	ELSE IF (@Usuario_Puesto='DEL')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2019_Mayo & vwCarteraDiferidaAnual_2019_Mayo
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaOfertasContratos_2016SQL.NomAgrupado, dbo.CentrosGerentesSQL.NombreGerente AS Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro INNER JOIN
                       dbo.CentrosGerentesSQL ON dbo.Sumarigrama.CodCentro = dbo.CentrosGerentesSQL.CodCentro  AND dbo.Sumarigrama.Año = dbo.CentrosGerentesSQL.Año LEFT OUTER JOIN
					   (
					        --SELECT CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
							SELECT CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CODOFER
					   
					   ) AS vwContratacion_SQL_AS400_2020 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			WHERE CodDelegacion = @Usuario_CodEntidad and Vigente=1
			
			PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- CONTRATOS MARCO --> ('Contratos Nacionales' que no estan en CentrosGerentesSQL)	(Duplicamos los que estan en Instalaciones I, Instalaciones II, etc)
			--INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			--SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente, Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			--ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			--dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			--FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
			--		   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
			--		   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
			--		   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro  LEFT OUTER JOIN
			--		   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
			--			FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)) AS vwContratacion_SQL_AS400_2020 ON 
			--			dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
			--			(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			--WHERE CodDirGeneral = @Usuario_CodEntidad AND Cart_DiferidaContratosSQL.Gerencia = 'Contratos Nacionales' and Vigente=1		
		
			--PRINT 'Time 1.0º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- RESTO (Facturacion-Produccion --> ObrasActualesSQL-Enlaces)
			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT DISTINCT dbo.CentrosGerentesSQL.NombreGerente, dbo.ClientesSQL.NomAgrupado, dbo.ObrasActualesSQL.CTR, vwEnlaces_Detallado.CDOFT
			FROM  dbo.ObrasActualesSQL INNER JOIN
				 (				 
				 	 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario
					 UNION
					 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BPH WHERE Usuario=@Usuario and añocierre=18
				 
				 ) as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  --vwEnlaces_ALL as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  dbo.ObrasActualesSQL.OBRA = vwEnlaces_Detallado.OBRA AND dbo.ObrasActualesSQL.OBRAL = vwEnlaces_Detallado.OBRAL INNER JOIN
				  dbo.CentrosGerentesSQL ON dbo.ObrasActualesSQL.CTR = dbo.CentrosGerentesSQL.CodCentro AND dbo.ObrasActualesSQL.Año = dbo.CentrosGerentesSQL.Año  INNER JOIN
				  dbo.ClientesSQL ON dbo.ObrasActualesSQL.CDCLI = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
				  #CarteraDiferida ON vwEnlaces_Detallado.CDOFT = #CarteraDiferida.CodOferta
			WHERE dbo.ObrasActualesSQL.Año = @pAño AND dbo.ObrasActualesSQL.Mes = @pMes AND #CarteraDiferida.CodOferta IS NULL

			PRINT 'Time 1.1º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT CentrosGerentesSQL.NombreGerente, ClientesSQL.NomAgrupado, vwContratacionOfertas_SQL_AS400_2020.CodCentro, vwContratacionOfertas_SQL_AS400_2020.CODOFER
			FROM  (
			
			  SELECT DISTINCT CT as CodCentro, CODOFER, CODCLIENTE FROM OFERREGU WHERE AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@Usuario
			  UNION ALL
			  SELECT DISTINCT CodCentro, CodOferta as CODOFER, CodCliente FROM dbo.OfertasSQL WHERE AñoAdjudicacion = @pAño
			
			) vwContratacionOfertas_SQL_AS400_2020 INNER JOIN
                   CentrosGerentesSQL ON vwContratacionOfertas_SQL_AS400_2020.CodCentro = CentrosGerentesSQL.CodCentro AND CentrosGerentesSQL.CodCentro = 2020 INNER JOIN
                   ClientesSQL ON vwContratacionOfertas_SQL_AS400_2020.CODCLIENTE = ClientesSQL.CodCliente LEFT OUTER JOIN
				   #RestoOfertas ON vwContratacionOfertas_SQL_AS400_2020.CODOFER = #RestoOfertas.CodOferta
			WHERE  #RestoOfertas.CodOferta IS NULL	
			
			PRINT 'Time 1.2º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
			
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Resto', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro,
			        '' as Contrato, #RestoOfertas.Cliente, #RestoOfertas.Gerencia, '' as FInicio, '' as FFinal, '' as FFinalEfectiva, #RestoOfertas.CodOferta,'X' as Tipo, '' as Mercado, 0 as CartInicio, 0 as NTrimestres, 0 as MontoTrimestre, 0 as MontoAnual, 0 AS PrevistoAño, 0 AS Nuevo,
					ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat,ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
					0  AS A2019,0 AS A2020, 0 AS A2021, '' as Prorrogable
			FROM    #RestoOfertas INNER JOIN
					dbo.Sumarigrama ON #RestoOfertas.CodCentro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					(
					  ---SELECT CodCentro, CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
					  SELECT CT as CodCentro, CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CT,CODOFER
					  
					) AS vwContratacion_SQL_AS400_2020
					ON #RestoOfertas.CodCentro = vwContratacion_SQL_AS400_2020.CodCentro AND #RestoOfertas.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
					(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado
					ON #RestoOfertas.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta	
			WHERE CodDelegacion = @Usuario_CodEntidad AND [#RestoOfertas].CodOferta NOT IN (SELECT CodOferta FROM #CarteraDiferida)

		END
	ELSE IF (@Usuario_Puesto='CT')
		BEGIN			
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaOfertasContratos_2016SQL.NomAgrupado, dbo.CentrosGerentesSQL.NombreGerente AS Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro INNER JOIN
                       dbo.CentrosGerentesSQL ON dbo.Sumarigrama.CodCentro = dbo.CentrosGerentesSQL.CodCentro  AND dbo.Sumarigrama.Año = dbo.CentrosGerentesSQL.Año LEFT OUTER JOIN
					   (
					        --SELECT CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
							SELECT CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CODOFER
					   
					   ) AS vwContratacion_SQL_AS400_2020 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			WHERE Sumarigrama.CodCentro = @Usuario_CodEntidad and Vigente=1
			
			PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- CONTRATOS MARCO --> ('Contratos Nacionales' que no estan en CentrosGerentesSQL)	(Duplicamos los que estan en Instalaciones I, Instalaciones II, etc)
			--INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			--SELECT  'Contratos Marco', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente, Gerencia,Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			--ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2019,			
			--dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2020, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2021, Cart_DiferidaContratosSQL.Prorrogable
			--FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
			--		   FROM #Cart_DiferidaContratosSQL) AS Cart_DiferidaContratosSQL INNER JOIN
			--		   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
			--		   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro  LEFT OUTER JOIN
			--		   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
			--			FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)) AS vwContratacion_SQL_AS400_2020 ON 
			--			dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
			--			(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			--WHERE CodDirGeneral = @Usuario_CodEntidad AND Cart_DiferidaContratosSQL.Gerencia = 'Contratos Nacionales' and Vigente=1		
		
			--PRINT 'Time 1.0º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			-- RESTO (Facturacion-Produccion --> ObrasActualesSQL-Enlaces)
			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT DISTINCT dbo.CentrosGerentesSQL.NombreGerente, dbo.ClientesSQL.NomAgrupado, dbo.ObrasActualesSQL.CTR, vwEnlaces_Detallado.CDOFT
			FROM  dbo.ObrasActualesSQL INNER JOIN
				 (				 
				 	 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario
					 UNION
					 SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BPH WHERE Usuario=@Usuario and añocierre=18
				 
				 ) as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  --vwEnlaces_ALL as vwEnlaces_Detallado ON dbo.ObrasActualesSQL.CTR = vwEnlaces_Detallado.CTRO AND 
				  dbo.ObrasActualesSQL.OBRA = vwEnlaces_Detallado.OBRA AND dbo.ObrasActualesSQL.OBRAL = vwEnlaces_Detallado.OBRAL INNER JOIN
				  dbo.CentrosGerentesSQL ON dbo.ObrasActualesSQL.CTR = dbo.CentrosGerentesSQL.CodCentro AND dbo.ObrasActualesSQL.Año = dbo.CentrosGerentesSQL.Año  INNER JOIN
				  dbo.ClientesSQL ON dbo.ObrasActualesSQL.CDCLI = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
				  #CarteraDiferida ON vwEnlaces_Detallado.CDOFT = #CarteraDiferida.CodOferta
			WHERE dbo.ObrasActualesSQL.Año = @pAño AND dbo.ObrasActualesSQL.Mes = @pMes AND #CarteraDiferida.CodOferta IS NULL

			PRINT 'Time 1.1º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

			INSERT INTO #RestoOfertas(Gerencia,Cliente,CodCentro,CodOferta)
			SELECT CentrosGerentesSQL.NombreGerente, ClientesSQL.NomAgrupado, vwContratacionOfertas_SQL_AS400_2020.CodCentro, vwContratacionOfertas_SQL_AS400_2020.CODOFER
			FROM  (
			
			  SELECT DISTINCT CT as CodCentro, CODOFER, CODCLIENTE FROM OFERREGU WHERE AÑOAD=@pAño AND ADJUDICADA = 'S' AND Usuario=@Usuario
			  UNION ALL
			  SELECT DISTINCT CodCentro, CodOferta as CODOFER, CodCliente FROM dbo.OfertasSQL WHERE AñoAdjudicacion = @pAño
			
			) vwContratacionOfertas_SQL_AS400_2020 INNER JOIN
                   CentrosGerentesSQL ON vwContratacionOfertas_SQL_AS400_2020.CodCentro = CentrosGerentesSQL.CodCentro AND CentrosGerentesSQL.CodCentro = 2020 INNER JOIN
                   ClientesSQL ON vwContratacionOfertas_SQL_AS400_2020.CODCLIENTE = ClientesSQL.CodCliente LEFT OUTER JOIN
				   #RestoOfertas ON vwContratacionOfertas_SQL_AS400_2020.CODOFER = #RestoOfertas.CodOferta
			WHERE  #RestoOfertas.CodOferta IS NULL	
			
			PRINT 'Time 1.2º --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
			
			INSERT INTO #CarteraDiferida (AGRUP,CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2019,A2020,A2021,Prorrogable) 
			SELECT  'Resto', dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro,
			        '' as Contrato, #RestoOfertas.Cliente, #RestoOfertas.Gerencia, '' as FInicio, '' as FFinal, '' as FFinalEfectiva, #RestoOfertas.CodOferta,'X' as Tipo, '' as Mercado, 0 as CartInicio, 0 as NTrimestres, 0 as MontoTrimestre, 0 as MontoAnual, 0 AS PrevistoAño, 0 AS Nuevo,
					ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) AS Contrat,ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2020.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
					0  AS A2019,0 AS A2020, 0 AS A2021, '' as Prorrogable
			FROM    #RestoOfertas INNER JOIN
					dbo.Sumarigrama ON #RestoOfertas.CodCentro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					(
					  ---SELECT CodCentro, CODOFER, Importe FROM dbo.fnContratacionAcumulada_SQL_AS400_2020(@pMes)
					  SELECT CT as CodCentro, CODOFER,SUM(IMPAD) AS importe FROM fnContratacion_SQL_AS400 (@pAño,@Usuario) WHERE MESAD<=@pMes GROUP BY CT,CODOFER
					  
					) AS vwContratacion_SQL_AS400_2020
					ON #RestoOfertas.CodCentro = vwContratacion_SQL_AS400_2020.CodCentro AND #RestoOfertas.CodOferta = vwContratacion_SQL_AS400_2020.CODOFER LEFT OUTER JOIN						
					(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado
					ON #RestoOfertas.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta
			WHERE  Sumarigrama.CodCentro = @Usuario_CodEntidad AND [#RestoOfertas].CodOferta NOT IN (SELECT CodOferta FROM #CarteraDiferida)

		END

	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario	

	DELETE FROM dbo.WEB_CarteraDiferidaPdteEjecutarUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'	
	DELETE FROM dbo.WEB_CarteraDetalladaUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'
	
	-- Copia en local y filtrada de los datos de la vista vwWEB_OFERTAS_CA (acceso al AS400)
	DECLARE @SQL_AS400_select as varchar(1000)
	DECLARE @SQL_AS400_from as varchar(1000)
	DECLARE @SQL_AS400 as varchar(max)
	
	CREATE TABLE #vwWEB_OFERTAS_CA_Local  (CodCentro varchar(3),CodOferta varchar(10), FAdjudicacion datetime, Adjudicada char(1), ImporteTotal float, Tipo varchar(10), DesOfer varchar(100))
	--CREATE CLUSTERED INDEX ix_vwWEB_OFERTAS_CA_Local_CodOferta ON #vwWEB_OFERTAS_CA_Local ([CodOferta]);

	SET @SQL_AS400_select = 'INSERT INTO #vwWEB_OFERTAS_CA_Local (CodCentro,CodOferta, FAdjudicacion, ImporteTotal,Tipo, DesOfer)
							 SELECT CDCEN AS CodCentro, CDOFT AS CodOferta, 
									CASE WHEN LEN(FECHAD) > 5 THEN
										 CONVERT(datetime, RIGHT(FECHAD, 6), 103) 
									ELSE
										(CASE WHEN FECHAD = ''0'' THEN
										  ''19990101''
										  ELSE
										    NULL
										 END) 
									END AS FAdjudicacion, 
									TVEN AS ImporteTotal, WS10 AS Tipo, DCOF AS DesOfer
							'

	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT OFCA.CDCEN, OFCA.CDOFT,  OFCA.DCOF,  OFCA.FECHAD, OFCA.TVEN,  OFCA.WS10
							 FROM  S44DD901.ICOMERF.IC09AP As OFCA LEFT OUTER JOIN S44DD901.FICOSCO.CO005BP AS Enlaces ON
									OFCA.CDCEN = Enlaces.CTRO AND OFCA.CDOFT = Enlaces.CDOFT
							 WHERE 
								((substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 ) < ' + str(@pAño) + ') OR 
								 (substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
								) AND
								NOT (OFCA.ADELE <> ''''S'''' AND Enlaces.CDOFT IS NULL) AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 )>=2005
							'')'	
	

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vwWEB_OFERTAS_CA'
	--print @SQL_AS400
	EXEC (@SQL_AS400)

	PRINT 'Time 2º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	--------------------------------
	-- Paco 20/04/2016 Table temporal de Ofertas dadas de baja para EXCLUIR SIEMPRE las ofertas de baja en relaciones posteriores	
	CREATE TABLE #OfertasDeBaja (CodOferta varchar(10))
	CREATE CLUSTERED INDEX ix_OfertasDeBaja_CodOferta ON #OfertasDeBaja ([CodOferta]);

	SET @SQL_AS400_select = 'INSERT INTO #OfertasDeBaja (CodOferta)
							 SELECT CDOFT AS CodOferta
							'
	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT CDOFT
							 FROM S44DD901.ICOMERF.IC09AP
							 WHERE substr( digits(dec(19000000+FECHAA,8,0)), 1, 4 ) >=2010 AND BAJA = ''''B'''' 
							 '')'	

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') OfertasDeBaja'	
	EXEC (@SQL_AS400)
	
	PRINT 'Time 3º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
	
	/* ***************************************************************************************************************** */
	/* ******************************************** CONTRATACION  ****************************************************** */
	/* ***************************************************************************************************************** */

	-- OFERTAS		
	CREATE TABLE #vwWEB_OFERTAS_CA (CodOferta varchar(10),FAdjudicacion datetime,DesOfer varchar(50), ImporteTotal float, Tipo char(10))
	CREATE CLUSTERED INDEX ix_vwWEB_OFERTAS_CA_CodOferta ON #vwWEB_OFERTAS_CA ([CodOferta]);
		
	-- Insertamos Ofertas que No son Baja
	INSERT INTO #vwWEB_OFERTAS_CA(CodOferta,FAdjudicacion,DesOfer,ImporteTotal,Tipo) 
	SELECT CodOferta,[dbo].[fnQuitar1999](FAdjudicacion) as FAdjudicacion ,DesOfer,ImporteTotal,Tipo 
	FROM #vwWEB_OFERTAS_CA_Local 
	WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)
		
	-- REGULARIZACIONES Posteriores	
	CREATE TABLE #vRegularizaciones (CodCentro varchar(3),CodOferta varchar(10), ImporteRegularizacion float)
	CREATE CLUSTERED INDEX ix_vRegularizaciones_CodOferta ON #vRegularizaciones ([CodOferta]);

	--INSERT into #vRegularizaciones(CodCentro,CodOferta,ImporteRegularizacion) 
	--SELECT cdcen,cdoft,sum(Impre)
	--		FROM Regularizaciones
	--		WHERE (dbo.Regularizaciones.AñoR=@pAño AND
	--			  dbo.Regularizaciones.MesR>@pMes) 
	--			  OR
	--			  (dbo.Regularizaciones.AñoR>@pAño)
	--GROUP BY cdcen,cdoft

	INSERT into #vRegularizaciones(CodCentro,CodOferta,ImporteRegularizacion) 
	SELECT cdcen,cdoft,sum(Impre)
			FROM vwRegularizaciones_2020_Sup 
			WHERE (AR=@pAño AND MR>@pMes) OR (AR>@pAño)
	GROUP BY cdcen,cdoft

	CREATE TABLE #WEB_CarteraUsuarioCentro_TMP (CodCentro char(3),CodOferta varchar(10),FAdjudicacion datetime,DesOfer varchar(50),ImporteContratado float,ImporteProd float,ImporteFactura float,ImporteFot float,TipoOferta varchar(1),Tipo int)	
	CREATE CLUSTERED INDEX ix_WEB_CarteraUsuarioCentro_TMP_CodOferta ON #WEB_CarteraUsuarioCentro_TMP ([CodOferta]);

	-- OFERTAS - REGULARIZACIONES Posteriores
	INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,FAdjudicacion,DesOfer,ImporteContratado)	
	SELECT  1,Tipo,'',[#vwWEB_OFERTAS_CA].CodOferta,FAdjudicacion,DesOfer,isnull(ImporteTotal,0)-isnull(ImporteRegularizacion,0)	
	FROM #vwWEB_OFERTAS_CA LEFT JOIN #vRegularizaciones ON [#vwWEB_OFERTAS_CA].CodOferta=[#vRegularizaciones].CodOferta

	-- OFERTASsql que no esten marcadas como bajas OfertasBajasSQL
	-- NO son de Reparto: Mismo Importe
	INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,FAdjudicacion,DesOfer,ImporteContratado)	
	SELECT  2,'F','',dbo.OfertasSQL.CodOferta,FAdjudicacion,DescripcionOferta,ImporteContratado
	FROM  dbo.OfertasSQL LEFT JOIN dbo.OfertasBajasSQL ON dbo.OfertasSQL.CodCentro=dbo.OfertasBajasSQL.CodCentro AND dbo.OfertasSQL.CodOferta=dbo.OfertasBajasSQL.CodOferta
	WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND dbo.OfertasSQL.CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)
		   AND isnull(dbo.OfertasBajasSQL.CodOferta,'')='' AND Reparto=0	

	-- SI son de Reparto: Suma de los Importes
	INSERT INTO #WEB_CarteraUsuarioCentro_TMP(Tipo,TipoOferta,CodCentro,CodOferta,FAdjudicacion,DesOfer,ImporteContratado)	
	SELECT  2,'F','',dbo.OfertasSQL.CodOferta,Min(FAdjudicacion),DescripcionOferta,sum(ImporteContratado)
	FROM  dbo.OfertasSQL LEFT JOIN dbo.OfertasBajasSQL ON dbo.OfertasSQL.CodCentro=dbo.OfertasBajasSQL.CodCentro AND dbo.OfertasSQL.CodOferta=dbo.OfertasBajasSQL.CodOferta
	WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND dbo.OfertasSQL.CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)
		  AND isnull(dbo.OfertasBajasSQL.CodOferta,'')='' AND Reparto=1 
	GROUP BY dbo.OfertasSQL.CodOferta,DescripcionOferta	

	PRINT 'Time 4º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
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
	      LEFT JOIN (
						  SELECT ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO_Detallado.CTRO AS CodCentro, vwTipoUNO_Detallado.CDOFT AS CodOferta,ObrasActualesSQL.OBRA, ObrasActualesSQL.OBRAL, vwTipoUNO_Detallado.OBRA + '-' + vwTipoUNO_Detallado.OBRAL + ' ' + ObrasActualesSQL.DSOBR AS NombreObra, SUM(ObrasActualesSQL.SOP) AS ImporteProduccion, SUM(ObrasActualesSQL.SOF) AS ImporteFactura, SUM(ObrasActualesSQL.SOL) AS ImporteFot, ObrasActualesSQL.STOBR AS Est, vwTipoUNO_Detallado.FECHAAPERTURA, vwTipoUNO_Detallado.FECHACIERRE
						  FROM (SELECT CTRO,OBRA,OBRAL,CDOFT,FechaApertura,FechaCierre FROM CO005BP WHERE Usuario=@Usuario AND CDOFT<>1) vwTipoUNO_Detallado INNER JOIN ObrasActualesSQL ON
						        vwTipoUNO_Detallado.CTRO = ObrasActualesSQL.CTR AND vwTipoUNO_Detallado.OBRA = ObrasActualesSQL.OBRA AND vwTipoUNO_Detallado.OBRAL = ObrasActualesSQL.OBRAL  
						  WHERE (Año=@pAño AND Mes=@pMes) OR isnull(Año,0)=0 
						  GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO_Detallado.CTRO, vwTipoUNO_Detallado.OBRA, vwTipoUNO_Detallado.OBRAL, ObrasActualesSQL.DSOBR, ObrasActualesSQL.STOBR, vwTipoUNO_Detallado.CDOFT, vwTipoUNO_Detallado.FECHAAPERTURA, vwTipoUNO_Detallado.FECHACIERRE, ObrasActualesSQL.OBRA, ObrasActualesSQL.OBRAL		  		  
		  ) vwTIPOUNO_Produccion_Detallado on [#WEB_CarteraUsuarioCentro_TMP].CodOferta=vwTIPOUNO_Produccion_Detallado.CodOferta AND 
		  CAST([#WEB_CarteraUsuarioCentro_TMP].CodCentro AS INT)=CAST(vwTIPOUNO_Produccion_Detallado.CodCentro AS INT) 
	
	PRINT 'Time 5º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
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
	FROM #WEB_CarteraUsuarioCentro_TMP A RIGHT JOIN (
	
		SELECT ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO_Detallado.CTRO AS CodCentro, vwTipoUNO_Detallado.CDOFT AS CodOferta,ObrasActualesSQL.OBRA, ObrasActualesSQL.OBRAL, vwTipoUNO_Detallado.OBRA + '-' + vwTipoUNO_Detallado.OBRAL + ' ' + ObrasActualesSQL.DSOBR AS NombreObra, SUM(ObrasActualesSQL.SOP) AS ImporteProduccion, SUM(ObrasActualesSQL.SOF) AS ImporteFactura, SUM(ObrasActualesSQL.SOL) AS ImporteFot, ObrasActualesSQL.STOBR AS Est, vwTipoUNO_Detallado.FECHAAPERTURA, vwTipoUNO_Detallado.FECHACIERRE
		FROM (SELECT CTRO,OBRA,OBRAL,CDOFT,FechaApertura,FechaCierre FROM CO005BP WHERE Usuario=@Usuario AND CDOFT<>1) vwTipoUNO_Detallado INNER JOIN ObrasActualesSQL ON
			  vwTipoUNO_Detallado.CTRO = ObrasActualesSQL.CTR AND vwTipoUNO_Detallado.OBRA = ObrasActualesSQL.OBRA AND vwTipoUNO_Detallado.OBRAL = ObrasActualesSQL.OBRAL  
		WHERE (Año=@pAño AND Mes=@pMes) OR isnull(Año,0)=0 
		GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO_Detallado.CTRO, vwTipoUNO_Detallado.OBRA, vwTipoUNO_Detallado.OBRAL, ObrasActualesSQL.DSOBR, ObrasActualesSQL.STOBR, vwTipoUNO_Detallado.CDOFT, vwTipoUNO_Detallado.FECHAAPERTURA, vwTipoUNO_Detallado.FECHACIERRE, ObrasActualesSQL.OBRA, ObrasActualesSQL.OBRAL		  		  

	) B on A.CodOferta=B.CodOferta AND
		 CAST(A.CodCentro AS INT)=CAST(B.CodCentro AS INT) INNER JOIN 
		#vwWEB_OFERTAS_CA_Local C ON B.CodOferta=C.CodOferta AND B.CodCentro=C.CodCentro
	WHERE (Año=@pAño AND Mes=@pMes) and A.CodOferta is null AND B.CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)	

	PRINT 'Time 6º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

-------------------------------------

	--TIPO1
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est)
	SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,dbo.fnFormatFecha(FechaApertura),dbo.fnFormatFecha(FechaCierre),ImporteProduccion,ImporteFactura,ImporteFot,Est
	FROM (
	
			SELECT      ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO.CTRO AS CodCentro, 'E' AS TipoOferta, 1 AS CodOferta, 0 AS ContratoMarco, 
								 '' AS DescripcionOferta, '-' AS FAdjudicacion, 0 AS ImporteContratado, 
								 vwTipoUNO.OBRA + '-' + vwTipoUNO.OBRAL + ' ' + ObrasActualesSQL.DSOBR AS NombreObra, SUM(ObrasActualesSQL.SOP) 
								 AS ImporteProduccion, ObrasActualesSQL.SOF AS ImporteFactura, ObrasActualesSQL.SOL AS ImporteFot, ObrasActualesSQL.STOBR AS Est, 
								 vwTipoUNO.FechaApertura, vwTipoUNO.FechaCierre, ObrasActualesSQL.CDCLI AS CodCliente
			FROM        (SELECT CTRO, OBRA, OBRAL, FechaApertura, FechaCierre FROM CO005BP WHERE Usuario=@Usuario AND CDOFT=1) vwTipoUNO INNER JOIN
						 ObrasActualesSQL ON vwTipoUNO.CTRO = ObrasActualesSQL.CTR AND vwTipoUNO.OBRA = ObrasActualesSQL.OBRA AND vwTipoUNO.OBRAL = ObrasActualesSQL.OBRAL
						 GROUP BY ObrasActualesSQL.Año, ObrasActualesSQL.Mes, vwTipoUNO.CTRO, vwTipoUNO.OBRA, vwTipoUNO.OBRAL, ObrasActualesSQL.DSOBR, ObrasActualesSQL.STOBR, vwTipoUNO.FechaApertura, vwTipoUNO.FechaCierre, ObrasActualesSQL.SOL, ObrasActualesSQL.SOF, ObrasActualesSQL.CDCLI

	) vw
	WHERE Año=@pAño AND Mes=@pMes AND CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)

	PRINT 'Time 7º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

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
	FROM WEB_CarteraDetalladaUsuarioCentro WITH (NOLOCK) INNER JOIN (
	
		SELECT vwEnlaces_Detallado.CTRO AS CodCentro, vwEnlaces_Detallado.CDOFT AS CodOferta, vwEnlaces_Detallado.OBRA,vwEnlaces_Detallado.OBRAL, 
			   --vwEnlaces_Detallado.OBRA + '-' + vwEnlaces_Detallado.OBRAL + ' ' + ObrasHistoricasSQL.DSOBR AS NombreObra, 
			   SUM(ObrasHistoricasSQL.SOP) AS ImporteProduccion, SUM(ObrasHistoricasSQL.SOF) AS ImporteFactura, SUM(ObrasHistoricasSQL.SOL) AS ImporteFot,
			   ObrasHistoricasSQL.FAPERTURA, ObrasHistoricasSQL.FCIERRE
		FROM   (SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario) vwEnlaces_Detallado INNER JOIN
				ObrasHistoricasSQL ON vwEnlaces_Detallado.CTRO = ObrasHistoricasSQL.CTR AND 
				vwEnlaces_Detallado.CDOFT = ObrasHistoricasSQL.CDOFT AND vwEnlaces_Detallado.OBRA = ObrasHistoricasSQL.OBRA AND 
				vwEnlaces_Detallado.OBRAL = ObrasHistoricasSQL.OBRAL
		GROUP BY vwEnlaces_Detallado.CTRO, vwEnlaces_Detallado.OBRA, vwEnlaces_Detallado.OBRAL, vwEnlaces_Detallado.CDOFT, 
				 ObrasHistoricasSQL.FAPERTURA, ObrasHistoricasSQL.FCIERRE 
				 --vwEnlaces_Detallado.OBRA + '-' + vwEnlaces_Detallado.OBRAL + ' ' + ObrasHistoricasSQL.DSOBR,
				 --ObrasHistoricasSQL.OBRA, ObrasHistoricasSQL.OBRAL
				 	
	)vwProduccion_Detallado_Historico ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=vwProduccion_Detallado_Historico.CodOferta AND
		 WEB_CarteraDetalladaUsuarioCentro.Obra=vwProduccion_Detallado_Historico.Obra AND
		 WEB_CarteraDetalladaUsuarioCentro.ObraL=vwProduccion_Detallado_Historico.ObraL 
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND vwProduccion_Detallado_Historico.CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)	

	PRINT 'Time 8º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

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
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND #WEB_CarteraDetalladaUsuarioCentro.CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)	

	PRINT 'Time 8.1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	/* ********************************************* OBRAS OTRAS ********************************************* */
	-- No tendran Codigo de Obra(la mayoria) y pueden ser de todos los Tipos	, No esta enlazado con Ofertas <--> Obra
	-- En el este caso insertamos las ofertas que anteriormente se a indicado produccion y actualizamos ofertas que no tengan produccion
	
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est)
	SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est
	FROM WEB_CarteraDetalladaUsuarioCentro INNER JOIN ObrasOtrasSQL ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND ObrasOtrasSQL.CDOFT IN (SELECT CodOferta FROM #CarteraDiferida) AND
		  WEB_CarteraDetalladaUsuarioCentro.Tipo=ObrasOtrasSQL.TipoOferta AND isnull(WEB_CarteraDetalladaUsuarioCentro.NombreObra,'')<>''
	GROUP BY TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est
	
	PRINT 'Time 8.2º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	--------------------------------------------------------------------------------
	-- Paco 22/02/2016
	-- Paco 20/04/2016 Incluído relacion con table temporal de Ofertas dadas de baja para EXCLUIR SIEMPRE las ofertas de baja
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est)
	SELECT @Usuario,TipoOferta,CDOFT CodOferta,Isnull(DescripcionOferta,''),IsNull(FAdjudicacion,''),IsNull(ImporteContratado,0),TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est
	FROM WEB_CarteraDetalladaUsuarioCentro RIGHT JOIN ObrasOtrasSQL ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
		 LEFT JOIN #OfertasDeBaja OB ON ObrasOtrasSQL.CDOFT = OB.CodOferta
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario is null AND ObrasOtrasSQL.CDOFT IN (SELECT CodOferta FROM #CarteraDiferida)
			AND OB.CodOferta is null
	GROUP BY TipoOferta,CDOFT,DescripcionOferta,FAdjudicacion,ImporteContratado,TipoOferta+[dbo].[fnObra](TipoOferta, ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  +  DSOBR, replace(ObrasOtrasSQL.FAPERTURA,'/','_'),replace(ObrasOtrasSQL.FCIERRE,'/','_'),SOP,SOF,SOL,Est

	--------------------------------------------------------------------------------

	PRINT 'Time 9º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ImporteProduccion=SOP,
	    ImporteFactura=SOF,
		ImporteFot=SOL,
		NombreObra= TipoOferta+[dbo].[fnObra](TipoOferta,ObrasOtrasSQL.Obra,ObrasOtrasSQL.ObraL)  + DSOBR,
		FApertura=replace(ObrasOtrasSQL.FApertura,'/','_'),
		FCierre=replace(ObrasOtrasSQL.FCierre,'/','_')
	FROM WEB_CarteraDetalladaUsuarioCentro INNER JOIN ObrasOtrasSQL ON
		 WEB_CarteraDetalladaUsuarioCentro.CodOferta=ObrasOtrasSQL.CDOFT
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND ObrasOtrasSQL.CTR IN (SELECT CodOferta FROM #CarteraDiferida) AND
		  WEB_CarteraDetalladaUsuarioCentro.Tipo=ObrasOtrasSQL.TipoOferta AND isnull(WEB_CarteraDetalladaUsuarioCentro.NombreObra,'')=''

    /* Para sumarizar a nivel de oferta la Produccion total y pooder calcular la cartera pendiente, que no se calcula a nivel de obra */	
	/*
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ImporteProduccion=q.Produccion
	FROM WEB_CarteraDetalladaUsuarioCentro INNER JOIN (
		 SELECT CodOferta, SUM(ImporteProduccion) Produccion 
		 FROM WEB_CarteraDetalladaUsuarioCentro
		 WHERE Usuario = @Usuario and IsNull(Obra,'')<>''  
		 GROUP BY CodOferta) q ON WEB_CarteraDetalladaUsuarioCentro.CodOferta=q.CodOferta
	WHERE Usuario = @Usuario and IsNull(Obra,'')=''
	*/
	
	/* ****************************************** CONTRATOS MARCO ********************************************* */
	UPDATE WEB_CarteraDetalladaUsuarioCentro
	SET ContratoMarco='*'
	WHERE CodOferta IN (SELECT CodOferta FROM vwCart_DiferidaOfertasContratosSQL WHERE Año=@pAño)
	
	/* *************************************************************************************** */	

	PRINT 'Time 10º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	CREATE TABLE #OfertaDatosAnuales_TMP (CodOferta varchar(10),Produccion_A float,CostoTotal_A float,MargenProduccion_A float,PorcProduccion_A float,
										  Facturacion_A float, Facturacion_Origen_A float,Facturacion_Anticipada_A float,Produccion_Curso_A float )	
	CREATE CLUSTERED INDEX ix_OfertaDatosAnuales_TMP_CodOferta ON #OfertaDatosAnuales_TMP ([CodOferta]);

	INSERT INTO #OfertaDatosAnuales_TMP
	SELECT * FROM (SELECT E.CDOFT, 
						SUM(O.SAP) Produccion_A,
						SUM(O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR) CostoTotal_A,
						SUM(O.SAP) - SUM((O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR)) MargenProduccion_A,
						CASE WHEN SUM(O.SAP)=0
							THEN 0
							ELSE ROUND(100*(SUM(O.SAP) - SUM((O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR))) / SUM(O.SAP) ,2)
							END PorcProduccion,
						SUM(O.SAF) Facturacion_A,
						SUM(O.SOF) Facturacion_Origen_A,
						SUM(O.SOF-O.SOL) Facturacion_Anticipada_A,						
						SUM(O.SOP-O.SOL) Produccion_Curso_A
	FROM (
	
	  SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario		-- ENLACES
	  /*
	  Paco 2020-09-16 con es para el cálculo de datos anuales ignoro el histórico de enlaces
	  UNION 
	  SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BPH WHERE Usuario=@Usuario		-- ENLACES HISTORICO
	  */
	) E INNER JOIN (
			SELECT * FROM ObrasActualesSQL WHERE Año = @pAño And Mes = @pMes
		) O ON E.CTRO=O.CTR AND E.OBRA=O.OBRA AND E.OBRAL=O.OBRAL 
	GROUP BY E.CDOFT
	)vw
	WHERE vw.CDOFT IN (SELECT CodOferta FROM #CarteraDiferida)
	
	PRINT 'Time 11º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ********************************* RESULTADO *********************************** */	

	SELECT CodOferta, sum(ImporteContratado) Contratado
	INTO #OfertasImporteContratado
	FROM WEB_CarteraDetalladaUsuarioCentro	
	WHERE Usuario = @Usuario 
	GROUP BY CodOferta

	UPDATE WEB_CarteraDetalladaUsuarioCentro
		SET WEB_CarteraDetalladaUsuarioCentro.TotalObrasOferta = q2.NumObras
		FROM	(SELECT q.CodOferta, count(q.Obra) NumObras
					FROM	(SELECT CodOferta, isnull(Obra,'') as Obra
								FROM WEB_CarteraDetalladaUsuarioCentro
								 WHERE Usuario = @Usuario
								 GROUP BY CodOferta, isnull(Obra,'')
							) q INNER JOIN #OfertaDatosAnuales_TMP t ON q.CodOferta=t.CodOferta --AND q.Obra=t.Obra AND q.ObraL=t.ObraL
	--				WHERE IsNull(q.Est,'')<>'C' OR ROUND(t.Produccion_A/1000,0)<>0 or ROUND(t.MargenProduccion_A/1000,0)<>0	
					GROUP BY q.CodOferta
				) q2 INNER JOIN #OfertasImporteContratado ON q2.CodOferta=#OfertasImporteContratado.CodOferta 
					INNER JOIN WEB_CarteraDetalladaUsuarioCentro W ON W.CodOferta=q2.CodOferta
	WHERE Usuario = @Usuario
	
	INSERT INTO #OfertaDatosAnuales_TMP
	SELECT W.CodOferta, 0, 0, 0, 0, 0, 0, 0,0
	FROM WEB_CarteraDetalladaUsuarioCentro  W LEFT JOIN #OfertaDatosAnuales_TMP T ON W.CodOferta=T.CodOferta --AND W.Obra=T.Obra AND W.ObraL=T.ObraL
	WHERE Usuario = @Usuario AND T.CodOferta is null

	PRINT 'Time 12º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'
	
	/*******************************************************************************************************************/	
	/*******************************************************************************************************************/	
	/*******************************************************************************************************************/

	/* RESULTADO --> rptCarteraDiferidaPorObra */
	SELECT q.CodOferta,
		   q.Tipo,
	       IsNull(SUM(q.ImporteContratado),0) Contratacion,
		   IsNull(SUM(q.ImporteProduccion),0) Produccion,
		   IsNull(IsNull(SUM(q.ImporteContratado),0)-IsNull(SUM(q.ImporteProduccion),0),0) CarteraPendiente,

		   IsNull(t.Produccion_A,0) Produccion_A,
		   IsNull(t.CostoTotal_A, 0 ) CostoTotal_A,
		   IsNull(t.MargenProduccion_A, 0) MargenProduccion_A,
		   IsNull(t.PorcProduccion_A, 0) PorcProduccion_A,

		   IsNull(t.Facturacion_A, 0) Facturacion_A,
		   IsNull(t.Facturacion_Origen_A, 0) Facturacion_Origen_A,
		   IsNull(t.Facturacion_Anticipada_A, 0) Facturacion_Anticipada_A,
		   IsNull(t.Produccion_Curso_A, 0) Produccion_Curso_A,
		   q.TotalObrasOferta,
		   0 as Baja		   
	INTO #rptCarteraDiferidaPorObra
	FROM (
			SELECT CodOferta,Tipo, ImporteContratado, SUM(ImporteProduccion) ImporteProduccion, TotalObrasOferta
			FROM WEB_CarteraDetalladaUsuarioCentro	
			WHERE Usuario = @Usuario
			GROUP BY CodOferta, Tipo, ImporteContratado, TotalObrasOferta) q INNER JOIN #OfertaDatosAnuales_TMP t ON q.CodOferta=t.CodOferta
	GROUP BY q.CodOferta,q.Tipo, q.TotalObrasOferta,t.Produccion_A, t.CostoTotal_A, t.MargenProduccion_A, t.PorcProduccion_A, t.Facturacion_A, t.Facturacion_Origen_A, t.Facturacion_Anticipada_A, t.Produccion_Curso_A
		
	/* Actualizamos Ofertas de Baja */
	UPDATE #rptCarteraDiferidaPorObra
	SET Baja= 1
	FROM #rptCarteraDiferidaPorObra INNER JOIN #OfertasDeBaja ON 
	#rptCarteraDiferidaPorObra.CodOferta= #OfertasDeBaja.CodOferta	
		
	PRINT 'Time 13º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'		 

	/*******************************************************************************************************************/
	/******************************************************** SALIDA ***************************************************/
	/*******************************************************************************************************************/	

	INSERT INTO dbo.WEB_CarteraDiferidaPdteEjecutarUsuarioCentro (Usuario,Año,Mes,
																  CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,
																  Tipo,Gerencia,AGRUP,Cliente,Contrato,FInicio,FFinal,FFinalEfectiva,CodOferta,DesOfer,TipoOferta,Mercado,
																  CartInicio,NTrimestre,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat,TrimSQL,Regu,
																  A_Año,
																  A_Año1,
																  A_Año2,
																  Prorrogable,
																  CarteraPendiente,
																  Produccion_A,																 
																  MargenProduccion_A,
																  CostoTotal_A,
																  PorcProduccion_A,
																  Produccion,
																  Facturacion_A,Facturacion_Origen_A,Facturacion_Anticipada_A,Produccion_Curso_A,
																  TotalObrasOferta,LiteralSIN)
	SELECT	@Usuario,@pAño,@pMes,
	        CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,
			#CarteraDiferida.Tipo,Gerencia,AGRUP,Cliente,Contrato,FInicio,FFinal,FFinalEfectiva,#CarteraDiferida.CodOferta,DesOfer,
			#rptCarteraDiferidaPorObra.Tipo as TipoOferta,Mercado,
			round(isnull(CartInicio,0)/1000,0), NTrimestres, MontoTrimestre, MontoAnual,round(PrevistoAño/1000,0),round(Nuevo/1000,0),
			round(isnull(Contrat,0)/1000,0) as Contrat,
			round(TrimSQL/1000,0) as TrimSQL,
			round(Regu/1000,0) as Regu,
			--CASE WHEN @pAgrup='T'
			--THEN 
			--	round(A2019,0)
			--ELSE
			--	[dbo].[fnCarteraDiferidaAnual] (isnull(MontoAnual,0),isnull(Contrat,0)/1000) END as A2019,			
			CASE WHEN [#CarteraDiferida].Tipo='T' OR [#CarteraDiferida].Tipo='X' -- Trimestral/Resto
			THEN 
				round(A2019,0)
			ELSE
				[dbo].[fnCarteraDiferidaAnual] (isnull(MontoAnual,0),isnull(Contrat,0)/1000) END as A2019,
			round(A2020,0),
			round(A2021,0),
			Prorrogable,			
			CASE WHEN isnull(#rptCarteraDiferidaPorObra.TotalObrasOferta,0) > 0 
			THEN round(isnull(#rptCarteraDiferidaPorObra.CarteraPendiente,0)/1000,0)
			ELSE 0 END  as CarteraPendiente,			
			isnull(#rptCarteraDiferidaPorObra.Produccion_A,0)/1000 as Produccion_A,
			isnull(#rptCarteraDiferidaPorObra.MargenProduccion_A,0)/1000,
			round(isnull(#rptCarteraDiferidaPorObra.CostoTotal_A,0)/1000,0) as CostoTotal_A,
			round(isnull(#rptCarteraDiferidaPorObra.PorcProduccion_A,0),0),			
			round(isnull(#rptCarteraDiferidaPorObra.Produccion,0)/1000,0) as Produccion,
			isnull(#rptCarteraDiferidaPorObra.Facturacion_A,0)/1000 as Facturacion_A,
			isnull(#rptCarteraDiferidaPorObra.Facturacion_Origen_A,0)/1000 as Facturacion_Origen_A,
			isnull(#rptCarteraDiferidaPorObra.Facturacion_Anticipada_A,0)/1000 as Facturacion_Anticipada_A,
			isnull(#rptCarteraDiferidaPorObra.Produccion_Curso_A,0)/1000 as Produccion_Curso_A,
			isnull(isnull(#rptCarteraDiferidaPorObra.TotalObrasOferta,0),0) as TotalObrasOferta,
		    dbo.fnLiteralSIN(#rptCarteraDiferidaPorObra.Tipo, isnull(#rptCarteraDiferidaPorObra.TotalObrasOferta,0)) as LiteralSIN
	FROM #CarteraDiferida LEFT JOIN #rptCarteraDiferidaPorObra ON #CarteraDiferida.CodOferta= #rptCarteraDiferidaPorObra.CodOferta
	LEFT JOIN (select distinct CodOferta, DesOfer from #vwWEB_OFERTAS_CA_Local ) WEB_CDUC ON WEB_CDUC.CodOferta=#CarteraDiferida.CodOferta	
	WHERE Baja IS NULL OR Baja=0 OR isnull(#rptCarteraDiferidaPorObra.TotalObrasOferta,0)>0 -- Eliminamos las Ofertas que estan de Baja y no tienen ninguna Oferta Asociada (Enlaces)			

	/**************************************************************************************************************************/
	--- Ofertas sin Descripcion al No estar adjudicadas actualizamos con AS400 

	PRINT 'Time 14º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	DECLARE @Ofertas_SIN_Descripcion as varchar(5000)

	SELECT @Ofertas_SIN_Descripcion = 
		STUFF((SELECT ',' + str(CodOferta)
			   FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro v 
			   WHERE  Usuario= @Usuario AND v.DesOfer IS NULL
			  FOR XML PATH('')), 1, 1, '')
	
	CREATE TABLE #Ofertas_SIN_DESCRIPCION(CODOFER numeric(10,0), DESOFER varchar(100))
	CREATE CLUSTERED INDEX ix_Ofertas_SIN_DESCRIPCION_CodOferta ON #Ofertas_SIN_DESCRIPCION ([CODOFER]);

	SET @SQL_AS400='INSERT INTO #Ofertas_SIN_DESCRIPCION(CODOFER, DESOFER) SELECT CODOFER, DESOFER FROM OPENQUERY(SIC,''SELECT CDOFT as CODOFER, DCOF as DESOFER FROM S44DD901.ICOMERF.IC09AP WHERE CDOFT IN('+ @Ofertas_SIN_Descripcion+') '')'		
	EXEC (@SQL_AS400)	

	UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	SET DESOFER=o.DESOFER,
		CarteraPendiente=0, Produccion_A=0, MargenProduccion_A=0, CostoTotal_A=0, PorcProduccion_A=0, Produccion=0
	FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro w INNER JOIN #Ofertas_SIN_DESCRIPCION o ON w.Codoferta=o.CODOFER
	WHERE Usuario= @Usuario AND w.DesOfer IS NULL

	PRINT 'Time 15º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/**************************************************************************************************************************/
	--- Actualizamos la Descripcion de la Oferta con literal: (B), si esta de baja y la Cartera Pendiente a 0

	UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	SET DESOFER='(Baja) ' + w.DESOFER, CarteraPendiente=0
	FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro w INNER JOIN #OfertasDeBaja b ON w.Codoferta=b.CodOferta
	WHERE  Usuario= @Usuario

	-- Borramos las Ofertas de Baja y que tengan Produccion a 0
	DELETE FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	WHERE Usuario= @Usuario and DESOFER like '(Baja)%' and Produccion_A=0

	/**************************************************************************************************************************/
	--- Actualizamos Cartera diferida Ano a 0 si no hay prevision, aunque exista contratacion
	--IF @pAgrup='A'
	--	BEGIN
	--		UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	--		SET A_Año=0
	--		FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	--		WHERE  Usuario= @Usuario AND MontoAnual=0
	--	END
	UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	SET A_Año=0
	FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	WHERE Usuario= @Usuario AND MontoAnual=0 AND Tipo='A'

	PRINT 'Time 16º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/**************************************************************************************************************************/

	 SELECT *
	 INTO #OFERTAS_1
	 FROM (	SELECT	    cast(O.CTR as decimal(3,0)) as CTR,
						E.CDOFT, 
						SUM(O.SAP) Produccion_1,
						SUM(O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR) CostoTotal_1,
						SUM(O.SAP) - SUM((O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR)) MargenProduccion_1,
						CASE WHEN SUM(O.SAP)=0
							THEN 0
							ELSE ROUND(100*(SUM(O.SAP) - SUM((O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR))) / SUM(O.SAP) ,2)
							END PorcProduccion_1,
						SUM(O.SAF) Facturacion_1,
						SUM(O.SOF) Facturacion_Origen_1,
						SUM(O.SOF-O.SOL) Facturacion_Anticipada_1,						
						SUM(O.SOP-O.SOL) Produccion_Curso_1
	FROM (
	
		 --SELECT * FROM vwEnlaces_CDOFT_1
		  SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BP WHERE Usuario=@Usuario AND CDOFT=1
		  UNION
		  SELECT CTRO,OBRA,OBRAL,CDOFT FROM CO005BPH WHERE Usuario=@Usuario AND CDOFT=1 AND añocierre=18 
	
	) E INNER JOIN
		 ( SELECT * FROM ObrasActualesSQL WHERE Año = @pAño And Mes = @pMes ) O 
		ON E.CTRO=O.CTR AND E.OBRA=O.OBRA AND E.OBRAL=O.OBRAL
		GROUP BY O.CTR, E.CDOFT
	)vw

	UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	SET Produccion_A=Produccion_1/1000,CarteraPendiente=-1*(Produccion_1/1000), CostoTotal_A=CostoTotal_1/1000,MargenProduccion_A=MargenProduccion_1/1000,
	    PorcProduccion_A=PorcProduccion_1/1000, Facturacion_A=Facturacion_1/1000,Facturacion_Origen_A=Facturacion_Origen_1/1000,
		Facturacion_Anticipada_A=Facturacion_Anticipada_1/1000,Produccion_Curso_A=Produccion_Curso_1/1000
	FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro INNER JOIN #OFERTAS_1 ON CodCentro=CTR and CodOferta=CDOFT
	WHERE Usuario= @Usuario
	
	PRINT 'Time Total --> ' + cast( DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha

	return 0
	
	END TRY
	BEGIN CATCH	
		PRINT ERROR_MESSAGE ()
		return  ERROR_NUMBER ()
		--select   ERROR_MESSAGE ()
	END CATCH	
	
END