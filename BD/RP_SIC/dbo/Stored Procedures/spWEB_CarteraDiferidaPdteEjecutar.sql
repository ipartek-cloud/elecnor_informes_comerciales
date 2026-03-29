
-- exec [dbo].[spWEB_CarteraDiferidaPdteEjecutar_NEW] 'eluque_1719',2018,8,'T'

CREATE PROCEDURE [dbo].[spWEB_CarteraDiferidaPdteEjecutar]
	@Usuario varchar(50), 		
	@pAño int,
	@pMes int,
	@pAgrup varchar(1) -- T:Trimestral, A: Anual	
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
		[A2018] [float] NULL,
		[A2019] [int] NULL,
		[A2020] [int] NULL,
		[Prorrogable] [varchar](50) NULL
)

	IF (@Usuario_Puesto='DG')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2018_Mayo & vwCarteraDiferidaAnual_2018_Mayo
			INSERT INTO #CarteraDiferida (CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2018,A2019,A2020,Prorrogable) 
			SELECT     dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente,Cart_DiferidaContratosSQL.Gerencia, Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2018,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2019, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2020, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM dbo.fnCart_DiferidaContratosSQL_Usuario(@pAgrup,@Usuario_Sin_Fecha)) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
						FROM dbo.fnContratacionAcumulada_SQL_AS400_2018(@pMes)) AS vwContratacion_SQL_AS400_2018 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2018.CODOFER LEFT OUTER JOIN						
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta		
			WHERE CodDirGeneral = @Usuario_CodEntidad
		END
	ELSE IF (@Usuario_Puesto='SDG')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2018_Mayo & vwCarteraDiferidaAnual_2018_Mayo
			INSERT INTO #CarteraDiferida (CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2018,A2019,A2020,Prorrogable) 
			SELECT     dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente,Cart_DiferidaContratosSQL.Gerencia, Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu,
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2018,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2019, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2020, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM dbo.fnCart_DiferidaContratosSQL_Usuario(@pAgrup,@Usuario_Sin_Fecha)) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
						FROM dbo.fnContratacionAcumulada_SQL_AS400_2018(@pMes)) AS vwContratacion_SQL_AS400_2018 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2018.CODOFER LEFT OUTER JOIN
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta		
			WHERE CodSubDirGeneral = @Usuario_CodEntidad

		END
	ELSE IF (@Usuario_Puesto='DN')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2018_Mayo & vwCarteraDiferidaAnual_2018_Mayo
			INSERT INTO #CarteraDiferida (CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2018,A2019,A2020,Prorrogable) 
			SELECT     dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente,Cart_DiferidaContratosSQL.Gerencia, Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2018,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2019, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2020, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM dbo.fnCart_DiferidaContratosSQL_Usuario(@pAgrup,@Usuario_Sin_Fecha)) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
						FROM dbo.fnContratacionAcumulada_SQL_AS400_2018(@pMes)) AS vwContratacion_SQL_AS400_2018 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2018.CODOFER LEFT OUTER JOIN
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta		
			WHERE CodDDirNegocio = @Usuario_CodEntidad

		END
	ELSE IF (@Usuario_Puesto='AREA')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2018_Mayo & vwCarteraDiferidaAnual_2018_Mayo
			INSERT INTO #CarteraDiferida (CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2018,A2019,A2020,Prorrogable) 
			SELECT     dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente,Cart_DiferidaContratosSQL.Gerencia, Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu,
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2018,			
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2019, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2020, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM dbo.fnCart_DiferidaContratosSQL_Usuario(@pAgrup,@Usuario_Sin_Fecha)) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
						FROM dbo.fnContratacionAcumulada_SQL_AS400_2018(@pMes)) AS vwContratacion_SQL_AS400_2018 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2018.CODOFER LEFT OUTER JOIN
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta		
			WHERE CodSubDirNegocioArea = @Usuario_CodEntidad

		END
	ELSE IF (@Usuario_Puesto='DEL')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2018_Mayo & vwCarteraDiferidaAnual_2018_Mayo
			INSERT INTO #CarteraDiferida (CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2018,A2019,A2020,Prorrogable) 
			SELECT     dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente,Cart_DiferidaContratosSQL.Gerencia, Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, 			
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2018,
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2019, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2020, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM dbo.fnCart_DiferidaContratosSQL_Usuario(@pAgrup,@Usuario_Sin_Fecha)) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
						FROM dbo.fnContratacionAcumulada_SQL_AS400_2018(@pMes)) AS vwContratacion_SQL_AS400_2018 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2018.CODOFER LEFT OUTER JOIN
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta		
			WHERE CodDelegacion = @Usuario_CodEntidad

		END
	ELSE IF (@Usuario_Puesto='CT')
		BEGIN
			-- vwCarteraDiferidaTrimestral_2018_Mayo & vwCarteraDiferidaAnual_2018_Mayo
			INSERT INTO #CarteraDiferida (CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,Contrato,Cliente,Gerencia,FInicio,FFinal,FFinalEfectiva,CodOferta,Tipo,Mercado,CartInicio,NTrimestres,MontoTrimestre,MontoAnual,PrevistoAño,Nuevo,Contrat ,TrimSQL,Regu,A2018,A2019,A2020,Prorrogable) 
			SELECT     dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral,dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea,dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro,dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente,Cart_DiferidaContratosSQL.Gerencia, Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio AS Nuevo, ISNULL(vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) AS Contrat, ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu,			
			ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2018,
			dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2019, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2020, Cart_DiferidaContratosSQL.Prorrogable
			FROM      (SELECT ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
					   FROM dbo.fnCart_DiferidaContratosSQL_Usuario(@pAgrup,@Usuario_Sin_Fecha)) AS Cart_DiferidaContratosSQL INNER JOIN
					   dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
					   dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
					   (SELECT CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
						FROM dbo.fnContratacionAcumulada_SQL_AS400_2018(@pMes)) AS vwContratacion_SQL_AS400_2018 ON 
						dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2018.CODOFER LEFT OUTER JOIN
						(SELECT * FROM vwCarteraDiferidaSQLContratado WHERE Año=@pAño) vwCarteraDiferidaSQLContratado ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwCarteraDiferidaSQLContratado.CodOferta		
			WHERE Sumarigrama.CodCentro = @Usuario_CodEntidad

		END

	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario	
	
	DELETE FROM dbo.WEB_CarteraDiferidaPdteEjecutarUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'	
	DELETE FROM dbo.WEB_CarteraDetalladaUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'
	
	CREATE TABLE #WEB_CarteraUsuarioCentro_TMP (CodCentro char(3),CodOferta varchar(10),FAdjudicacion datetime,DesOfer varchar(50),ImporteContratado float,ImporteProd float,ImporteFactura float,ImporteFot float,TipoOferta varchar(1),Tipo int)	
	
	-- Copia en local y filtrada de los datos de la vista vwWEB_OFERTAS_CA (acceso al AS400)
	DECLARE @SQL_AS400_select as varchar(1000)
	DECLARE @SQL_AS400_from as varchar(1000)
	DECLARE @SQL_AS400 as varchar(max)
	
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
							 WHERE 
								((substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 ) < ' + str(@pAño) + ') OR 
								 (substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 1, 4 ) = ' + str(@pAño) + ' AND substr( digits(dec(19000000+OFCA.FECHAA,8,0)), 5, 2 ) <= ' + str(@pMes) + ')
								) AND
								NOT (OFCA.ADELE <> ''''S'''' AND Enlaces.CDOFT IS NULL)
							'')'

	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vwWEB_OFERTAS_CA'		
	EXEC (@SQL_AS400)
		
	--------------------------------
	-- Paco 20/04/2016 Table temporal de Ofertas dadas de baja para EXCLUIR SIEMPRE las ofertas de baja en relaciones posteriores
	CREATE TABLE #OfertasDeBaja (CodCentro varchar(3),CodOferta varchar(10))
	SET @SQL_AS400_select = 'INSERT INTO #OfertasDeBaja (CodCentro,CodOferta)
							 SELECT CDCEN AS CodCentro, CDOFT AS CodOferta
							'

	SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
							''SELECT DISTINCT CDCEN, CDOFT
							 FROM S44DD901.ICOMERF.IC09AP
							 WHERE BAJA = ''''B'''' 
							 '')'
	SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') OfertasDeBaja'	
	EXEC (@SQL_AS400)
	
	/* ***************************************************************************************************************** */
	/* ******************************************** CONTRATACION  ****************************************************** */
	/* ***************************************************************************************************************** */

	-- OFERTAS
		
	CREATE TABLE #vwWEB_OFERTAS_CA (CodOferta varchar(10),FAdjudicacion datetime,DesOfer varchar(50), ImporteTotal float, Tipo char(10))
		
	-- Insertamos Ofertas que No son Baja
	INSERT INTO #vwWEB_OFERTAS_CA(CodOferta,FAdjudicacion,DesOfer,ImporteTotal,Tipo) 
	SELECT CodOferta,[dbo].[fnQuitar1999](FAdjudicacion) as FAdjudicacion ,DesOfer,ImporteTotal,Tipo 
	FROM #vwWEB_OFERTAS_CA_Local 
	WHERE (year(FAdjudicacion)<@pAño OR (year(FAdjudicacion)=@pAño AND month(FAdjudicacion)<=@pMes)) AND CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)

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
	      LEFT JOIN vwTIPOUNO_Produccion_Detallado on [#WEB_CarteraUsuarioCentro_TMP].CodOferta=vwTIPOUNO_Produccion_Detallado.CodOferta AND 
		  CAST([#WEB_CarteraUsuarioCentro_TMP].CodCentro AS INT)=CAST(vwTIPOUNO_Produccion_Detallado.CodCentro AS INT) 
	WHERE (Año=@pAño AND Mes=@pMes) OR isnull(Año,0)=0 -- Adjudicadas OR Sin Obra	

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
		vwTIPOUNO_Produccion_Detallado B on A.CodOferta=B.CodOferta AND
		 CAST(A.CodCentro AS INT)=CAST(B.CodCentro AS INT) INNER JOIN 
		#vwWEB_OFERTAS_CA_Local C ON B.CodOferta=C.CodOferta AND B.CodCentro=C.CodCentro
	WHERE (Año=@pAño AND Mes=@pMes) and A.CodOferta is null AND B.CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)
		
-------------------------------------

	--TIPO1
	INSERT INTO WEB_CarteraDetalladaUsuarioCentro(Usuario,Tipo,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,FApertura,FCierre,ImporteProduccion,ImporteFactura,ImporteFot,Est)
	SELECT @Usuario,TipoOferta,CodOferta,DescripcionOferta,FAdjudicacion,ImporteContratado,NombreObra,dbo.fnFormatFecha(FechaApertura),dbo.fnFormatFecha(FechaCierre),ImporteProduccion,ImporteFactura,ImporteFot,Est
	FROM [dbo].[vwTIPOUNO_ProduccionElecnor_Detallado]
	WHERE Año=@pAño AND Mes=@pMes AND CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)

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
	WHERE WEB_CarteraDetalladaUsuarioCentro.Usuario= @Usuario AND vwProduccion_Detallado_Historico.CodOferta IN (SELECT CodOferta FROM #CarteraDiferida)

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

	CREATE TABLE #OfertaDatosAnuales_TMP (CodOferta varchar(10),Produccion_A float,CostoTotal_A float,MargenProduccion_A float,PorcProduccion_A float,
										  Facturacion_A float, Facturacion_Origen_A float,Facturacion_Anticipada_A float,Produccion_Curso_A float )	
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
			SELECT *
			FROM OPENQUERY(SIC, 'SELECT * FROM   S44DD901.FICOSCO.CO005BP AS Enlaces')) E INNER JOIN 		(
			SELECT * FROM ObrasActualesSQL WHERE Año = @pAño And Mes = @pMes
		) O ON E.CTRO=O.CTR AND E.OBRA=O.OBRA+O.OBRAL 
	GROUP BY E.CDOFT
	)vw
	WHERE vw.CDOFT IN (SELECT CodOferta FROM #CarteraDiferida)

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

	/*******************************************************************************************************************/
	/******************************************************** SALIDA ***************************************************/
	/*******************************************************************************************************************/	

	INSERT INTO dbo.WEB_CarteraDiferidaPdteEjecutarUsuarioCentro (Usuario,Año,Mes,
																  CodDirGeneral,NombreDirGeneral,CodSubDirGeneral,NombreSubDirGeneral,CodDDirNegocio,NombreDirNegocio,CodSubDirNegocioArea,NombreSubDirNegocioArea,CodDelegacion,NombreDelegacion,CodCentro,NombreCentro,
																  Tipo,Gerencia,Cliente,Contrato,FInicio,FFinal,FFinalEfectiva,CodOferta,DesOfer,TipoOferta,Mercado,
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
			#CarteraDiferida.Tipo,Gerencia,Cliente,Contrato,FInicio,FFinal,FFinalEfectiva,#CarteraDiferida.CodOferta,DesOfer,
			#rptCarteraDiferidaPorObra.Tipo as TipoOferta,Mercado,
			round(isnull(CartInicio,0)/1000,0), NTrimestres, MontoTrimestre, MontoAnual,round(PrevistoAño/1000,0),round(Nuevo/1000,0),
			round(isnull(Contrat,0)/1000,0) as Contrat,
			round(TrimSQL/1000,0) as TrimSQL,
			round(Regu/1000,0) as Regu,
			CASE WHEN @pAgrup='T'
			THEN 
				round(A2018,0)
			ELSE
				[dbo].[fnCarteraDiferidaAnual] (isnull(MontoAnual,0),isnull(Contrat,0)/1000) END as A2018,
			round(A2019,0),
			round(A2020,0),
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
	WHERE Baja IS NULL	OR  Baja=0 OR isnull(#rptCarteraDiferidaPorObra.TotalObrasOferta,0)>0 -- Eliminamos las Ofertas que estan de Baja y no tienen ninguna Oferta Asociada (Enlaces)
			
	/**************************************************************************************************************************/
	--- Ofertas sin Descripcion al No estar adjudicadas actualizamos con AS400 

	DECLARE @Ofertas_SIN_Descripcion as varchar(5000)

	SELECT @Ofertas_SIN_Descripcion = 
		STUFF((SELECT ',' + str(CodOferta)
			   FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro v 
			   WHERE  Usuario= @Usuario AND v.DesOfer IS NULL
			  FOR XML PATH('')), 1, 1, '')
	
	CREATE TABLE #Ofertas_SIN_DESCRIPCION(CODOFER numeric(10,0), DESOFER varchar(100))
	SET @SQL_AS400='INSERT INTO #Ofertas_SIN_DESCRIPCION(CODOFER, DESOFER) SELECT CODOFER, DESOFER FROM OPENQUERY(SIC,''SELECT CDOFT as CODOFER, DCOF as DESOFER FROM S44DD901.ICOMERF.IC09AP WHERE CDOFT IN('+ @Ofertas_SIN_Descripcion+') '')'		
	EXEC (@SQL_AS400)

	UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	SET DESOFER=o.DESOFER,
		CarteraPendiente=0, Produccion_A=0, MargenProduccion_A=0, CostoTotal_A=0, PorcProduccion_A=0, Produccion=0
	FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro w INNER JOIN #Ofertas_SIN_DESCRIPCION o ON w.Codoferta=o.CODOFER
	WHERE  Usuario= @Usuario AND w.DesOfer IS NULL

	/**************************************************************************************************************************/
	--- Actualizamos la Descripcion de la Oferta con literal: (B), si esta de baja

	UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
	SET DESOFER='(Baja) ' + w.DESOFER
	FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro w INNER JOIN #OfertasDeBaja b ON w.Codoferta=b.CodOferta
	WHERE  Usuario= @Usuario

	/**************************************************************************************************************************/
	--- Actualizamos Cartera diferida Ano a 0 si no hay prevision, aunque exista contratacion
	IF @pAgrup='A'
		BEGIN
			UPDATE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
			SET A_Año=0
			FROM WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
			WHERE  Usuario= @Usuario AND MontoAnual=0
		END	

	return (0)
	
	END TRY
	BEGIN CATCH	
		return  ERROR_NUMBER ()
		--select   ERROR_MESSAGE ()
	END CATCH	
	
END

--select * from WEB_CarteraDiferidaPdteEjecutarUsuarioCentro where  codoferta='1837000002'