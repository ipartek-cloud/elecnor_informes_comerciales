CREATE VIEW dbo.vwRegularizaciones_AsociadasInversion_Pais_Cliente_Desglose
AS
SELECT     dbo.vwRegularizaciones_AsociadasInversion.CodCentro, dbo.vwRegularizaciones_AsociadasInversion.CodOferta, 
                      dbo.vwRegularizaciones_AsociadasInversion.NumRegularizacion, dbo.vwRegularizaciones_AsociadasInversion.FAlta, 
                      dbo.vwRegularizaciones_AsociadasInversion.DescripcionOferta, dbo.vwRegularizaciones_AsociadasInversion.CodCliente, 
                      dbo.vwRegularizaciones_AsociadasInversion.Localidad, dbo.vwRegularizaciones_AsociadasInversion.CodProv, 
                      dbo.vwRegularizaciones_AsociadasInversion.ImporteAprox, dbo.vwRegularizaciones_AsociadasInversion.CodAct1, 
                      dbo.vwRegularizaciones_AsociadasInversion.CodAct2, dbo.vwRegularizaciones_AsociadasInversion.CodResponsable, 
                      dbo.vwRegularizaciones_AsociadasInversion.FPresentacion, dbo.vwRegularizaciones_AsociadasInversion.PresupuestoVenta, 
                      dbo.vwRegularizaciones_AsociadasInversion.FAdjudicacion, dbo.vwRegularizaciones_AsociadasInversion.AñoAdjudicacion, 
                      dbo.vwRegularizaciones_AsociadasInversion.MesAdjudicacion, dbo.vwRegularizaciones_AsociadasInversion.ImporteContratado, 
                      dbo.vwRegularizaciones_AsociadasInversion.ASOCIADAINVERSION, dbo.ClientesSQL.NombreCliente, dbo.ClientesSQL.NomAgrupado, 
                      dbo.ClientesSQL.NomAgrupadoDesglose, dbo.ClientesSQL.Pais, dbo.Provincias.Pais AS Mercado
FROM         dbo.vwRegularizaciones_AsociadasInversion INNER JOIN
                      dbo.Provincias ON dbo.vwRegularizaciones_AsociadasInversion.CodProv = dbo.Provincias.CDPRO LEFT OUTER JOIN
                      dbo.ClientesSQL ON dbo.vwRegularizaciones_AsociadasInversion.CodCliente = dbo.ClientesSQL.CodCliente
WHERE     (dbo.ClientesSQL.VisibleDesglose = 1)

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
         Begin Table = "vwRegularizaciones_AsociadasInversion"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Provincias"
            Begin Extent = 
               Top = 226
               Left = 510
               Bottom = 334
               Right = 699
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientesSQL"
            Begin Extent = 
               Top = 6
               Left = 492
               Bottom = 114
               Right = 683
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwRegularizaciones_AsociadasInversion_Pais_Cliente_Desglose';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwRegularizaciones_AsociadasInversion_Pais_Cliente_Desglose';

