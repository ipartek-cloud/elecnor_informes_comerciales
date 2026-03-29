CREATE PROCEDURE [dbo].[spWEB_OfertacionUsuario]
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
	DECLARE @Hoy datetime
	DECLARE @Posicion as int
	
	SET @Hoy=convert(datetime,CONVERT(varchar(10), GETDATE(), 103),103)
	
	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario
	
	SELECT @Usuario_Puesto=Puesto, @Usuario_CodEntidad=CodEntidad FROM dbo.WEB_Usuarios WHERE Usuario=@Usuario_Sin_Fecha	
	IF isnull(@Usuario_Puesto,'')='' RETURN -99999
	
	/* ***************************** OFERTAS BASE A PARTIR de 2012 **************************** */	
    
	--DELETE FROM WEB_OFERTACION WHERE Usuario like '%' +@Usuario_Sin_Fecha + '%'	
	DELETE FROM WEB_OFERTACION WHERE Usuario like @Usuario_Sin_Fecha + '%'	
	
	INSERT INTO WEB_OFERTACION (Usuario,CDCEN,CDOFT,FECHAA,IMAOF,FECHPP,PREVE,FECHAD,ADELE,PREAD)
    SELECT @Usuario,CDCEN,CDOFT,FECHAA,IMAOF,FECHPP,PREVE,FECHAD,ADELE,PREAD
    FROM dbo.vwWEB_OFERTACION	

	/* ****************************** IMPORTES d CENTRO DENTRO d PERIODO *********************************** */
	
	--DELETE FROM WEB_OfertacionUsuarioCentro_TMP WHERE Usuario like '%' +@Usuario_Sin_Fecha + '%'
	--DELETE FROM WEB_OfertacionUsuarioCentro WHERE Usuario like '%' +@Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_OfertacionUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_OfertacionUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'
	
	-- ABIERTAS
	INSERT INTO WEB_OfertacionUsuarioCentro_TMP(Usuario,CodCentro,Cantidad_Abiertas,Monto_Abiertas)	
	SELECT  @Usuario,CodCentro,count(CodOferta),sum(Importe)			
	FROM  dbo.vwWEB_OF_Abiertas
	WHERE Usuario=@Usuario AND (year(Fecha)=@pAño AND month(Fecha) <= @pMes)
	GROUP BY CodCentro
	
	-- PDTES PRESENTACION
	INSERT INTO WEB_OfertacionUsuarioCentro_TMP(Usuario,CodCentro,Cantidad_PdtesPresentar,Monto_PdtesPresentar)	
	SELECT  @Usuario,CodCentro,count(CodOferta),sum(Importe)
	FROM  dbo.vwWEB_OF_PdtesPresentar_PdtesDecidir
	WHERE (Usuario=@Usuario) AND (
									(Fecha >@Hoy)
	                                 OR
	                                ((year(FechaAlta)=@pAño AND month(FechaAlta) <= @pMes) AND ISNULL(Fecha,'')='' AND ISNULL(FechaAdjudicacion,'')='')
	                              )
	GROUP BY CodCentro	
	
	-- PDTES DECIDIR
	INSERT INTO WEB_OfertacionUsuarioCentro_TMP(Usuario,CodCentro,Cantidad_PdtesDecidir,Monto_PdtesDecidir)	
	SELECT  @Usuario,CodCentro,count(CodOferta),sum(Importe)			
	FROM  dbo.vwWEB_OF_PdtesPresentar_PdtesDecidir
	WHERE Usuario=@Usuario AND Fecha <=@Hoy 
	GROUP BY CodCentro	
	
	-- DENEGADAS
	INSERT INTO WEB_OfertacionUsuarioCentro_TMP(Usuario,CodCentro,Cantidad_Denegadas,Monto_Denegadas)	
	SELECT  @Usuario,CodCentro,count(CodOferta),sum(Importe)			
	FROM  dbo.vwWEB_OF_Denegadas_Adjudicadas
	WHERE (Usuario=@Usuario) AND ((year(Fecha)=@pAño AND month(Fecha) <= @pMes))
	GROUP BY CodCentro
	
	-- ADJUDICADAS
	   -- Ofertas
		  INSERT INTO WEB_OfertacionUsuarioCentro_TMP(Usuario,CodCentro,Cantidad_Adjudicadas,Monto_Adjudicadas)	
		  SELECT  @Usuario,CodCentro,count(CodOferta),sum(Importe)			
		  FROM  dbo.vwWEB_OF_Denegadas_Adjudicadas
		  WHERE (Usuario=@Usuario) AND ((year(Fecha)=@pAño AND month(Fecha) <= @pMes) AND (Adjudicada='S'))
		  GROUP BY CodCentro
	   -- Regularizaciones
/*
Paco 2015-10-05
		  INSERT INTO WEB_OfertacionUsuarioCentro_TMP(Usuario,CodCentro,Cantidad_Adjudicadas,Monto_Adjudicadas)
		  SELECT  @Usuario,Regularizaciones.CDCEN, count(Regularizaciones.CdOft),sum(Regularizaciones.IMPRE)
		  FROM dbo.Ofertas INNER JOIN dbo.Regularizaciones ON dbo.Ofertas.CDOFT = dbo.Regularizaciones.CDOFT
          --WHERE year(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR))=@pAño and month(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR))<=@pMes
          WHERE dbo.Regularizaciones.AñoR=@pAño and dbo.Regularizaciones.MesR<=@pMes
          GROUP BY Regularizaciones.CDCEN
*/
		  INSERT INTO WEB_OfertacionUsuarioCentro_TMP(Usuario,CodCentro,Cantidad_Adjudicadas,Monto_Adjudicadas)
		  SELECT  @Usuario,CDCEN, count(CdOft),sum(IMPRE)
		  FROM dbo.Ofertas_Regularizaciones
          WHERE year(dbo.fgConvertirFechaDMY(FECHAR))=@pAño and month(dbo.fgConvertirFechaDMY(FECHAR))<=@pMes
          GROUP BY CDCEN
-------------------------------------
	   -- OfertasSQL
		  INSERT INTO WEB_OfertacionUsuarioCentro_TMP(Usuario,CodCentro,Cantidad_Adjudicadas,Monto_Adjudicadas)	
		  SELECT  @Usuario,CodCentro,count(idOfertasSQL),sum(ImporteContratado)
		  FROM    dbo.OfertasSQL 
		  WHERE  AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes 
		  GROUP BY CodCentro	   
		
	/* ********************************* CENTROS ASIGNADOS *********************************** */	
	
	--DECLARE @vCentrosAsignadosUsuario TABLE (CodCentro varchar(3))
	CREATE TABLE #vCentrosAsignadosUsuario (CodCentro varchar(3))
	
	IF @Usuario_Puesto='DG'
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)		
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodDirGeneral = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='SDG'
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)				
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodSubDirGeneral = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='DN'	
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)			
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodDDirNegocio = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='AREA'
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)				
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodSubDirNegocioArea = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='DEL'	
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)			
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodDelegacion = @Usuario_CodEntidad		
	ELSE IF @Usuario_Puesto='CT'
		INSERT INTO #vCentrosAsignadosUsuario(CodCentro)				
		SELECT CodCentro FROM dbo.Sumarigrama WHERE CodCentro = @Usuario_CodEntidad		
	ELSE		
		RETURN	-999999
	
	/* **************************** SUMARIGRAMA CON IMPORTES-OBJETIVOS d CENTROS ASIGNADOS *************************** */
	
	-- Insertamos Centros + Importes	
	INSERT INTO WEB_OfertacionUsuarioCentro (Usuario,Año,Mes,CodCentro,Cantidad_Abiertas,Monto_Abiertas,Cantidad_PdtesPresentar,Monto_PdtesPresentar,Cantidad_PdtesDecidir,Monto_PdtesDecidir,Cantidad_Denegadas,Monto_Denegadas,Cantidad_Adjudicadas,Monto_Adjudicadas)	
	SELECT @Usuario,@pAño,@pMes,WEB_OfertacionUsuarioCentro_TMP.CodCentro,
		   (Sum(Cantidad_Abiertas)),
		   (Sum(Monto_Abiertas)/1000),
		   (Sum(Cantidad_PdtesPresentar)),
		   (Sum(Monto_PdtesPresentar)/1000),
		   (Sum(Cantidad_PdtesDecidir)),
		   (Sum(Monto_PdtesDecidir)/1000),
		   (Sum(Cantidad_Denegadas)),
		   (Sum(Monto_Denegadas)/1000),
		   (Sum(Cantidad_Adjudicadas)),
		   (Sum(Monto_Adjudicadas)/1000)		   
	FROM WEB_OfertacionUsuarioCentro_TMP INNER JOIN #vCentrosAsignadosUsuario ON WEB_OfertacionUsuarioCentro_TMP.CodCentro=	[#vCentrosAsignadosUsuario].CodCentro
	WHERE Usuario=@Usuario 
	GROUP BY WEB_OfertacionUsuarioCentro_TMP.CodCentro
		
	-- Insertamos Centros SIN Contratacion pero que pueden tener Objetivos
	INSERT INTO WEB_OfertacionUsuarioCentro (Usuario,Año,Mes,CodCentro,Cantidad_Abiertas,Monto_Abiertas,Cantidad_PdtesPresentar,Monto_PdtesPresentar,Cantidad_PdtesDecidir,Monto_PdtesDecidir,Cantidad_Denegadas,Monto_Denegadas,Cantidad_Adjudicadas,Monto_Adjudicadas)	
	SELECT @Usuario,@pAño,@pMes,[#vCentrosAsignadosUsuario].CodCentro,0,0,0,0,0,0,0,0,0,0
	FROM #vCentrosAsignadosUsuario LEFT JOIN 
		( SELECT WEB_OfertacionUsuarioCentro.* 
		  FROM WEB_OfertacionUsuarioCentro
		  WHERE Usuario=@Usuario) w ON w.CodCentro=[#vCentrosAsignadosUsuario].CodCentro
	WHERE  isnull(Usuario,'')=''
	GROUP BY [#vCentrosAsignadosUsuario].CodCentro,Usuario
	
	-- Actualizamos Sumarigrama de Centros Asigandos a Usuario
	UPDATE WEB_OfertacionUsuarioCentro 
	SET CodDirGeneral=dbo.Sumarigrama.CodDirGeneral,
		NombreDirGeneral=dbo.Sumarigrama.NombreDirGeneral,
		CodSubDirGeneral=dbo.Sumarigrama.CodSubDirGeneral, 
        NombreSubDirGeneral= dbo.Sumarigrama.NombreSubDirGeneral,
        CodDDirNegocio=dbo.Sumarigrama.CodDDirNegocio,
        NombreDirNegocio=dbo.Sumarigrama.NombreDirNegocio, 
        CodSubDirNegocioArea=dbo.Sumarigrama.CodSubDirNegocioArea,
        NombreSubDirNegocioArea=dbo.Sumarigrama.NombreSubDirNegocioArea,
        CodDelegacion=dbo.Sumarigrama.CodDelegacion, 
        NombreDelegacion=dbo.Sumarigrama.NombreDelegacion,
        NombreCentro=dbo.Sumarigrama.NombreCentro
	FROM dbo.Sumarigrama		
	WHERE  dbo.WEB_OfertacionUsuarioCentro.CodCentro = dbo.Sumarigrama.CodCentro AND dbo.WEB_OfertacionUsuarioCentro.Usuario = @Usuario			
	
	/* ******************************* BORRAMOS TEMPORAL ***************************** */
	--DELETE FROM WEB_OfertacionUsuarioCentro_TMP WHERE Usuario like '%' +@Usuario_Sin_Fecha + '%'
	DELETE FROM WEB_OfertacionUsuarioCentro_TMP WHERE Usuario like @Usuario_Sin_Fecha + '%'
	--DELETE FROM WEB_OFERTACION WHERE Usuario like @Usuario_Sin_Fecha + '%'
	--DELETE FROM WEB_OfertacionUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'

	/* ********************* ULTIMA FECHA ACTIVIDAD USUARIO *********************************** */	
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@Usuario_Sin_Fecha 
	
	/* ********************************* RESULTADO *********************************** */	
	--SELECT WEB_OfertacionUsuarioCentro.*  FROM WEB_OfertacionUsuarioCentro WHERE Usuario = @Usuario

	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH 
		return ERROR_NUMBER ()
	END CATCH
	
END