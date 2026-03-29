CREATE VIEW dbo.vf_Principales_Contrataciones_Informe_Detalle_x_Importe_y_Año
AS
SELECT        dbo.vt_Principales_Contrataciones_Importe_i.NomProyecto, dbo.vt_Principales_Contrataciones_Importe_i.ClienteAgrupado, 
                         dbo.vt_Principales_Contrataciones_Importe_i.NomProvincia, dbo.[vt_Principales_Contrataciones_Detalle por Oferta].MesAd, 
                         dbo.[vt_Principales_Contrataciones_Detalle por Oferta].AñoAd, dbo.[vt_Principales_Contrataciones_Detalle por Oferta].CodOferta, 
                         dbo.[vt_Principales_Contrataciones_Detalle por Oferta].DesOferta, dbo.[vt_Principales_Contrataciones_Detalle por Oferta].Reg, 
                         dbo.[vt_Principales_Contrataciones_Detalle por Oferta].Causa, dbo.[vt_Principales_Contrataciones_Detalle por Oferta].ImpAd, 
                         dbo.vt_Principales_Contrataciones_Importe_i.Total AS Imp
FROM            dbo.vt_Principales_Contrataciones_Importe_i INNER JOIN
                         dbo.[vt_Principales_Contrataciones_Detalle por Oferta] ON 
                         dbo.vt_Principales_Contrataciones_Importe_i.ClienteAgrupado = dbo.[vt_Principales_Contrataciones_Detalle por Oferta].ClienteAgrupado AND 
                         dbo.vt_Principales_Contrataciones_Importe_i.NomProyecto = dbo.[vt_Principales_Contrataciones_Detalle por Oferta].NomProyecto

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
         Begin Table = "vt_Principales_Contrataciones_Importe_i"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vt_Principales_Contrataciones_Detalle por Oferta"
            Begin Extent = 
               Top = 6
               Left = 285
               Bottom = 135
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vf_Principales_Contrataciones_Informe_Detalle_x_Importe_y_Año';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vf_Principales_Contrataciones_Informe_Detalle_x_Importe_y_Año';

