CREATE VIEW dbo.[vwSDG_Contratacion Actividades_2018_0708_DN]
AS
SELECT        dbo.ActividadesSQL.Orden, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.ActividadesSQL.CDAC1, 
                         LEFT(dbo.HistoricoContratacionGrupoSQL.Mercado, 1) AS Pais, SUM(dbo.HistoricoContratacionGrupoSQL.Importe) AS Contrat2018, 
                         dbo.HistoricoContratacionGrupoSQL.Mes
FROM            dbo.Sumarigrama INNER JOIN
                         dbo.HistoricoContratacionGrupoSQL ON dbo.Sumarigrama.CodCentro = dbo.HistoricoContratacionGrupoSQL.CodCentro INNER JOIN
                         dbo.ActividadesSQL ON dbo.HistoricoContratacionGrupoSQL.CodAct2 = dbo.ActividadesSQL.CDAC2 AND 
                         dbo.HistoricoContratacionGrupoSQL.CodAct1 = dbo.ActividadesSQL.CDAC1
WHERE        (dbo.HistoricoContratacionGrupoSQL.Año = 2018) AND (dbo.Sumarigrama.CodSubDirGeneral = 221) AND (dbo.ActividadesSQL.CDAC1 = '07') OR
                         (dbo.HistoricoContratacionGrupoSQL.Año = 2018) AND (dbo.Sumarigrama.CodSubDirGeneral = 221) AND (dbo.ActividadesSQL.CDAC1 = '08')
GROUP BY dbo.ActividadesSQL.Orden, LEFT(dbo.HistoricoContratacionGrupoSQL.Mercado, 1), dbo.HistoricoContratacionGrupoSQL.Mes, dbo.ActividadesSQL.CDAC1, 
                         dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwSDG_Contratacion Actividades_2018_0708_DN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[31] 4[30] 2[20] 3) )"
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
         Begin Table = "Sumarigrama"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 228
               Right = 291
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HistoricoContratacionGrupoSQL"
            Begin Extent = 
               Top = 54
               Left = 358
               Bottom = 183
               Right = 583
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ActividadesSQL"
            Begin Extent = 
               Top = 25
               Left = 690
               Bottom = 154
               Right = 915
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
         Column = 1440
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwSDG_Contratacion Actividades_2018_0708_DN';

