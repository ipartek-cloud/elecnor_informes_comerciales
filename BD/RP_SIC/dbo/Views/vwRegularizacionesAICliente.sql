CREATE VIEW dbo.vwRegularizacionesAICliente
AS
SELECT     dbo.Regularizaciones.CDCEN AS CodCentro, dbo.Regularizaciones.CDOFT AS CodOferta, ISNULL(dbo.Regularizaciones.NUMRE, 0) 
                      AS NumRegularizacion, dbo.fgConvertirFechaDMY(dbo.vwOfertasAI.FECHAA) AS FAlta, dbo.vwOfertasAI.DCOF AS DescripcionOferta, 
                      dbo.vwOfertasAI.CDCLI AS CodCliente, dbo.vwOfertasAI.LOCAL AS Localidad, dbo.vwOfertasAI.PROOF AS CodProv, 
                      dbo.vwOfertasAI.IMAOF AS ImporteAprox, dbo.vwOfertasAI.CDAC1 AS CodAct1, dbo.vwOfertasAI.CDAC2 AS CodAct2, 
                      dbo.vwOfertasAI.RPROF AS CodResponsable, dbo.fgConvertirFechaDMY(dbo.vwOfertasAI.FECHPP) AS FPresentacion, 
                      dbo.vwOfertasAI.PREVE AS PresupuestoVenta, dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR) AS FAdjudicacion, 
                      YEAR(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR)) AS AñoAdjudicacion, 
                      MONTH(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR)) AS MesAdjudicacion, dbo.vwOfertasAI.ADELE AS Adjudicada, 
                      dbo.Regularizaciones.IMPRE AS ImporteContratado, dbo.Provincias.Pais, dbo.fnNombrePais(dbo.Provincias.CDAUT, dbo.Provincias.NMPRO) 
                      AS NombrePais, dbo.Clientes.NAUX AS NombreCliente
FROM         dbo.vwOfertasAI INNER JOIN
                      dbo.Regularizaciones ON dbo.vwOfertasAI.CDOFT = dbo.Regularizaciones.CDOFT INNER JOIN
                      dbo.Provincias ON dbo.vwOfertasAI.PROOF = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Clientes ON dbo.vwOfertasAI.CDCLI = dbo.Clientes.AUX
WHERE     (dbo.vwOfertasAI.ADELE = 's')

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
         Configuration = "(H (1[50] 2[40] 3) )"
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
      ActivePaneConfig = 2
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwOfertasAI"
            Begin Extent = 
               Top = 51
               Left = 347
               Bottom = 159
               Right = 536
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Regularizaciones"
            Begin Extent = 
               Top = 88
               Left = 17
               Bottom = 196
               Right = 206
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Provincias"
            Begin Extent = 
               Top = 6
               Left = 574
               Bottom = 114
               Right = 763
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Clientes"
            Begin Extent = 
               Top = 6
               Left = 801
               Bottom = 114
               Right = 990
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
      PaneHidden = 
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
         Or = 135', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwRegularizacionesAICliente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'0
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwRegularizacionesAICliente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwRegularizacionesAICliente';

