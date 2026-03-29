CREATE VIEW dbo.vwRPI_Asuntos_Singulares
AS
SELECT        TOP (100) PERCENT dbo.RPI_Asuntos.idAsunto, dbo.RPI_Asuntos.FechaAsunto, dbo.RPI_Asuntos.MontoAsunto, dbo.RPI_Asuntos.FechaPresentado, 
                         dbo.RPI_Asuntos.MontoPresentado, dbo.RPI_Asuntos.FechaPreAdjudicado, dbo.RPI_Asuntos.MontoPreAdjudicado, dbo.RPI_Asuntos.FechaAdjudicado, 
                         dbo.RPI_Asuntos.MontoAdjudicado, dbo.RPI_Asuntos.FechaEnVigor, dbo.RPI_Asuntos.MontoEnVigor, dbo.RPI_Asuntos.FechaDenegado, 
                         dbo.RPI_Asuntos.MontoDenegado, dbo.RPI_Asuntos.Estado, dbo.fnAgrupRPTAsuntos(dbo.RPI_Asuntos.Estado) AS AgrupRPTAsuntos, 
                         dbo.fnAgrupPaises(dbo.RPI_Area_Pais.Area) AS AgrupPais, dbo.RPI_Asuntos.idArea_Pais, dbo.RPI_Area_Pais.Area, dbo.RPI_Area_Pais.Pais, 
                         dbo.RPI_Area_Pais.Activo, dbo.RPI_Asuntos.idProbabilidad, dbo.RPI_Probabilidades.NombreProbabilidad, dbo.RPI_Asuntos.IdActividad_1, 
                         dbo.RPI_Asuntos.IdActividad_2, dbo.RPI_Asuntos.CodCliente, dbo.RPI_Clientes.NombreCliente, dbo.RPI_Asuntos.Financiacion, dbo.RPI_Asuntos.Precalificacion, 
                         dbo.RPI_Asuntos.CodMoneda, dbo.RPI_Monedas.NombreMoneda, dbo.RPI_Asuntos.UsuarioPropietario, dbo.RPI_Asuntos.Proyecto, 
                         dbo.RPI_Asuntos.EstructuraContraactual, dbo.RPI_Asuntos.MemoriaProyecto, dbo.RPI_Asuntos.Instalaciones_Redes_Centro, 
                         dbo.RPI_Asuntos.Instalaciones_Redes_Sur, dbo.RPI_Asuntos.Instalaciones_Redes_Este, dbo.RPI_Asuntos.Instalaciones_Redes_Nordeste, 
                         dbo.RPI_Asuntos.Instalaciones_Redes_Norteamerica, dbo.RPI_Asuntos.GrandesRedes_Area1, dbo.RPI_Asuntos.GrandesRedes_Area2, 
                         dbo.RPI_Asuntos.GrandesRedes_Area3, dbo.RPI_Asuntos.Singular, dbo.RPI_Asuntos.Ingenieria, dbo.fnOrdenEstadoAsunto(dbo.RPI_Asuntos.Estado) 
                         AS OrdenEstado, dbo.fnResponsablesAsunto(dbo.RPI_Asuntos.idAsunto, dbo.RPI_Asuntos.UsuarioPropietario) AS Responsables, 
                         dbo.fnSeguimientosAsunto(dbo.RPI_Asuntos.idAsunto, 'C') AS SeguimientoComercialAsunto, dbo.fnSeguimientosAsunto(dbo.RPI_Asuntos.idAsunto, 'F') 
                         AS SeguimientoFinancieroAsunto, dbo.fnMontoAsunto(dbo.RPI_Asuntos.Estado, dbo.RPI_Asuntos.MontoAsunto, dbo.RPI_Asuntos.MontoPresentado, 
                         dbo.RPI_Asuntos.MontoPreAdjudicado, dbo.RPI_Asuntos.MontoAdjudicado, dbo.RPI_Asuntos.MontoEnVigor, dbo.RPI_Asuntos.MontoDenegado) AS Monto, 
                         dbo.RPI_Asuntos.Energia_Area1, dbo.RPI_Asuntos.Energia_Area2, dbo.RPI_Asuntos.Energia_Area3, dbo.RPI_Asuntos.GrandesRedes_Gas, 
                         dbo.RPI_Asuntos.GrandesRedes_LineasUE, dbo.RPI_Asuntos.Energia_Audeca, dbo.RPI_Asuntos.Energia_Area4_FFCC, 2999 AS FechaEnVigorSinAño, 
                         2999 AS FechaDenegadoSinAño, dbo.RPI_Asuntos.Anexo1, dbo.RPI_Asuntos.Anexo2, dbo.RPI_Asuntos.Anexo3
FROM            dbo.RPI_Asuntos INNER JOIN
                         dbo.RPI_Clientes ON dbo.RPI_Asuntos.CodCliente = dbo.RPI_Clientes.CodCliente INNER JOIN
                         dbo.RPI_Monedas ON dbo.RPI_Asuntos.CodMoneda = dbo.RPI_Monedas.CodMoneda INNER JOIN
                         dbo.RPI_Probabilidades ON dbo.RPI_Asuntos.idProbabilidad = dbo.RPI_Probabilidades.idProbabilidad INNER JOIN
                         dbo.RPI_Area_Pais ON dbo.RPI_Asuntos.idArea_Pais = dbo.RPI_Area_Pais.idArea_Pais INNER JOIN
                         dbo.RPI_Actividades ON dbo.RPI_Asuntos.IdActividad_1 = dbo.RPI_Actividades.idActividad
WHERE        (dbo.RPI_Asuntos.Singular = 1)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 8970
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwRPI_Asuntos_Singulares';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwRPI_Asuntos_Singulares';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[28] 4[32] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -31
         Left = 0
      End
      Begin Tables = 
         Begin Table = "RPI_Asuntos"
            Begin Extent = 
               Top = 94
               Left = 387
               Bottom = 388
               Right = 657
            End
            DisplayFlags = 280
            TopColumn = 23
         End
         Begin Table = "RPI_Clientes"
            Begin Extent = 
               Top = 292
               Left = 755
               Bottom = 387
               Right = 964
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RPI_Monedas"
            Begin Extent = 
               Top = 52
               Left = 1039
               Bottom = 164
               Right = 1248
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RPI_Probabilidades"
            Begin Extent = 
               Top = 107
               Left = 36
               Bottom = 202
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RPI_Area_Pais"
            Begin Extent = 
               Top = 202
               Left = 36
               Bottom = 331
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RPI_Actividades"
            Begin Extent = 
               Top = 346
               Left = 28
               Bottom = 441
               Right = 237
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 62
         Width = 284
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwRPI_Asuntos_Singulares';

