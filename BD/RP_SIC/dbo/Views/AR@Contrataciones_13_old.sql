CREATE VIEW dbo.[AR@Contrataciones_13_old]
AS
SELECT     TOP (100) PERCENT YEAR(dbo.fgConvertirFechaDMY(dbo.Ofertas.FECHAD)) AS AñoAd, MONTH(dbo.fgConvertirFechaDMY(dbo.Ofertas.FECHAD)) AS MesAd, 
                      dbo.Provincias.Pais AS Mercado, dbo.Sumarigrama.CodDDirNegocio AS Dn, dbo.Sumarigrama.CodDelegacion AS Dele, dbo.Ofertas.CDCEN AS Ct, 
                      dbo.Ofertas.CDOFT AS CodOfer, dbo.Ofertas.DCOF AS DesOfer, dbo.Ofertas.PREAD AS Importe, dbo.Ofertas.LOCAL AS Localidad, dbo.Ofertas.PROOF AS CodProvincia, 
                      dbo.Provincias.NMPRO AS NomProvincia, dbo.Ofertas.CDCLI AS CodCliente, dbo.ClientesSQL.NombreCliente AS NomCliente, 
                      dbo.ClientesSQL.NomAgrupado AS ClienAgrupado, dbo.Ofertas.CDAC1 AS Act1, dbo.Ofertas.CDAC2 AS Act2
FROM         dbo.Ofertas INNER JOIN
                      dbo.Provincias ON dbo.Ofertas.PROOF = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.Ofertas.CDCEN = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
                      dbo.ClientesSQL ON dbo.Ofertas.CDCLI = dbo.ClientesSQL.CodCliente
WHERE     (YEAR(dbo.fgConvertirFechaDMY(dbo.Ofertas.FECHAD)) >= 2005) AND (dbo.Ofertas.ADELE = 'S')

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[30] 2[24] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1[50] 4[25] 3) )"
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
         Begin Table = "Ofertas"
            Begin Extent = 
               Top = 0
               Left = 288
               Bottom = 223
               Right = 480
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Provincias"
            Begin Extent = 
               Top = 0
               Left = 689
               Bottom = 119
               Right = 887
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Sumarigrama"
            Begin Extent = 
               Top = 52
               Left = 5
               Bottom = 202
               Right = 223
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "ClientesSQL"
            Begin Extent = 
               Top = 139
               Left = 577
               Bottom = 258
               Right = 775
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
      Begin ColumnWidths = 18
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
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 5685
         Alias = 1620
         Table = 1170
         Output = 720
       ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'AR@Contrataciones_13_old';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'  Append = 1400
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'AR@Contrataciones_13_old';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'AR@Contrataciones_13_old';

