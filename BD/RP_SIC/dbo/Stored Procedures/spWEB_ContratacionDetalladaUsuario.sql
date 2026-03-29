
CREATE PROCEDURE [dbo].[spWEB_ContratacionDetalladaUsuario]
	@Usuario varchar(50), 		
	@pAño int,
	@pMes int,
	@pAcumulado bit,
	@pEntidad varchar(10),
	@pCodEntidad varchar(3)
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY
	
	DECLARE @Usuario_Sin_Fecha varchar(50)	
	DECLARE @Posicion as int
	
	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	DELETE FROM dbo.WEB_ContratacionDetalladaUsuarioCentro WHERE Usuario like '%' + @Usuario_Sin_Fecha + '%'
	
	/* ********************************* CENTROS ASIGNADOS *********************************** */	
	
	--DECLARE @vCentrosEntidad TABLE (CodCentro varchar(3))
	CREATE TABLE #vCentrosEntidad (CodCentro varchar(3))
	
	IF @pEntidad='DG'
		INSERT INTO #vCentrosEntidad(CodCentro)		
		SELECT CodCentro FROM dbo.WEB_ContratacionUsuarioCentro WHERE CodDirGeneral = @pCodEntidad AND Usuario= @Usuario			
	ELSE IF @pEntidad='SDG'
		INSERT INTO #vCentrosEntidad(CodCentro)				
		SELECT CodCentro FROM dbo.WEB_ContratacionUsuarioCentro WHERE CodSubDirGeneral = @pCodEntidad AND Usuario= @Usuario			
	ELSE IF @pEntidad='DN'	
		INSERT INTO #vCentrosEntidad(CodCentro)			
		SELECT CodCentro FROM dbo.WEB_ContratacionUsuarioCentro WHERE CodDDirNegocio = @pCodEntidad AND Usuario= @Usuario		
	ELSE IF @pEntidad='AREA'
		INSERT INTO #vCentrosEntidad(CodCentro)				
		SELECT CodCentro FROM dbo.WEB_ContratacionUsuarioCentro WHERE CodSubDirNegocioArea = @pCodEntidad AND Usuario= @Usuario		
	ELSE IF @pEntidad='DEL'	
		INSERT INTO #vCentrosEntidad(CodCentro)			
		SELECT CodCentro FROM dbo.WEB_ContratacionUsuarioCentro WHERE CodDelegacion = @pCodEntidad AND Usuario= @Usuario		
	ELSE IF @pEntidad='CT'
		INSERT INTO #vCentrosEntidad(CodCentro)			
		SELECT CodCentro FROM dbo.WEB_ContratacionUsuarioCentro WHERE CodCentro = @pCodEntidad AND Usuario= @Usuario	
		
	/* ****************************** IMPORTES d CENTRO DENTRO d PERIODO *********************************** */
	

	-- OFERTAS 
	IF @pAcumulado =1
		BEGIN
			INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			SELECT  1,@Usuario,vwWEB_OFERTAS.CodCentro,isnull(CodOferta,''),0,'',isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
			FROM vwWEB_OFERTAS INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS.CodCentro=[#vCentrosEntidad].CodCentro
			WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes 
		END
	ELSE	
		BEGIN
			INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			SELECT  1,@Usuario,vwWEB_OFERTAS.CodCentro,isnull(CodOferta,''),0,'',isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
			FROM vwWEB_OFERTAS INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS.CodCentro=[#vCentrosEntidad].CodCentro
			WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes 
		END	
	
	-- REGULARIZACIONES
	IF @pAcumulado =1
		BEGIN
			INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			SELECT  2,@Usuario,vwWEB_REG.CodCentro,isnull(CodOferta,''),NumRegularizacion,Caus,isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			FROM vwWEB_REG INNER JOIN #vCentrosEntidad ON vwWEB_REG.CodCentro=[#vCentrosEntidad].CodCentro
			WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes 
		END
	ELSE
		BEGIN
			INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			SELECT  2,@Usuario,vwWEB_REG.CodCentro,isnull(CodOferta,''),NumRegularizacion,Caus,isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
			FROM vwWEB_REG INNER JOIN #vCentrosEntidad ON vwWEB_REG.CodCentro=[#vCentrosEntidad].CodCentro
			WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes
		END
	
	-- OFERTASsql
	IF @pAcumulado =1
		BEGIN
			INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			SELECT  3,@Usuario,OfertasSQL.CodCentro,isnull(CodOferta,''),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
			FROM OfertasSQL INNER JOIN #vCentrosEntidad ON OfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
			WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes 			
		END
	ELSE
		BEGIN
			INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
			SELECT  3,@Usuario,OfertasSQL.CodCentro,isnull(CodOferta,''),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2			
			FROM OfertasSQL INNER JOIN #vCentrosEntidad ON OfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
			WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes 
		END
		
	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha	
	
	/* ********************************* RESULTADO *********************************** */	
	--SELECT WEB_ContratacionDetalladaUsuarioCentro.*  
	--FROM WEB_ContratacionDetalladaUsuarioCentro
	--WHERE Usuario = @Usuario
	--ORDER BY CodOferta,Regularizacion
		
	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH		
		return ERROR_NUMBER ()
	END CATCH
	
END