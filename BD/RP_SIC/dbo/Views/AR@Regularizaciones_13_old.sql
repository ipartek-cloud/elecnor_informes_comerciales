CREATE VIEW dbo.[AR@Regularizaciones_13_old]
AS
SELECT     TOP (100) PERCENT YEAR(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR)) AS AñoAd, MONTH(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR)) 
                      AS MesAd, dbo.Provincias.Pais AS Mercado, dbo.Sumarigrama.CodDDirNegocio AS Dn, dbo.Sumarigrama.CodDelegacion AS Dele, 
                      dbo.Regularizaciones.CDCEN AS CT, dbo.Ofertas.CDOFT AS CodOferta, dbo.Ofertas.DCOF AS DesOferta, dbo.Regularizaciones.NUMRE AS Reg, 
                      dbo.Regularizaciones.CAUS AS Causa, dbo.Regularizaciones.IMPRE AS Importe, dbo.Ofertas.LOCAL AS Localidad, dbo.Ofertas.PROOF AS CodProvincia, 
                      dbo.Provincias.NMPRO AS NomProvincia, dbo.Ofertas.CDCLI AS CodCliente, dbo.ClientesSQL.NombreCliente AS NomCliente, 
                      dbo.ClientesSQL.NomAgrupado AS ClienAgrupado, dbo.Ofertas.CDAC1 AS Act1, dbo.Ofertas.CDAC2 AS Act2, dbo.Ofertas.CDCEN
FROM         dbo.Regularizaciones INNER JOIN
                      dbo.Ofertas ON dbo.Regularizaciones.CDOFT = dbo.Ofertas.CDOFT INNER JOIN
                      dbo.Provincias ON dbo.Ofertas.PROOF = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.Ofertas.CDCEN = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
                      dbo.ClientesSQL ON dbo.Ofertas.CDCLI = dbo.ClientesSQL.CodCliente
WHERE     (YEAR(dbo.fgConvertirFechaDMY(dbo.Regularizaciones.FECHAR)) >= 2005)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'AR@Regularizaciones_13_old';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[29] 2[7] 3) )"
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
         Begin Table = "Regularizaciones"
            Begin Extent = 
               Top = 2
               Left = 579
               Bottom = 121
               Right = 777
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Ofertas"
            Begin Extent = 
               Top = 27
               Left = 291
               Bottom = 207
               Right = 489
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Provincias"
            Begin Extent = 
               Top = 121
               Left = 561
               Bottom = 240
               Right = 759
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Sumarigrama"
            Begin Extent = 
               Top = 0
               Left = 16
               Bottom = 140
               Right = 234
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "ClientesSQL"
            Begin Extent = 
               Top = 155
               Left = 42
               Bottom = 274
               Right = 240
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
         Width = 15', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'AR@Regularizaciones_13_old';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'00
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
         Column = 5955
         Alias = 1365
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'AR@Regularizaciones_13_old';

