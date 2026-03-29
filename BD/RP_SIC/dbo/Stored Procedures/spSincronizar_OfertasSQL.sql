CREATE PROCEDURE [dbo].[spSincronizar_OfertasSQL]
	@pAño int,
	@pMes int 	
		AS
BEGIN
	
	--SET NOCOUNT ON;
		
	BEGIN TRY
	
		DELETE FROM dbo.OfertasSQL WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion)=@pMes AND Reparto=1

		INSERT INTO [RP_SIC].[dbo].[ofertasSQL]([CodCentro_Origen],[CodCentro],[CodOferta],[NumRegularizacion],[FAlta],[DescripcionOferta],[CodCliente],[Localidad],[CodProv],[ImporteAprox],[CodAct1],[CodAct2],[CodResponsable],[FPresentacion],[PresupuestoVenta],[FAdjudicacion],[AñoAdjudicacion],[Adjudicada],[ImporteContratado],Reparto)
		SELECT [CodCentro_Origen],[CodCentro],[CodOferta],[NumRegularizacion],[FAlta],[DescripcionOferta],[CodCliente],[Localidad],[CodProv],[ImporteAprox],[CodAct1],[CodAct2],[CodResponsable],[FPresentacion],[PresupuestoVenta],[FAdjudicacion],[AñoAdjudicacion],[Adjudicada],[ImporteContratado],1
		FROM dbo.vwOfertasReparto
		WHERE AñoAdjudicacion = @pAño AND MesAdjudicacion= @pMes

		INSERT INTO [RP_SIC].[dbo].[ofertasSQL]([CodCentro_Origen],[CodCentro],[CodOferta],[NumRegularizacion],[FAlta],[DescripcionOferta],[CodCliente],[Localidad],[CodProv],[ImporteAprox],[CodAct1],[CodAct2],[CodResponsable],[FPresentacion],[PresupuestoVenta],[FAdjudicacion],[AñoAdjudicacion],[Adjudicada],[ImporteContratado],Reparto)
		SELECT [CodCentro_Origen],[CodCentro],[CodOferta],[NumRegularizacion],[FAlta],[DescripcionOferta],[CodCliente],[Localidad],[CodProv],[ImporteAprox],[CodAct1],[CodAct2],[CodResponsable],[FPresentacion],[PresupuestoVenta],[FAdjudicacion],[AñoAdjudicacion],[Adjudicada],[ImporteContratado],1
		FROM dbo.vwRegularizacionesReparto
		WHERE AñoAdjudicacion = @pAño AND MesAdjudicacion= @pMes
    
		select 0 -- NO ERROR
   
	END TRY
	BEGIN CATCH
		select ERROR_NUMBER ()
	END CATCH
    
END
