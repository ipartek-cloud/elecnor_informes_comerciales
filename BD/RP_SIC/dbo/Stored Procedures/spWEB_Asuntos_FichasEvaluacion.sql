

CREATE PROCEDURE [dbo].[spWEB_Asuntos_FichasEvaluacion]
	@pEntidad varchar(50),
	@pCodEntidad varchar(50)
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

		DECLARE @Usuario_Sin_Fecha varchar(50)
		
		IF @pEntidad = 'DG' AND isnull(@pCodEntidad,'')=''
			BEGIN
				SELECT 'Eln. Infraestructuras' as DG, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
				FROM
				(
				SELECT idAsunto, Estado
				FROM dbo.vwRPI_Asuntos_Singulares
				Where Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor],[Preadjudicado] ,[Adjudicado] , [Denegado])
				) as pvt
			END
		ELSE IF (@pEntidad = 'DG' AND isnull(@pCodEntidad,'')<>'' )
			BEGIN
				SELECT 'Eln. Infraestructuras' as DG,AgrupPais, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
				FROM
				(
				SELECT AgrupPais,idAsunto, Estado
				FROM dbo.vwRPI_Asuntos_Singulares
				Where Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor],[Preadjudicado] ,[Adjudicado] , [Denegado])
				) as pvt
			END
		ELSE IF @pEntidad = 'Presencia'
			BEGIN			
				SELECT 'Eln. Infraestructuras' as DG, AgrupPais, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
				FROM
				(
				SELECT AgrupPais, Area, idAsunto, Estado
				FROM dbo.vwRPI_Asuntos_Singulares
				Where (
						Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
						) AND (
							@pCodEntidad=AgrupPais
						)
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor],[Preadjudicado] ,[Adjudicado] , [Denegado])
				) as pvt
			END
		ELSE IF @pEntidad = 'Area'
			BEGIN
				SELECT 'Eln. Infraestructuras' as DG, AgrupPais, Area, Pais, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
				FROM
				(
				SELECT AgrupPais, Area, Pais, idAsunto, Estado
				FROM dbo.vwRPI_Asuntos_Singulares
				Where (
						Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
					 ) AND (
						@pCodEntidad=Area
					 )
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
				) as pvt
			END	

			return 0 -- NO ERROR
				
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END

