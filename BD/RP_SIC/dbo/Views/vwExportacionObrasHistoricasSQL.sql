CREATE VIEW dbo.vwExportacionObrasHistoricasSQL
AS
SELECT        dbo.vwObrasHistorico.CDOFT, dbo.vwObrasHistorico.CTR, dbo.vwObrasHistorico.OBRA, dbo.vwObrasHistorico.OBRAL, dbo.vwObrasHistorico.DSOBR, 
                         dbo.vwObrasHistorico.FAPERTURA, dbo.vwObrasHistorico.FCIERRE, dbo.vwObrasHistorico.SOP, dbo.vwObrasHistorico.SOF, dbo.vwObrasHistorico.SOL
FROM            dbo.vwObrasHistorico LEFT OUTER JOIN
                         dbo.vwOfertas_ObrasActualesSQL ON dbo.vwObrasHistorico.CDOFT = dbo.vwOfertas_ObrasActualesSQL.CodOferta AND 
                         dbo.vwObrasHistorico.CTR = dbo.vwOfertas_ObrasActualesSQL.CodCentro AND dbo.vwObrasHistorico.OBRA = dbo.vwOfertas_ObrasActualesSQL.OBRA AND 
                         dbo.vwObrasHistorico.OBRAL = dbo.vwOfertas_ObrasActualesSQL.OBRAL
WHERE        (dbo.vwObrasHistorico.SOP > 0) AND (ISNULL(dbo.vwOfertas_ObrasActualesSQL.SOP, 0) = 0)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[35] 4[17] 2[20] 3) )"
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
         Begin Table = "vwObrasHistorico"
            Begin Extent = 
               Top = 32
               Left = 45
               Bottom = 275
               Right = 318
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwOfertas_ObrasActualesSQL"
            Begin Extent = 
               Top = 26
               Left = 781
               Bottom = 269
               Right = 1164
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
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1860
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
         Table = 3210
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwExportacionObrasHistoricasSQL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwExportacionObrasHistoricasSQL';

