CREATE VIEW dbo.vwCart_DiferidaOfertasContratosSQL
AS
SELECT        dbo.Cart_DiferidaContratosSQL.ID, dbo.Cart_DiferidaContratosSQL.Contrato, dbo.Cart_DiferidaContratosSQL.Cliente, dbo.Cart_DiferidaContratosSQL.FInicio, 
                         dbo.Cart_DiferidaContratosSQL.FFinal, dbo.Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaContratosSQL.Tipo, dbo.Cart_DiferidaContratosSQL.Mercado, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Año, dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, 
                         dbo.NomOfertasSQL.DesOferta, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto3, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto4, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Meses
FROM            dbo.Cart_DiferidaContratosSQL INNER JOIN
                         dbo.Cart_DiferidaOfertasContratos_2016SQL ON dbo.Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
                         dbo.NomOfertasSQL ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = dbo.NomOfertasSQL.CodOferta
WHERE        (dbo.Cart_DiferidaContratosSQL.Tipo = 'T') AND (dbo.Cart_DiferidaContratosSQL.Vigente = 1) OR
                         (dbo.Cart_DiferidaContratosSQL.Tipo = 'A') AND (dbo.Cart_DiferidaContratosSQL.Vigente = 1)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwCart_DiferidaOfertasContratosSQL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[10] 2[14] 3) )"
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
         Begin Table = "Cart_DiferidaContratosSQL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 312
               Right = 454
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Cart_DiferidaOfertasContratos_2016SQL"
            Begin Extent = 
               Top = 8
               Left = 533
               Bottom = 340
               Right = 1145
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "NomOfertasSQL"
            Begin Extent = 
               Top = 45
               Left = 1216
               Bottom = 140
               Right = 1425
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
         Width = 3285
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 4245
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
  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwCart_DiferidaOfertasContratosSQL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwCart_DiferidaOfertasContratosSQL';

