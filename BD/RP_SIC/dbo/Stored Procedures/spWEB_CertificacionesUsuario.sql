
-- exec spWEB_CertificacionesUsuario 'anruiz'

CREATE PROCEDURE [dbo].[spWEB_CertificacionesUsuario]
	@Usuario varchar(50)
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
	
	DELETE FROM WEB_CertificacionesUsuarioCentro WHERE Usuario like @Usuario_Sin_Fecha + '%'	
	
	/* ********************************* CENTROS ASIGNADOS *********************************** */			
	
	IF @Usuario_Puesto='DG'
		
		INSERT INTO [dbo].[WEB_CertificacionesUsuarioCentro]
				   ([Usuario],[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019])
		SELECT	    @Usuario,[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019]
		FROM vwWEB_Certificaciones
		WHERE CodDirGeneral=@Usuario_CodEntidad		
			
	ELSE IF @Usuario_Puesto='SDG'
		
		INSERT INTO [dbo].[WEB_CertificacionesUsuarioCentro]
				   ([Usuario],[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019])
		SELECT	    @Usuario,[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019]
		FROM vwWEB_Certificaciones
		WHERE CodSubDirGeneral = @Usuario_CodEntidad	

	ELSE IF @Usuario_Puesto='DN'	
		
		INSERT INTO [dbo].[WEB_CertificacionesUsuarioCentro]
				   ([Usuario],[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019])
		SELECT	    @Usuario,[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019]
		FROM vwWEB_Certificaciones
		WHERE CodDDirNegocio = @Usuario_CodEntidad		

	ELSE IF @Usuario_Puesto='AREA'
		
		INSERT INTO [dbo].[WEB_CertificacionesUsuarioCentro]
				   ([Usuario],[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019])
		SELECT	    @Usuario,[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019]
		FROM vwWEB_Certificaciones
		WHERE CodSubDirNegocioArea = @Usuario_CodEntidad 		

	ELSE IF @Usuario_Puesto='DEL'		
		
		INSERT INTO [dbo].[WEB_CertificacionesUsuarioCentro]
				   ([Usuario],[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019])
		SELECT	    @Usuario,[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019]
		FROM vwWEB_Certificaciones
		WHERE CodDelegacion = @Usuario_CodEntidad		

	ELSE IF @Usuario_Puesto='CT'
		
		INSERT INTO [dbo].[WEB_CertificacionesUsuarioCentro]
				   ([Usuario],[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019])
		SELECT	    @Usuario,[CodDirGeneral],[NombreDirGeneral],[CodSubDirGeneral],[NombreSubDirGeneral],[CodDDirNegocio],[NombreDirNegocio],[CodSubDirNegocioArea],[NombreSubDirNegocioArea],[CodDelegacion],[NombreDelegacion],[CodCentro],[NombreCentro],
					[NumReferencias_ALL],[NumCBE_ALL],[NumOfertas_2016],[NumReferencias_2016],[NumCBE_2016],[NumOfertas_2018],[NumReferencias_2018],[NumCBE_2018],[NumOfertas_2019],[NumReferencias_2019],[NumCBE_2019]
		FROM vwWEB_Certificaciones
		WHERE CodCentro = @Usuario_CodEntidad		

	ELSE		
		RETURN	-999999
	
	--SELECT * FROM [dbo].[WEB_CertificacionesUsuarioCentro] Where usuario=@Usuario

	return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END



