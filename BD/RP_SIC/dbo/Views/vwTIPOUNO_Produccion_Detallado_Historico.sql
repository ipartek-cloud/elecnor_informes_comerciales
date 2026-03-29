CREATE VIEW dbo.vwTIPOUNO_Produccion_Detallado_Historico
AS
SELECT        TOP (100) PERCENT dbo.vwEnlaces_Detallado.CTRO AS CodCentro, dbo.vwEnlaces_Detallado.CDOFT AS CodOferta, 
                         dbo.vwEnlaces_Detallado.OBRA + '-' + dbo.vwEnlaces_Detallado.OBRAL + ' ' + dbo.ObrasHistoricasSQL.DSOBR AS NombreObra, 
                         SUM(dbo.ObrasHistoricasSQL.SOP) AS ImporteProduccion, SUM(dbo.ObrasHistoricasSQL.SOF) AS ImporteFactura, SUM(dbo.ObrasHistoricasSQL.SOL) AS ImporteFot,
                          dbo.ObrasHistoricasSQL.FAPERTURA, dbo.ObrasHistoricasSQL.FCIERRE
FROM            dbo.vwEnlaces_Detallado INNER JOIN
                         dbo.ObrasHistoricasSQL ON dbo.vwEnlaces_Detallado.CTRO = dbo.ObrasHistoricasSQL.CTR AND 
                         dbo.vwEnlaces_Detallado.OBRA = dbo.ObrasHistoricasSQL.OBRA AND dbo.vwEnlaces_Detallado.OBRAL = dbo.ObrasHistoricasSQL.OBRAL
GROUP BY dbo.vwEnlaces_Detallado.CTRO, dbo.vwEnlaces_Detallado.OBRA, dbo.vwEnlaces_Detallado.OBRAL, dbo.vwEnlaces_Detallado.CDOFT, 
                         dbo.ObrasHistoricasSQL.FAPERTURA, dbo.ObrasHistoricasSQL.FCIERRE, 
                         dbo.vwEnlaces_Detallado.OBRA + '-' + dbo.vwEnlaces_Detallado.OBRAL + ' ' + dbo.ObrasHistoricasSQL.DSOBR

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[21] 4[33] 2[17] 3) )"
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
         Begin Table = "ObrasHistoricasSQL"
            Begin Extent = 
               Top = 59
               Left = 519
               Bottom = 326
               Right = 744
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwEnlaces_Detallado"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 210
               Right = 273
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
      Begin ColumnWidths = 9
         Width = 284
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
      Begin ColumnWidths = 12
         Column = 9885
         Alias = 1770
         Table = 2025
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwTIPOUNO_Produccion_Detallado_Historico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwTIPOUNO_Produccion_Detallado_Historico';

