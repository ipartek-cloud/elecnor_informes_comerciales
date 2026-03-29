CREATE VIEW [dbo].[vwRPI_Asuntos_OLD]
AS
SELECT        TOP (100) PERCENT dbo.RPI_Asuntos.idAsunto, dbo.RPI_Asuntos.FechaAsunto, dbo.RPI_Asuntos.MontoAsunto, dbo.RPI_Asuntos.FechaPresentado, dbo.RPI_Asuntos.MontoPresentado, 
                         dbo.RPI_Asuntos.FechaPreAdjudicado, dbo.RPI_Asuntos.MontoPreAdjudicado, dbo.RPI_Asuntos.FechaAdjudicado, dbo.RPI_Asuntos.MontoAdjudicado, dbo.RPI_Asuntos.FechaEnVigor, 
                         dbo.RPI_Asuntos.MontoEnVigor, dbo.RPI_Asuntos.FechaDenegado, dbo.RPI_Asuntos.MontoDenegado, dbo.RPI_Asuntos.Estado, dbo.fnAgrupRPTAsuntos(dbo.RPI_Asuntos.Estado) AS AgrupRPTAsuntos, 
                         dbo.fnAgrupPaises(dbo.RPI_Area_Pais.Area) AS AgrupPais, dbo.RPI_Asuntos.idArea_Pais, dbo.RPI_Area_Pais.Area, dbo.RPI_Area_Pais.Pais, dbo.RPI_Area_Pais.Activo, dbo.RPI_Asuntos.idProbabilidad, 
                         dbo.RPI_Probabilidades.NombreProbabilidad, dbo.RPI_Asuntos.IdActividad_1, dbo.RPI_Asuntos.IdActividad_2, dbo.RPI_Asuntos.CodCliente, dbo.RPI_Clientes.NombreCliente, dbo.RPI_Asuntos.Financiacion, 
                         dbo.RPI_Asuntos.Precalificacion, dbo.RPI_Asuntos.CodMoneda, dbo.RPI_Monedas.NombreMoneda, dbo.RPI_Asuntos.UsuarioPropietario, dbo.RPI_Asuntos.Proyecto, dbo.RPI_Asuntos.EstructuraContraactual, 
                         dbo.RPI_Asuntos.MemoriaProyecto, dbo.RPI_Asuntos.Instalaciones_Redes_Centro, dbo.RPI_Asuntos.Instalaciones_Redes_Sur, dbo.RPI_Asuntos.Instalaciones_Redes_Este, 
                         dbo.RPI_Asuntos.Instalaciones_Redes_Nordeste, dbo.RPI_Asuntos.Instalaciones_Redes_Norteamerica, dbo.RPI_Asuntos.GrandesRedes_Area1, dbo.RPI_Asuntos.GrandesRedes_Area2, 
                         dbo.RPI_Asuntos.GrandesRedes_Area3, dbo.RPI_Asuntos.Singular, dbo.RPI_Asuntos.Ingenieria, dbo.fnOrdenEstadoAsunto(dbo.RPI_Asuntos.Estado) AS OrdenEstado, 
                         dbo.fnResponsablesAsunto(dbo.RPI_Asuntos.idAsunto, dbo.RPI_Asuntos.UsuarioPropietario) AS Responsables, dbo.fnSeguimientosAsunto(dbo.RPI_Asuntos.idAsunto, 'C') AS SeguimientoComercialAsunto, 
                         dbo.fnSeguimientosAsunto(dbo.RPI_Asuntos.idAsunto, 'F') AS SeguimientoFinancieroAsunto, dbo.fnMontoAsunto(dbo.RPI_Asuntos.Estado, dbo.RPI_Asuntos.MontoAsunto, dbo.RPI_Asuntos.MontoPresentado, 
                         dbo.RPI_Asuntos.MontoPreAdjudicado, dbo.RPI_Asuntos.MontoAdjudicado, dbo.RPI_Asuntos.MontoEnVigor, dbo.RPI_Asuntos.MontoDenegado) AS Monto, dbo.RPI_Asuntos.Energia_Area1, 
                         dbo.RPI_Asuntos.Energia_Area2, dbo.RPI_Asuntos.Energia_Area3, dbo.RPI_Asuntos.GrandesRedes_Gas, dbo.RPI_Asuntos.GrandesRedes_LineasUE, dbo.RPI_Asuntos.Energia_Audeca, 
                         dbo.RPI_Asuntos.Energia_Area4_FFCC, CASE WHEN dbo.RPI_Asuntos.FechaEnVigor = '' THEN 2999 ELSE year(dbo.RPI_Asuntos.FechaEnVigor) END AS FechaEnVigorSinAño, 
                         CASE WHEN dbo.RPI_Asuntos.FechaDenegado = '' THEN 2999 ELSE year(dbo.RPI_Asuntos.FechaDenegado) END AS FechaDenegadoSinAño
FROM            dbo.RPI_Asuntos INNER JOIN
                         dbo.RPI_Clientes ON dbo.RPI_Asuntos.CodCliente = dbo.RPI_Clientes.CodCliente INNER JOIN
                         dbo.RPI_Monedas ON dbo.RPI_Asuntos.CodMoneda = dbo.RPI_Monedas.CodMoneda INNER JOIN
                         dbo.RPI_Probabilidades ON dbo.RPI_Asuntos.idProbabilidad = dbo.RPI_Probabilidades.idProbabilidad INNER JOIN
                         dbo.RPI_Area_Pais ON dbo.RPI_Asuntos.idArea_Pais = dbo.RPI_Area_Pais.idArea_Pais INNER JOIN
                         dbo.RPI_Actividades ON dbo.RPI_Asuntos.IdActividad_1 = dbo.RPI_Actividades.idActividad
