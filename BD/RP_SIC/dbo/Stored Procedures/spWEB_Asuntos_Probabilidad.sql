

CREATE PROCEDURE [dbo].[spWEB_Asuntos_Probabilidad]
	@pEntidad varchar(50),
	@pCodEntidad varchar(50)
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

		DECLARE @Usuario_Sin_Fecha varchar(50)

		
		IF @pEntidad = 'DG' AND isnull(@pCodEntidad,'')=''
			BEGIN
				SELECT 'Eln. Infraestructuras' as DG, [Baja < 50%] as 'Baja < 50%',[Media 50-90%] as 'Media 50-90%',[Alta > 90%] as 'Alta > 90%'
				FROM
				(
				SELECT idAsunto, NombreProbabilidad
				FROM dbo.vwRPI_Asuntos
				Where Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR NombreProbabilidad IN ([Baja < 50%],[Media 50-90%],[Alta > 90%])
				) as pvt
			END
		ELSE IF (@pEntidad = 'DG' AND isnull(@pCodEntidad,'')<>'' )
			BEGIN
				SELECT 'Eln. Infraestructuras' as DG,AgrupPais, [Baja < 50%] as 'Baja < 50%',[Media 50-90%] as 'Media 50-90%',[Alta > 90%] as 'Alta > 90%'
				FROM
				(
				SELECT AgrupPais,idAsunto, NombreProbabilidad
				FROM dbo.vwRPI_Asuntos
				Where Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR NombreProbabilidad IN ([Baja < 50%],[Media 50-90%],[Alta > 90%])
				) as pvt
			END
		ELSE IF @pEntidad = 'Presencia'
			BEGIN			
				SELECT 'Eln. Infraestructuras' as DG,AgrupPais,Area, [Baja < 50%] as 'Baja < 50%',[Media 50-90%] as 'Media 50-90%',[Alta > 90%] as 'Alta > 90%'
				FROM
				(
				SELECT AgrupPais,Area,idAsunto, NombreProbabilidad
				FROM dbo.vwRPI_Asuntos
				Where (
						Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
						) AND (
							@pCodEntidad=AgrupPais
						)
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR NombreProbabilidad IN ([Baja < 50%],[Media 50-90%],[Alta > 90%])
				) as pvt
			END
		ELSE IF @pEntidad = 'Area'
			BEGIN
				SELECT 'Eln. Infraestructuras' as DG,AgrupPais, Area, Pais, [Baja < 50%] as 'Baja < 50%',[Media 50-90%] as 'Media 50-90%',[Alta > 90%] as 'Alta > 90%'
				FROM
				(
				SELECT AgrupPais, Area, Pais, idAsunto, NombreProbabilidad
				FROM dbo.vwRPI_Asuntos
				Where (
						Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
					 ) AND (
						@pCodEntidad=Area
					 )
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR NombreProbabilidad IN ([Baja < 50%],[Media 50-90%],[Alta > 90%])
				) as pvt
			END	

		return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END

