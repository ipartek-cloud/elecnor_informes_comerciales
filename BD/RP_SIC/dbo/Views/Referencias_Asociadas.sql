CREATE VIEW dbo.Referencias_Asociadas
AS
SELECT        Referencias.idReferencia, dbo.ContratacionAsociada.CodOfertaAsociada AS CodOferta, Referencias.Proyecto, Referencias.Memoria, Referencias.ClienteFinal, 
                         Referencias.NombreUTE, Referencias.PorcentajeUTE, Referencias.MesInicio, Referencias.AñoInicio, Referencias.Plazo, Referencias.MesFinPrevista, 
                         Referencias.AñoFinPrevista, Referencias.Fecha, Referencias.ImporteCertificado, Referencias.SinReferencia, Referencias.Facturacion, 
                         Referencias.idReferenciasSectores, Referencias.CCTV, Referencias.CCAA, Referencias.Intrusion, Referencias.LecturaMatriculas, Referencias.Megafonia, 
                         Referencias.AudioVisual, Referencias.Redes, Referencias.Telefonia, Referencias.Wifi, Referencias.SmartCities, Referencias.Parking, Referencias.Aguas, 
                         Referencias.PCI, Referencias.Automatizacion, Referencias.Mantenimientos, Referencias.CodCPV
FROM            dbo.Referencias_SIN_asociadas AS Referencias INNER JOIN
                         dbo.ContratacionAsociada ON Referencias.CodOferta = dbo.ContratacionAsociada.CodOferta
WHERE        (Referencias.SinReferencia = 0) AND (dbo.ContratacionAsociada.CodOferta <> dbo.ContratacionAsociada.CodOfertaAsociada)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[32] 4[29] 2[20] 3) )"
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
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Referencias"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 293
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ContratacionAsociada"
            Begin Extent = 
               Top = 6
               Left = 285
               Bottom = 101
               Right = 494
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
      Begin ColumnWidths = 34
         Width = 284
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
         Width = 2295
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
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 4095
     ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Referencias_Asociadas';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'    Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Referencias_Asociadas';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Referencias_Asociadas';

