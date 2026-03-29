CREATE VIEW dbo.vwOferRegu_Actividades_Encuestas
AS
SELECT        dbo.vwOferRegu_Encuestas.CT, dbo.vwOferRegu_Encuestas.MERCADO, dbo.vwOferRegu_Encuestas.CODOFER, dbo.vwOferRegu_Encuestas.DESOFER, 
                         dbo.vwOferRegu_Encuestas.REG, dbo.vwOferRegu_Encuestas.CAUSA, dbo.vwOferRegu_Encuestas.LOCALIDAD, dbo.vwOferRegu_Encuestas.CODPROVINCIA, 
                         dbo.vwOferRegu_Encuestas.NOMPROVINCIA, dbo.vwOferRegu_Encuestas.CODCLIENTE, dbo.vwOferRegu_Encuestas.NOMCLIENTE, 
                         dbo.vwOferRegu_Encuestas.ACT1, dbo.vwOferRegu_Encuestas.ACT2, dbo.vwOferRegu_Encuestas.RESPONSABLE, dbo.vwOferRegu_Encuestas.AÑOGRAB, 
                         dbo.vwOferRegu_Encuestas.MESGRAB, dbo.vwOferRegu_Encuestas.IMPAPROX, dbo.vwOferRegu_Encuestas.AÑOPRES, dbo.vwOferRegu_Encuestas.MESPRES, 
                         dbo.vwOferRegu_Encuestas.IMPPRES, dbo.vwOferRegu_Encuestas.ADJUDICADA, dbo.vwOferRegu_Encuestas.AÑOAD, dbo.vwOferRegu_Encuestas.MESAD, 
                         dbo.vwOferRegu_Encuestas.IMPAD, dbo.vwOferRegu_Encuestas.TIPO, dbo.vwOferRegu_Encuestas.OFERTAR, dbo.vwOferRegu_Encuestas.TOTCOSTOS, 
                         dbo.vwOferRegu_Encuestas.IMPTOTAL, dbo.vwOferRegu_Encuestas.CLIENTPROV, dbo.vwOferRegu_Encuestas.BAJA, dbo.vwOferRegu_Encuestas.AI, 
                         dbo.vwOferRegu_Encuestas.ORIGEN, dbo.ActividadesSQL.DSACT, dbo.ActividadesSQL.Agrupacion, dbo.Sumarigrama.NombreCentro
FROM            dbo.vwOferRegu_Encuestas LEFT OUTER JOIN
                         dbo.Sumarigrama ON dbo.vwOferRegu_Encuestas.CT = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
                         dbo.ActividadesSQL ON dbo.vwOferRegu_Encuestas.ACT1 = dbo.ActividadesSQL.CDAC1 AND dbo.vwOferRegu_Encuestas.ACT2 = dbo.ActividadesSQL.CDAC2

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "vwOferRegu_Encuestas"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 302
               Right = 319
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ActividadesSQL"
            Begin Extent = 
               Top = 150
               Left = 678
               Bottom = 305
               Right = 918
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Sumarigrama"
            Begin Extent = 
               Top = 0
               Left = 679
               Bottom = 129
               Right = 916
            End
            DisplayFlags = 280
            TopColumn = 10
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwOferRegu_Actividades_Encuestas';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwOferRegu_Actividades_Encuestas';

