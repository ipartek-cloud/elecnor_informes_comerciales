
-- [dbo].[spWEB_OfertaDetalles] 947,'1094700016'

CREATE PROCEDURE [dbo].[spWEB_OfertaDetalles]
	@CodCentro varchar(3),
    @CodOferta varchar(20)
	AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vExisteOfertaSQL int
	
	BEGIN TRY		
	
		DECLARE @WEB_Ofeta_Detalle TABLE (
											CodCentro varchar(3),
											NombreCentro varchar(30),
											CodOferta varchar(10),
											DescripcionOferta varchar(50),
											Baja int,
											FAlta datetime,
											CodResponsable varchar(3),
											CodCliente varchar(8),
											NombreCliente varchar(50),
											Localidad varchar(30),											
											CodProv  varchar(2),
											NombreProvincia varchar(50),
											CodActividad varchar(4),
											NombreActividad varchar(50),
											FPresentacion datetime,
											ImporteAprox float,
											PresupuestoVenta float,
											FAdjudicacion datetime,
											Adjudicada varchar(1),
											ImporteContratado float,
											TotalOferta float,
											TotalRegularizacion float,
											Tipo varchar(8),
											EsOfertasSQL bit,
											CodObra varchar(10),
											DescripcionObra varchar(100),
											TotalProduccion float
										  )

		-- La Ofertas puede estar en Ofertas o OfertasSQL
		SELECT @vExisteOfertaSQL=Count(CodCentro) FROM dbo.OfertasSQL where CodCentro=@CodCentro and CodOferta=@CodOferta
				
		IF isnull(@vExisteOfertaSQL,0)=0 -- Ofertas
			BEGIN
				INSERT INTO @WEB_Ofeta_Detalle ([CodCentro],[CodOferta],[DescripcionOferta],[BAJA],[FAlta],[CodResponsable],[CodCliente],[Localidad],[CodProv],[CodActividad],[FPresentacion],[ImporteAprox],[PresupuestoVenta],[FAdjudicacion],[Adjudicada],[ImporteContratado],[TotalOferta],[Tipo],[EsOfertasSQL])
				SELECT [CodCentro],[CodOferta],[DescripcionOferta],dbo.fnBajaAlta([BAJA]),dbo.fgConvertirFechaDMY([FAlta]),[CodResponsable],[CodCliente],[Localidad],[CodProv],[CodActividad],dbo.fgConvertirFechaDMY([FPresentacion]),[ImporteAprox],[PresupuestoVenta],dbo.fgConvertirFechaDMY([FAdjudicacion]),[Adjudicada],[ImporteContratado],[TotalOferta],dbo.fnTipoOferta([Tipo]),0
				FROM [dbo].[vwOfertasDetalle]
				WHERE CodCentro=@CodCentro AND CodOferta=@CodOferta
			END				
		ELSE	-- OfertasSQL	
			BEGIN
				INSERT INTO @WEB_Ofeta_Detalle ([CodCentro],[CodOferta],[DescripcionOferta],[BAJA],[FAlta],[CodResponsable],[CodCliente],[Localidad],[CodProv],[CodActividad],[FPresentacion],[ImporteAprox],[PresupuestoVenta],[FAdjudicacion],[Adjudicada],[ImporteContratado],[TotalOferta],[Tipo],[EsOfertasSQL])
				SELECT [CodCentro],[CodOferta],[DescripcionOferta],dbo.fnBajaAlta([BAJA]),'',[CodResponsable],[CodCliente],[Localidad],[CodProv],[CodActividad],'',0,0,min([FAdjudicacion]),[Adjudicada],sum([ImporteContratado]),[TotalOferta],[Tipo],1
				FROM [dbo].[vwOfertasSQLDetalle]	
				WHERE CodCentro=@CodCentro AND CodOferta=@CodOferta	
				GROUP BY [CodCentro],[CodOferta],[DescripcionOferta],dbo.fnBajaAlta([BAJA]),[CodResponsable],[CodCliente],[Localidad],[CodProv],[CodActividad],[Adjudicada],[TotalOferta],[Tipo]
			END			
			
		DECLARE @CodObra varchar(10)
		DECLARE @DescripcionObra varchar(100)
		DECLARE @TotalProduccion float
		
		SELECT TOP 1 @CodObra=CodObra,@DescripcionObra=DescripcionObra,@TotalProduccion=TotalSOP
		FROM vwEnlaces_Obras
		WHERE CodCentro=@CodCentro AND CDOFT=@CodOferta
		ORDER BY ObraL		
		
		UPDATE @WEB_Ofeta_Detalle SET 
			   NombreCliente=dbo.fnNombreCliente(CodCliente),
			   NombreCentro= dbo.fnNombreCentro(CodCentro),
			   NombreProvincia=dbo.fnNombreProvincia(CodProv),
			   NombreActividad= dbo.fnNombreActividad (CodActividad),
			   TotalRegularizacion = CASE WHEN EsOfertasSQL=1 THEN 0 ELSE dbo.fnImporteRegularizacion(CodCentro,CodOferta) END,
			   CodObra=isnull(@CodObra,''),
			   DescripcionObra=isnull(@DescripcionObra,''),
			   TotalProduccion=isnull(@TotalProduccion,0)		   	
		
		SELECT * FROM @WEB_Ofeta_Detalle
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END