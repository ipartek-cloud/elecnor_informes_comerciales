CREATE VIEW dbo.vwWEB_OfertacionDetallada
AS
SELECT        dbo.WEB_OfertacionDetalladaUsuarioCentro.Usuario, dbo.WEB_OfertacionDetalladaUsuarioCentro.CodCentro, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.CodOferta, dbo.WEB_OfertacionDetalladaUsuarioCentro.FAlta, dbo.WEB_OfertacionDetalladaUsuarioCentro.ImporteAlta, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.FPresentacion, dbo.WEB_OfertacionDetalladaUsuarioCentro.ImportePresentacion, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.FAdjudicacion, dbo.WEB_OfertacionDetalladaUsuarioCentro.DescripcionOferta, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.Regularizacion, dbo.WEB_OfertacionDetalladaUsuarioCentro.CausaRegularizacion, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.ImporteContratado, dbo.WEB_OfertacionDetalladaUsuarioCentro.Localidad, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.CodCliente, dbo.WEB_OfertacionDetalladaUsuarioCentro.CodAct1, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.CodAct2, dbo.WEB_OfertacionDetalladaUsuarioCentro.CodProv, dbo.Provincias.NMPRO AS NombreProvincia, 
                         dbo.Provincias.Pais, dbo.WEB_OfertacionDetalladaUsuarioCentro.Adjudicada, dbo.WEB_OfertacionDetalladaUsuarioCentro.CodResponsable, 
                         ISNULL(dbo.ClientesSQL.NombreCliente, dbo.Ofertas_Clientes.DESPRO) AS NombreCliente
FROM            dbo.WEB_OfertacionDetalladaUsuarioCentro LEFT OUTER JOIN
                         dbo.Ofertas_Clientes ON dbo.WEB_OfertacionDetalladaUsuarioCentro.CodOferta = dbo.Ofertas_Clientes.CDOFT LEFT OUTER JOIN
                         dbo.Provincias ON dbo.WEB_OfertacionDetalladaUsuarioCentro.CodProv = dbo.Provincias.CDPRO LEFT OUTER JOIN
                         dbo.ClientesSQL ON dbo.WEB_OfertacionDetalladaUsuarioCentro.CodCliente = dbo.ClientesSQL.CodCliente

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[55] 4[5] 2[21] 3) )"
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
         Begin Table = "WEB_OfertacionDetalladaUsuarioCentro"
            Begin Extent = 
               Top = 36
               Left = 480
               Bottom = 488
               Right = 790
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Provincias"
            Begin Extent = 
               Top = 0
               Left = 0
               Bottom = 279
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientesSQL"
            Begin Extent = 
               Top = 281
               Left = 10
               Bottom = 505
               Right = 343
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Ofertas_Clientes"
            Begin Extent = 
               Top = 48
               Left = 968
               Bottom = 160
               Right = 1177
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
      Begin ColumnWidths = 23
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
      End
   End
   Begi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_OfertacionDetallada';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'n CriteriaPane = 
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_OfertacionDetallada';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_OfertacionDetallada';

