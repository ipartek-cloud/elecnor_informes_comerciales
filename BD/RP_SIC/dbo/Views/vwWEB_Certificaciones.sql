CREATE VIEW dbo.vwWEB_Certificaciones
AS
SELECT        dbo.Sumarigrama_RPSIC_Certificaciones.CodDirGeneral, dbo.Sumarigrama_RPSIC_Certificaciones.NombreDirGeneral, 
                         dbo.Sumarigrama_RPSIC_Certificaciones.CodSubDirGeneral, dbo.Sumarigrama_RPSIC_Certificaciones.NombreSubDirGeneral, 
                         dbo.Sumarigrama_RPSIC_Certificaciones.CodDDirNegocio, dbo.Sumarigrama_RPSIC_Certificaciones.NombreDirNegocio, 
                         dbo.Sumarigrama_RPSIC_Certificaciones.CodSubDirNegocioArea, dbo.Sumarigrama_RPSIC_Certificaciones.NombreSubDirNegocioArea, 
                         dbo.Sumarigrama_RPSIC_Certificaciones.CodDelegacion, dbo.Sumarigrama_RPSIC_Certificaciones.NombreDelegacion, 
                         dbo.Sumarigrama_RPSIC_Certificaciones.CodCentro, dbo.Sumarigrama_RPSIC_Certificaciones.NombreCentro, 
                         ISNULL(dbo.vwContratacion_Referencias.NumReferencias, 0) AS NumReferencias_ALL, ISNULL(dbo.vwContratacion_Referencias_CBE.NumReferenciasCBE, 0) 
                         AS NumCBE_ALL, ISNULL(dbo.vwContratacion_Ingresos300K_2016_NumOfertas_CON_Referencias_CON_CBE.NumOfertas, 0) AS NumOfertas_2016, 
                         ISNULL(dbo.vwContratacion_Ingresos300K_2016_NumOfertas_CON_Referencias_CON_CBE.NumReferencias, 0) AS NumReferencias_2016, 
                         ISNULL(dbo.vwContratacion_Ingresos300K_2016_NumOfertas_CON_Referencias_CON_CBE.NumCBE, 0) AS NumCBE_2016, 
                         ISNULL(dbo.vwContratacion_Ingresos300K_2018_NumOfertas_CON_Referencias_CON_CBE.NumOfertas, 0) AS NumOfertas_2018, 
                         ISNULL(dbo.vwContratacion_Ingresos300K_2018_NumOfertas_CON_Referencias_CON_CBE.NumReferencias, 0) AS NumReferencias_2018, 
                         ISNULL(dbo.vwContratacion_Ingresos300K_2018_NumOfertas_CON_Referencias_CON_CBE.NumCBE, 0) AS NumCBE_2018, 
                         ISNULL(dbo.vwContratacion_Ingresos300K_2019_NumOfertas_CON_Referencias_CON_CBE.NumOfertas, 0) AS NumOfertas_2019, 
                         ISNULL(dbo.vwContratacion_Ingresos300K_2019_NumOfertas_CON_Referencias_CON_CBE.NumReferencias, 0) AS NumReferencias_2019, 
                         ISNULL(dbo.vwContratacion_Ingresos300K_2019_NumOfertas_CON_Referencias_CON_CBE.NumCBE, 0) AS NumCBE_2019
FROM            dbo.Sumarigrama_RPSIC_Certificaciones LEFT OUTER JOIN
                         dbo.vwContratacion_Ingresos300K_2019_NumOfertas_CON_Referencias_CON_CBE ON 
                         dbo.Sumarigrama_RPSIC_Certificaciones.CodCentro = dbo.vwContratacion_Ingresos300K_2019_NumOfertas_CON_Referencias_CON_CBE.CodCentro LEFT OUTER JOIN
                         dbo.vwContratacion_Ingresos300K_2018_NumOfertas_CON_Referencias_CON_CBE ON 
                         dbo.Sumarigrama_RPSIC_Certificaciones.CodCentro = dbo.vwContratacion_Ingresos300K_2018_NumOfertas_CON_Referencias_CON_CBE.CodCentro LEFT OUTER JOIN
                         dbo.vwContratacion_Ingresos300K_2016_NumOfertas_CON_Referencias_CON_CBE ON 
                         dbo.Sumarigrama_RPSIC_Certificaciones.CodCentro = dbo.vwContratacion_Ingresos300K_2016_NumOfertas_CON_Referencias_CON_CBE.CodCentro LEFT OUTER JOIN
                         dbo.vwContratacion_Referencias_CBE ON dbo.Sumarigrama_RPSIC_Certificaciones.CodCentro = dbo.vwContratacion_Referencias_CBE.CodCentro LEFT OUTER JOIN
                         dbo.vwContratacion_Referencias ON dbo.Sumarigrama_RPSIC_Certificaciones.CodCentro = dbo.vwContratacion_Referencias.CodCentro

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[47] 4[16] 2[21] 3) )"
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
         Begin Table = "Sumarigrama_RPSIC_Certificaciones"
            Begin Extent = 
               Top = 18
               Left = 338
               Bottom = 299
               Right = 601
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwContratacion_Referencias"
            Begin Extent = 
               Top = 34
               Left = 30
               Bottom = 129
               Right = 277
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwContratacion_Referencias_CBE"
            Begin Extent = 
               Top = 265
               Left = 30
               Bottom = 360
               Right = 278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwContratacion_Ingresos300K_2016_NumOfertas_CON_Referencias_CON_CBE"
            Begin Extent = 
               Top = 12
               Left = 688
               Bottom = 139
               Right = 1177
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwContratacion_Ingresos300K_2018_NumOfertas_CON_Referencias_CON_CBE"
            Begin Extent = 
               Top = 151
               Left = 689
               Bottom = 280
               Right = 1180
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwContratacion_Ingresos300K_2019_NumOfertas_CON_Referencias_CON_CBE"
            Begin Extent = 
               Top = 279
               Left = 684
               Bottom = 408
               Right = 1178
            End
            DisplayFlags = 280
         ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_Certificaciones';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 24
         Width = 284
         Width = 1500
         Width = 2595
         Width = 1500
         Width = 2595
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1800
         Width = 1875
         Width = 1500
         Width = 1605
         Width = 2460
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
         Column = 7320
         Alias = 2205
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_Certificaciones';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_Certificaciones';

