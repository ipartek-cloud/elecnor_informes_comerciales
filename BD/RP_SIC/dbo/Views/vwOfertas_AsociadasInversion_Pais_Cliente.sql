CREATE VIEW dbo.vwOfertas_AsociadasInversion_Pais_Cliente
AS
SELECT     dbo.vwOfertas_AsociadasInversion.CDCEN AS CodCentro, dbo.vwOfertas_AsociadasInversion.CDOFT AS CodOferta, 0 AS NumRegularizacion, 
                      dbo.fgConvertirFechaDMY(dbo.vwOfertas_AsociadasInversion.FECHAA) AS FAlta, dbo.vwOfertas_AsociadasInversion.DCOF AS DescripcionOferta, 
                      dbo.vwOfertas_AsociadasInversion.CDCLI AS CodCliente, dbo.vwOfertas_AsociadasInversion.LOCAL AS Localidad, 
                      dbo.vwOfertas_AsociadasInversion.PROOF AS CodProv, dbo.vwOfertas_AsociadasInversion.IMAOF AS ImporteAprox, 
                      dbo.vwOfertas_AsociadasInversion.CDAC1 AS CodAct1, dbo.vwOfertas_AsociadasInversion.CDAC2 AS CodAct2, 
                      dbo.vwOfertas_AsociadasInversion.RPROF AS CodResponsable, dbo.fgConvertirFechaDMY(dbo.vwOfertas_AsociadasInversion.FECHPP) 
                      AS FPresentacion, dbo.vwOfertas_AsociadasInversion.PREVE AS PresupuestoVenta, 
                      dbo.fgConvertirFechaDMY(dbo.vwOfertas_AsociadasInversion.FECHAD) AS FAdjudicacion, 
                      YEAR(dbo.fgConvertirFechaDMY(dbo.vwOfertas_AsociadasInversion.FECHAD)) AS AñoAdjudicacion, 
                      MONTH(dbo.fgConvertirFechaDMY(dbo.vwOfertas_AsociadasInversion.FECHAD)) AS MesAdjudicacion, 
                      dbo.vwOfertas_AsociadasInversion.ADELE AS Adjudicada, dbo.vwOfertas_AsociadasInversion.PREAD AS ImporteContratado, 
                      dbo.Provincias.Pais AS Mercado, dbo.vwOfertas_AsociadasInversion.ASOCIADAINVERSION, dbo.ClientesSQL.NombreCliente, 
                      dbo.ClientesSQL.NomAgrupado, dbo.ClientesSQL.Pais
FROM         dbo.vwOfertas_AsociadasInversion INNER JOIN
                      dbo.Provincias ON dbo.vwOfertas_AsociadasInversion.PROOF = dbo.Provincias.CDPRO LEFT OUTER JOIN
                      dbo.ClientesSQL ON dbo.vwOfertas_AsociadasInversion.CDCLI = dbo.ClientesSQL.CodCliente

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
         Begin Table = "vwOfertas_AsociadasInversion"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 211
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Provincias"
            Begin Extent = 
               Top = 118
               Left = 299
               Bottom = 226
               Right = 488
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "ClientesSQL"
            Begin Extent = 
               Top = 5
               Left = 567
               Bottom = 154
               Right = 756
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
      Begin ColumnWidths = 25
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
         SortO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwOfertas_AsociadasInversion_Pais_Cliente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'rder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwOfertas_AsociadasInversion_Pais_Cliente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwOfertas_AsociadasInversion_Pais_Cliente';

