
--	exec spWEB_ContratacionActividadDetalladaUsuario 'anruiz_2048', 2018,5,'AGRP',-1,'Ferrocarriles',''
-- 
/*
select round(sum(I)/1000,0) from (
select sum(ImporteContratado) as I FROM vwWEB_OFERTAS WHERE  year(FAdjudicacion)=2018 AND month(FAdjudicacion) <= 5 AND Agrupacion='Ferrocarriles'
UNION
select sum(ImporteContratado) as I FROM vwWEB_REG WHERE  year(FAdjudicacion)=2018 AND month(FAdjudicacion) <= 5  AND Agrupacion='Ferrocarriles'
UNION
select sum(ImporteContratado) as I FROM vwOfertasSQL WHERE  year(FAdjudicacion)=2018 AND month(FAdjudicacion) <= 5 AND Agrupacion='Ferrocarriles') vw
*/

CREATE PROCEDURE [dbo].[spWEB_ContratacionActividadDetalladaUsuario]
	@Usuario varchar(50), 		
	@pAño int,
	@pMes int,
	@pEntidad varchar(10),
	@pCodEntidad int,
	@pAgrupacion varchar(50),
	@pDescripcion varchar(50),
	@pMesActual int,
	@pAcumulado int
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

	IF  @pMesActual= 0 -- Mes Anterior
		BEGIN
			SET @pMes= @pMes-1
		END
	
	/* ********************************* CENTROS ASIGNADOS *********************************** */	
	
	CREATE TABLE #vCentrosEntidad (CodCentro varchar(3))
	
	IF @pEntidad='AGRP'
		INSERT INTO #vCentrosEntidad(CodCentro)		
		SELECT CodCentro FROM dbo.WEB_ContratacionActividadUsuarioCentro WHERE Agrupacion=@pAgrupacion AND Usuario= @Usuario GROUP BY CodCentro			
	ELSE IF @pEntidad='DSACT'
		INSERT INTO #vCentrosEntidad(CodCentro)				
		SELECT CodCentro FROM dbo.WEB_ContratacionActividadUsuarioCentro WHERE DSACT = @pDescripcion AND Usuario= @Usuario	
	ELSE IF @pEntidad='DEL'	
		INSERT INTO #vCentrosEntidad(CodCentro)			
		SELECT CodCentro FROM dbo.WEB_ContratacionActividadUsuarioCentro WHERE  DSACT = @pDescripcion AND CodDelegacion = @pCodEntidad AND Usuario= @Usuario		
	ELSE IF @pEntidad='CT'
		INSERT INTO #vCentrosEntidad(CodCentro)			
		SELECT CodCentro FROM dbo.WEB_ContratacionActividadUsuarioCentro WHERE  DSACT = @pDescripcion AND CodCentro = @pCodEntidad AND Usuario= @Usuario	
		
	/* ****************************** IMPORTES d CENTRO DENTRO d PERIODO *********************************** */	

	IF @pEntidad='AGRP' -- Filtro Año+Mes+Agrupacion
		BEGIN
			IF @pAcumulado=1
				BEGIN
					-- OFERTAS
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  1 as Tipo,@Usuario,vwWEB_OFERTAS.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
					FROM vwWEB_OFERTAS INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes AND Agrupacion=@pAgrupacion
		
					-- REGULARIZACIONES
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  2,@Usuario,vwWEB_REG.CodCentro,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
					FROM vwWEB_REG INNER JOIN #vCentrosEntidad ON vwWEB_REG.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes AND Agrupacion=@pAgrupacion
	
					-- OFERTASsql
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  3,@Usuario,vwOfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAdjudicacion, ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
					FROM vwOfertasSQL INNER JOIN #vCentrosEntidad ON vwOfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes AND Agrupacion=@pAgrupacion		
				END
			ELSE
				BEGIN
					-- OFERTAS
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  1 as Tipo,@Usuario,vwWEB_OFERTAS.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
					FROM vwWEB_OFERTAS INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes AND Agrupacion=@pAgrupacion
		
					-- REGULARIZACIONES
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  2,@Usuario,vwWEB_REG.CodCentro,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
					FROM vwWEB_REG INNER JOIN #vCentrosEntidad ON vwWEB_REG.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes AND Agrupacion=@pAgrupacion
	
					-- OFERTASsql
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  3,@Usuario,vwOfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAdjudicacion, ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
					FROM vwOfertasSQL INNER JOIN #vCentrosEntidad ON vwOfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes AND Agrupacion=@pAgrupacion		
				END	
		END
	ELSE	-- Filtro Año+Mes+Descripcion
		BEGIN	
			IF @pAcumulado=1
				BEGIN				
					-- OFERTAS
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  1 as Tipo,@Usuario,vwWEB_OFERTAS.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
					FROM vwWEB_OFERTAS INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes AND Descripcion=@pDescripcion		
					-- REGULARIZACIONES
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  2,@Usuario,vwWEB_REG.CodCentro,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
					FROM vwWEB_REG INNER JOIN #vCentrosEntidad ON vwWEB_REG.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes AND Descripcion=@pDescripcion
					-- OFERTASsql
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  3,@Usuario,vwOfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAdjudicacion, ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
					FROM vwOfertasSQL INNER JOIN #vCentrosEntidad ON vwOfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) <= @pMes AND Descripcion=@pDescripcion						
				END
			ELSE
				BEGIN
					-- OFERTAS
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  1 as Tipo,@Usuario,vwWEB_OFERTAS.CodCentro,isnull(CodOferta,0),0,'',isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2		
					FROM vwWEB_OFERTAS INNER JOIN #vCentrosEntidad ON vwWEB_OFERTAS.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes AND Descripcion=@pDescripcion		
					-- REGULARIZACIONES
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  2,@Usuario,vwWEB_REG.CodCentro,isnull(CodOferta,0),NumRegularizacion,Caus,isnull(CodCliente,''),FAdjudicacion,ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
					FROM vwWEB_REG INNER JOIN #vCentrosEntidad ON vwWEB_REG.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes AND Descripcion=@pDescripcion
					-- OFERTASsql
					INSERT INTO WEB_ContratacionDetalladaUsuarioCentro(Tipo,Usuario,CodCentro,CodOferta,Regularizacion,CausaRegularizacion,CodCliente,FAdjudicacion,ImporteContratado,DescripcionOferta,Localidad,CodProv,CodAct1,CodAct2)	
					SELECT  3,@Usuario,vwOfertasSQL.CodCentro,isnull(CodOferta,0),isnull(NumRegularizacion,0),'',isnull(CodCliente,''),FAdjudicacion, ImporteContratado,isnull(DescripcionOferta,''),isnull(Localidad,''),CodProv,CodAct1,CodAct2
					FROM vwOfertasSQL INNER JOIN #vCentrosEntidad ON vwOfertasSQL.CodCentro=[#vCentrosEntidad].CodCentro
					WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes AND Descripcion=@pDescripcion	
				END						
		END	
		
	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	

	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha		

	/* ********************************* RESULTADO *********************************** */	

	/*	

	SELECT CodCentro FROM #vCentrosEntidad
	
	SELECT WEB_ContratacionDetalladaUsuarioCentro.*  
	FROM WEB_ContratacionDetalladaUsuarioCentro
	WHERE Usuario = @Usuario 
	ORDER BY CodOferta,Regularizacion 	
		
	*/

	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH		
		return ERROR_NUMBER ()
	END CATCH
	
END
