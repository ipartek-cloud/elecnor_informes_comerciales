CREATE PROCEDURE [dbo].[spObrasParaClasificacion]
	
AS
BEGIN
		SET NOCOUNT ON;

		DELETE FROM [dbo].[ObrasParaClasificacion]

		CREATE TABLE #ObrasParaClasificacion(	
			CodCentro varchar(3),
			Obra decimal(3, 0) ,
			ObraL decimal(3, 0) ,
			NomObra nvarchar(150) ,
			NombreCliente nvarchar(150) ,
			CIF nvarchar(12) ,
			PreFact_2014 float ,
			Prod_2014 float ,
			Fact_2014 float ,
			Estado_2014	nvarchar(1),
			PreFact_2015 float ,			
			Prod_2015 float ,
			Fact_2015 float ,
			Estado_2015	nvarchar(1),
			PreFact_2016 float ,
			Prod_2016 float ,			
			Fact_2016 float,
			Estado_2016	nvarchar(1),
			PreFact_2017 float ,
			Prod_2017 float ,
			Fact_2017 float,
			Estado_2017	nvarchar(1),
			PreFact_2018 float ,
			Prod_2018 float ,
			Fact_2018 float,
			Estado_2018	nvarchar(1),
			Actividad int 
			)

		INSERT INTO #ObrasParaClasificacion([CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PreFact_2014],[Prod_2014],[Fact_2014], Estado_2014,Actividad)
		SELECT [CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PresupuestoFacturacion],[Produccion],[Facturacion],Estado,Actividad
		FROM [RP_SIC].[dbo].[vwObrasActualesSQL_Clientes_Mes12]
		WHERE año=2014

		INSERT INTO #ObrasParaClasificacion([CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PreFact_2015],[Prod_2015],[Fact_2015], Estado_2015,Actividad)
		SELECT [CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PresupuestoFacturacion],[Produccion],[Facturacion],Estado,Actividad
		FROM [RP_SIC].[dbo].[vwObrasActualesSQL_Clientes_Mes12]
		WHERE año=2015

		INSERT INTO #ObrasParaClasificacion([CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PreFact_2016],[Prod_2016],[Fact_2016], Estado_2016,Actividad)
		SELECT [CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PresupuestoFacturacion],[Produccion],[Facturacion],Estado,Actividad
		FROM [RP_SIC].[dbo].[vwObrasActualesSQL_Clientes_Mes12]
		WHERE año=2016

		INSERT INTO #ObrasParaClasificacion([CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PreFact_2017],[Prod_2017],[Fact_2017], Estado_2017,Actividad)
		SELECT [CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PresupuestoFacturacion],[Produccion],[Facturacion],Estado,Actividad
		FROM [RP_SIC].[dbo].[vwObrasActualesSQL_Clientes_Mes12]
		WHERE año=2017 

		INSERT INTO #ObrasParaClasificacion([CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PreFact_2018],[Prod_2018],[Fact_2018], Estado_2018,Actividad)
		SELECT [CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PresupuestoFacturacion],[Produccion],[Facturacion],Estado,Actividad
		FROM [RP_SIC].[dbo].[vwObrasActualesSQL_Clientes_Mes12]
		WHERE año=2018 

		INSERT INTO [dbo].[ObrasParaClasificacion]([CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],[PreFact_2014],[Prod_2014],[Fact_2014],[Estado_2014],[PreFact_2015],[Prod_2015],[Fact_2015],[Estado_2015],[PreFact_2016],[Prod_2016],[Fact_2016],[Estado_2016],[PreFact_2017],[Prod_2017],[Fact_2017],[Estado_2017],[PreFact_2018],[Prod_2018],[Fact_2018],[Estado_2018],Actividad)
		SELECT [CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF]
			  ,isnull(sum([PreFact_2014]),0) as PreFact_2014
			  ,isnull(sum([Prod_2014]),0) as Prod_2014
			  ,isnull(sum([Fact_2014]),0) as Fact_2014
			  ,isnull(max([Estado_2014]),'') as Estado_2014
			  ,isnull(sum([PreFact_2015]),0) as PreFact_2015
			  ,isnull(sum([Prod_2015]),0) as Prod_2015
			  ,isnull(sum([Fact_2015]),0) as Fact_2015
			  ,isnull(max([Estado_2015]),'') as Estado_2015
			  ,isnull(sum([PreFact_2016]),0) as PreFact_2016
			  ,isnull(sum([Prod_2016]),0) as Prod_2016
			  ,isnull(sum([Fact_2016]),0) as Fact_2016
			  ,isnull(max([Estado_2016]),'') as Estado_2016
			  ,isnull(sum([PreFact_2017]),0) as PreFact_2017
			  ,isnull(sum([Prod_2017]),0) as Prod_2017
			  ,isnull(sum([Fact_2017]),0) as Fact_2017	
			  ,isnull(max([Estado_2017]),'') as Estado_2017
			  ,isnull(sum([PreFact_2018]),0) as PreFact_2018
			  ,isnull(sum([Prod_2018]),0) as Prod_2018
			  ,isnull(sum([Fact_2018]),0) as Fact_2018	
			  ,isnull(max([Estado_2018]),'') as Estado_2018
			  ,Actividad			 
		FROM #ObrasParaClasificacion
		GROUP BY [CodCentro],[Obra],[ObraL],[NomObra],[NombreCliente],[CIF],Actividad
		ORDER BY CodCentro, NombreCliente

		DROP TABLE #ObrasParaClasificacion

END
