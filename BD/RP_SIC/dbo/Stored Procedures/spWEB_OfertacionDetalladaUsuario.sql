
CREATE PROCEDURE [dbo].[spWEB_OfertacionDetalladaUsuario]
	@Usuario varchar(50), 		
	@pAño int,
	@pEntidad varchar(10),
	@pCodEntidad int,
	@pTipoOferta varchar(15)
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY
	
	DECLARE @Usuario_Sin_Fecha varchar(50)
	DECLARE @Hoy datetime
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	SET @Hoy=convert(datetime,CONVERT(varchar(10), GETDATE(), 103),103)
	
	DELETE FROM dbo.WEB_OfertacionDetalladaUsuarioCentro WHERE Usuario like '%' + @Usuario_Sin_Fecha + '%'
	
	/* ********************************* CENTROS ASIGNADOS *********************************** */	
	
	--DECLARE @vCentrosEntidad TABLE (CodCentro varchar(3))
	CREATE TABLE #vCentrosEntidad (CodCentro varchar(3))
	
	IF @pEntidad='DEL'	
		INSERT INTO #vCentrosEntidad(CodCentro)			
		SELECT CodCentro FROM dbo.WEB_OfertacionUsuarioCentro WHERE CodDelegacion = @pCodEntidad AND Usuario= @Usuario		
	ELSE IF @pEntidad='CT'
		INSERT INTO #vCentrosEntidad(CodCentro)			
		SELECT CodCentro FROM dbo.WEB_OfertacionUsuarioCentro WHERE CodCentro = @pCodEntidad AND Usuario= @Usuario	
		
	/* ****************************** IMPORTES d CENTRO DENTRO d PERIODO *********************************** */	
	
		IF @pTipoOferta='Abierta'
			BEGIN
			   --- OFERTAS 	
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  1,@Usuario,vwWEB_OFERTAS_OF.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
			   FROM vwWEB_OFERTAS_OF INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS_OF.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  year(FAlta)=@pAño	 
			
			   -- REGULARIZACIONES
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  2,@Usuario,vwWEB_REG.CodCentro,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,'S',CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   FROM vwWEB_REG INNER JOIN #vCentrosEntidad ON vwWEB_REG.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  year(FAlta)=@pAño
			 
			   -- OFERTASsql
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  3,@Usuario,OfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAlta,ImporteAprox,FPresentacion,PresupuestoVenta, FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   FROM OfertasSQL INNER JOIN #vCentrosEntidad ON OfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  year(FAlta)=@pAño	   
			END
		ELSE IF @pTipoOferta='PdtePresentar'
			BEGIN
			   --- OFERTAS 	
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  1,@Usuario,vwWEB_OFERTAS_OF.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
			   FROM vwWEB_OFERTAS_OF INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS_OF.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  (FPresentacion >@Hoy AND ISNULL(FAdjudicacion,'')='')
					   OR
			          (year(FAlta)=@pAño AND ISNULL(FPresentacion,'')='' AND ISNULL(FAdjudicacion,'')='') 	 
			
			   -- REGULARIZACIONES
			   --INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   --SELECT  2,@Usuario,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,'S',CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   --FROM vwWEB_REG INNER JOIN @vCentrosEntidad ON vwWEB_REG.CodCentro=[@vCentrosEntidad].CodCentro
			   --WHERE  year(FPresentacion)=@pAño AND FPresentacion <@Hoy AND ISNULL(FAdjudicacion,'')=''	 	 
			 
			   -- OFERTASsql
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  3,@Usuario,OfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAlta,ImporteAprox,FPresentacion,PresupuestoVenta, FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   FROM OfertasSQL INNER JOIN #vCentrosEntidad ON OfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  (FPresentacion >@Hoy AND ISNULL(FAdjudicacion,'')='')
					   OR
			          (year(FAlta)=@pAño AND ISNULL(FPresentacion,'')='' AND ISNULL(FAdjudicacion,'')='') 	 	 	 
			END
		ELSE IF @pTipoOferta='PdteDecidir'
			BEGIN
			   --- OFERTAS 	
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  1,@Usuario,vwWEB_OFERTAS_OF.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
			   FROM vwWEB_OFERTAS_OF INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS_OF.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  FPresentacion <=@Hoy AND ISNULL(FAdjudicacion,'')='' AND Adjudicada <>'N'
			
			   -- REGULARIZACIONES
			   --INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   --SELECT  2,@Usuario,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,'S',CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   --FROM vwWEB_REG INNER JOIN @vCentrosEntidad ON vwWEB_REG.CodCentro=[@vCentrosEntidad].CodCentro
			   --WHERE  year(FPresentacion)=@pAño AND FPresentacion >=@Hoy AND ISNULL(FAdjudicacion,'')=''	 	 
			 
			   -- OFERTASsql
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  3,@Usuario,OfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAlta,ImporteAprox,FPresentacion,PresupuestoVenta, FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   FROM OfertasSQL INNER JOIN #vCentrosEntidad ON OfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE FPresentacion <=@Hoy AND ISNULL(FAdjudicacion,'')='' AND Adjudicada <>'N'	 	 
			END
		ELSE IF @pTipoOferta='Denegada'
			BEGIN
			   --- OFERTAS 	
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  1,@Usuario,vwWEB_OFERTAS_OF.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
			   FROM vwWEB_OFERTAS_OF INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS_OF.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  year(isnull(FAdjudicacion,FAltaSistema))=@pAño AND Adjudicada='N'	 
			
			   -- REGULARIZACIONES
			   --INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   --SELECT  2,@Usuario,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,'S',CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   --FROM vwWEB_REG INNER JOIN @vCentrosEntidad ON vwWEB_REG.CodCentro=[@vCentrosEntidad].CodCentro
			   --WHERE  year(FAdjudicacion)=@pAño  
			 
			   -- OFERTASsql
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  3,@Usuario,OfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAlta,ImporteAprox,FPresentacion,PresupuestoVenta, FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   FROM OfertasSQL INNER JOIN #vCentrosEntidad ON OfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  year(FAdjudicacion)=@pAño AND Adjudicada='N'	 
			END
		ELSE IF @pTipoOferta='Adjudicada'
			BEGIN
			   --- OFERTAS 	
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  1,@Usuario,vwWEB_OFERTAS_OF.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
			   FROM vwWEB_OFERTAS_OF INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS_OF.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  year(FAdjudicacion)=@pAño AND Adjudicada='S'	 
						
			   -- REGULARIZACIONES
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  2,@Usuario,vwWEB_REG.CodCentro,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,'S',CodResponsable,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   FROM vwWEB_REG INNER JOIN #vCentrosEntidad ON vwWEB_REG.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  year(FAdjudicacion)=@pAño AND ISNULL(FAdjudicacion,'')<>''
						 
			   -- OFERTASsql
			   INSERT INTO WEB_OfertacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAlta,ImporteAlta,FPresentacion,ImportePresentacion,FAdjudicacion,ImporteContratado,Adjudicada,CodResponsable,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			   SELECT  3,@Usuario,OfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAlta,isnull(ImporteAprox,0),FPresentacion,isnull(PresupuestoVenta,0), FAdjudicacion,isnull(ImporteContratado,0),Adjudicada,isnull(CodResponsable,''),isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			   FROM OfertasSQL INNER JOIN #vCentrosEntidad ON OfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
			   WHERE  year(FAdjudicacion)=@pAño AND Adjudicada='S'	 
					   
			END
			
	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha		
	
	/* ********************************* RESULTADO *********************************** */	
	--SELECT WEB_OfertacionDetalladaUsuarioCentro.*  
	--FROM WEB_OfertacionDetalladaUsuarioCentro
	--WHERE Usuario = @Usuario
	--ORDER BY CodOferta,Regularizacion
		
	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH		
		return ERROR_NUMBER ()
	END CATCH
	
END