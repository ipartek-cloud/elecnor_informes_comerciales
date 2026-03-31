CREATE VIEW dbo.[SumarigramaDB2]
AS
SELECT     TOP (100) PERCENT dbo.DirGeneral.CodDirGeneral, dbo.DirGeneral.NombreDirGeneral, dbo.SubDirGeneral.CodSubDirGeneral, 
                      dbo.SubDirGeneral.NombreSubDirGeneral, dbo.DirNegocio.CodDDirNegocio, dbo.DirNegocio.NombreDirNegocio, 
                      dbo.SubDirNegocioArea.CodSubDirNegocioArea, dbo.SubDirNegocioArea.NombreSubDirNegocioArea, dbo.Delegaciones.CodDelegacion, 
                      dbo.Delegaciones.NombreDelegacion, dbo.Centros.CodCentro, dbo.Centros.NombreCentro, dbo.SubDirGeneral.Orden AS OrdenSubDirGeneral
FROM         dbo.DirGeneral INNER JOIN
                      dbo.SubDirGeneral ON dbo.DirGeneral.CodDirGeneral = dbo.SubDirGeneral.CodDirGeneral INNER JOIN
                      dbo.Enlace_SubDirGeneral_DirNegocio ON dbo.SubDirGeneral.CodSubDirGeneral = dbo.Enlace_SubDirGeneral_DirNegocio.CodSubDirGeneral AND 
                      dbo.SubDirGeneral.CodDirGeneral = dbo.Enlace_SubDirGeneral_DirNegocio.CodDirGeneral INNER JOIN
                      dbo.DirNegocio ON dbo.Enlace_SubDirGeneral_DirNegocio.CodDirNegocio = dbo.DirNegocio.CodDDirNegocio INNER JOIN
                      dbo.SubDirNegocioArea ON dbo.DirNegocio.CodDDirNegocio = dbo.SubDirNegocioArea.CodDirNegocio INNER JOIN
                      dbo.Enlace_SubDirNegocioArea_Delegaciones ON 
                      dbo.SubDirNegocioArea.CodSubDirNegocioArea = dbo.Enlace_SubDirNegocioArea_Delegaciones.CodSubDirNegocioArea AND 
                      dbo.SubDirNegocioArea.CodDirNegocio = dbo.Enlace_SubDirNegocioArea_Delegaciones.CodDirNegocio INNER JOIN
                      dbo.Delegaciones ON dbo.Enlace_SubDirNegocioArea_Delegaciones.CodDelegacion = dbo.Delegaciones.CodDelegacion INNER JOIN
                      dbo.Centros ON dbo.Delegaciones.CodDelegacion = dbo.Centros.CDDEL

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
               Right = 454
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Centros"
            Begin Extent = 
               Top = 198
               Left = 492
               Bottom = 306
               Right = 681
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
      Begin ColumnWidths = 13
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
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'SumarigramaDB2';














GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'SumarigramaDB2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[22] 2[20] 3) )"
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
         Begin Table = "DirGeneral"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 99
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SubDirGeneral"
            Begin Extent = 
               Top = 6
               Left = 265
               Bottom = 99
               Right = 454
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Enlace_SubDirGeneral_DirNegocio"
            Begin Extent = 
               Top = 6
               Left = 492
               Bottom = 99
               Right = 681
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DirNegocio"
            Begin Extent = 
               Top = 102
               Left = 38
               Bottom = 210
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SubDirNegocioArea"
            Begin Extent = 
               Top = 102
               Left = 265
               Bottom = 195
               Right = 474
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Enlace_SubDirNegocioArea_Delegaciones"
            Begin Extent = 
               Top = 102
               Left = 512
               Bottom = 195
               Right = 703
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Delegaciones"
            Begin Extent = 
               Top = 198
               Left = 265
               Bottom = 306', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'SumarigramaDB2';


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[SumarigramaDB2] TO [ELNR\sig]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[SumarigramaDB2] TO [usuELECSIG]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[SumarigramaDB2] TO [ELNR\sig]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[SumarigramaDB2] TO [usuELECSIG]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SumarigramaDB2] TO [ELNR\sig]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SumarigramaDB2] TO [usuELECSIG]
    AS [dbo];

