CREATE VIEW dbo.vwContratacion_AS400_2019
AS
SELECT        Contratacion_AS400_2019.AÑOAD AS Año, Contratacion_AS400_2019.MESAD AS Mes, Contratacion_AS400_2019.CT AS CodCentro, 
                         Contratacion_AS400_2019.CODOFER, Contratacion_AS400_2019.DESOFER, Contratacion_AS400_2019.CODCLIENTE, 
                         dbo.ClientesSQL.NomAgrupado AS NOMCLIENTE, Contratacion_AS400_2019.IMPAD AS Importe
FROM            OPENQUERY(SIC, 
                         'SELECT  AÑOAD, MESAD , CT , CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, IMPAD FROM S44DD901.ICOMERF.OFERREGU WHERE AÑOAD = 2019 AND ADJUDICADA = ''S'' ')
                          AS Contratacion_AS400_2019 LEFT OUTER JOIN
                         dbo.ClientesSQL ON Contratacion_AS400_2019.CODCLIENTE = dbo.ClientesSQL.CodCliente
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwContratacion_AS400_2019';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[14] 3) )"
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
         Begin Table = "Contratacion_AS400_2019"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 204
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientesSQL"
            Begin Extent = 
               Top = 9
               Left = 616
               Bottom = 138
               Right = 832
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
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 3030
         Width = 1500
         Width = 3465
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3090
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwContratacion_AS400_2019';

