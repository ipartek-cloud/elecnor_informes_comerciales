CREATE VIEW dbo.vwOfertasAsociadasInversion
AS
SELECT     dbo.vwOfertasAI.CDCEN AS CodCentro, dbo.vwOfertasAI.CDOFT AS CodOferta, 0 AS NumRegularizacion, 
                      dbo.fgConvertirFechaDMY(dbo.vwOfertasAI.FECHAA) AS FAlta, dbo.vwOfertasAI.DCOF AS DescripcionOferta, dbo.vwOfertasAI.CDCLI AS CodCliente, 
                      dbo.vwOfertasAI.LOCAL AS Localidad, dbo.vwOfertasAI.PROOF AS CodProv, dbo.vwOfertasAI.IMAOF AS ImporteAprox, 
                      dbo.vwOfertasAI.CDAC1 AS CodAct1, dbo.vwOfertasAI.CDAC2 AS CodAct2, dbo.vwOfertasAI.RPROF AS CodResponsable, 
                      dbo.fgConvertirFechaDMY(dbo.vwOfertasAI.FECHPP) AS FPresentacion, dbo.vwOfertasAI.PREVE AS PresupuestoVenta, 
                      dbo.fgConvertirFechaDMY(dbo.vwOfertasAI.FECHAD) AS FAdjudicacion, YEAR(dbo.fgConvertirFechaDMY(dbo.vwOfertasAI.FECHAD)) 
                      AS AñoAdjudicacion, MONTH(dbo.fgConvertirFechaDMY(dbo.vwOfertasAI.FECHAD)) AS MesAdjudicacion, dbo.vwOfertasAI.ADELE AS Adjudicada, 
                      dbo.vwOfertasAI.PREAD AS ImporteContratado, dbo.Provincias.Pais
FROM         dbo.vwOfertasAI INNER JOIN
                      dbo.Provincias ON dbo.vwOfertasAI.PROOF = dbo.Provincias.CDPRO

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
         Begin Table = "Provincias"
            Begin Extent = 
               Top = 7
               Left = 439
               Bottom = 115
               Right = 628
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwOfertasAI"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 227
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
      Begin ColumnWidths = 21
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwOfertasAsociadasInversion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwOfertasAsociadasInversion';

