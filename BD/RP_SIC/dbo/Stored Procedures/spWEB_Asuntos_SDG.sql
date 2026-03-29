
CREATE PROCEDURE [dbo].[spWEB_Asuntos_SDG]
	@pEntidad varchar(50),
	@pCodEntidad varchar(50)
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

		DECLARE @Usuario_Sin_Fecha varchar(50)

		IF @pEntidad = 'DG' AND isnull(@pCodEntidad,'')<>''
			BEGIN
				SELECT * FROM(
						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Instalaciones y Redes' as AgrupSDG,'' as Area ,idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where ( 
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')									
									) AND (
										Instalaciones_Redes_Centro=1 OR Instalaciones_Redes_Sur=1 OR Instalaciones_Redes_Este=1 OR Instalaciones_Redes_Nordeste=1 OR Instalaciones_Redes_Norteamerica=1
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision, [Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Instalaciones y Redes' as AgrupSDG,'Centro' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Instalaciones_Redes_Centro=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Instalaciones y Redes' as AgrupSDG, 'Sur' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Instalaciones_Redes_Sur=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Instalaciones y Redes' as AgrupSDG, 'Este' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Instalaciones_Redes_Este=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Instalaciones y Redes' as AgrupSDG, 'Nordeste' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Instalaciones_Redes_Nordeste=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Instalaciones y Redes' as AgrupSDG, 'Norteamerica' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Instalaciones_Redes_Norteamerica=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION


						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion ,[Pdte.Decisión] as PdteDecision, [Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Grandes Redes' as AgrupSDG, '' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										GrandesRedes_Gas=1 OR GrandesRedes_LineasUE=1 OR GrandesRedes_Area1=1 OR GrandesRedes_Area2=1 OR GrandesRedes_Area3=1
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor], [Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion ,[Pdte.Decisión] as PdteDecision, [Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Grandes Redes' as AgrupSDG, 'Gas/Agua' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										GrandesRedes_Gas=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor], [Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion ,[Pdte.Decisión] as PdteDecision, [Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Grandes Redes' as AgrupSDG, 'Lineas U.E.' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										GrandesRedes_LineasUE=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor], [Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt
						
						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion ,[Pdte.Decisión] as PdteDecision, [Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Grandes Redes' as AgrupSDG, 'Area 1' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										GrandesRedes_Area1=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor], [Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt
						
						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion ,[Pdte.Decisión] as PdteDecision, [Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Grandes Redes' as AgrupSDG, 'Area 2' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										GrandesRedes_Area2=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor], [Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt
						
						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion ,[Pdte.Decisión] as PdteDecision, [Preadjudicado] as Preadjudicado, [Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Grandes Redes' as AgrupSDG, 'Area 3' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										GrandesRedes_Area3=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor], [Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Energía' as AgrupSDG, '' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Energia_Audeca=1 OR Energia_Area1=1 OR Energia_Area2=1 OR Energia_Area3=1 OR Energia_Area4_FFCC=1
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Energía' as AgrupSDG, 'Audeca' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Energia_Audeca=1
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Energía' as AgrupSDG, 'Area 1 ' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Energia_Area1=1
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Energía' as AgrupSDG, 'Area 2 ' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Energia_Area2=1
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Energía' as AgrupSDG, 'Area 3 ' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Energia_Area3=1
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Energía' as AgrupSDG, 'Area4_FFCC' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Energia_Area4_FFCC=1
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						UNION

						SELECT 'Eln. Infraestructuras' as DG, AgrupSDG, Area, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
						FROM
						(
							SELECT 'Ingeniería' as AgrupSDG, '' as Area, idAsunto, Estado
							FROM dbo.vwRPI_Asuntos
							Where (
									Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
									) AND (
										Ingenieria=1 
									)
						) vw
						PIVOT
						(
						COUNT(idAsunto)
						FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
						) as pvt

						) as vw
						ORDER BY AgrupSDG desc

			END
			
		ELSE IF @pEntidad = 'DG' AND isnull(@pCodEntidad,'')=''
			BEGIN
				SELECT 'Eln. Infraestructuras' as DG, [Asunto] as Asunto,[En Preparación] as Preparacion,[Pdte.Decisión] as PdteDecision,[Preadjudicado] as Preadjudicado,[Adjudicado] as Adjudicado,[En Vigor] as Vigor, [Denegado] as Denegado
				FROM
				(
				SELECT idAsunto, Estado
				FROM dbo.vwRPI_Asuntos
				Where Estado IN ('Asunto', 'En Preparación', 'Pdte.Decisión', 'Preadjudicado', 'Adjudicado','En Vigor','Denegado')
				) vw
				PIVOT
				(
				COUNT(idAsunto)
				FOR Estado IN ([Asunto] ,[En Preparación],[Pdte.Decisión],[En Vigor] ,[Preadjudicado],[Adjudicado] , [Denegado])
				) as pvt
			END
		ELSE
		

		return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END

