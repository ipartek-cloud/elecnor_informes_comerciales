CREATE VIEW dbo.vwCarteraDiferidaAnual_2018_Mayo
AS
SELECT        TOP (100) PERCENT dbo.Sumarigrama.CodDirGeneral, dbo.Sumarigrama.NombreDirGeneral, dbo.Sumarigrama.CodSubDirGeneral, 
                         dbo.Sumarigrama.NombreSubDirGeneral, dbo.Sumarigrama.CodDDirNegocio, dbo.Sumarigrama.NombreDirNegocio, dbo.Sumarigrama.CodSubDirNegocioArea, 
                         dbo.Sumarigrama.NombreSubDirNegocioArea, dbo.Sumarigrama.CodDelegacion, dbo.Sumarigrama.NombreDelegacion, dbo.Sumarigrama.CodCentro, 
                         dbo.Sumarigrama.NombreCentro, Cart_DiferidaContratosSQL.Contrato, Cart_DiferidaContratosSQL.Cliente, Cart_DiferidaContratosSQL.Gerencia, 
                         Cart_DiferidaContratosSQL.FInicio, Cart_DiferidaContratosSQL.FFinal, Cart_DiferidaContratosSQL.FFinalEfectiva, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, Cart_DiferidaContratosSQL.Tipo, Cart_DiferidaContratosSQL.Mercado, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre AS PrevistoAño, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres * dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre - dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio
                          AS Nuevo, ISNULL(dbo.vwCarteraDiferidaSQLContratado.AñoSQL, 0) + ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) AS Contrat, 
                         ISNULL(dbo.vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS TrimSQL, ISNULL(vwContratacion_SQL_AS400_2018.Importe, 0) 
                         - ISNULL(dbo.vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS Regu, ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, 0) 
                         * ISNULL(dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 0) - ISNULL(dbo.vwCarteraDiferidaSQLContratado.TrimSQL, 0) AS A2018, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1 AS A2019, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2 AS A2020, 
                         Cart_DiferidaContratosSQL.Prorrogable
FROM            (SELECT        ID, Contrato, Cliente, CodigoContratoClient, Gerencia, Prorrogable, Tipo, Mercado, FInicio, FFinal, FFinalEfectiva, Zona
                          FROM            dbo.fnCart_DiferidaContratosSQL('A') AS fnCart_DiferidaContratosSQL_1) AS Cart_DiferidaContratosSQL INNER JOIN
                         dbo.Cart_DiferidaOfertasContratos_2016SQL ON Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
                         dbo.Sumarigrama ON dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
                         dbo.vwCarteraDiferidaSQLContratado ON dbo.Sumarigrama.Año = dbo.vwCarteraDiferidaSQLContratado.Año AND 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = dbo.vwCarteraDiferidaSQLContratado.CodOferta LEFT OUTER JOIN
                             (SELECT        CodCentro, CODOFER, DESOFER, CODCLIENTE, NOMCLIENTE, Importe
                               FROM            dbo.fnContratacionAcumulada_SQL_AS400_2018(5) AS fnContratacionAcumulada_SQL_AS400_2018_1) AS vwContratacion_SQL_AS400_2018 ON 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = vwContratacion_SQL_AS400_2018.CODOFER

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'iteriaPane = 
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwCarteraDiferidaAnual_2018_Mayo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwCarteraDiferidaAnual_2018_Mayo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[56] 4[4] 2[20] 3) )"
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
               Bottom = 135
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Cart_DiferidaOfertasContratos_2016SQL"
            Begin Extent = 
               Top = 144
               Left = 456
               Bottom = 456
               Right = 665
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Sumarigrama"
            Begin Extent = 
               Top = 212
               Left = 17
               Bottom = 341
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwContratacion_SQL_AS400_2018"
            Begin Extent = 
               Top = 256
               Left = 1057
               Bottom = 385
               Right = 1266
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "vwCarteraDiferidaSQLContratado"
            Begin Extent = 
               Top = 84
               Left = 912
               Bottom = 213
               Right = 1121
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
   Begin Cr', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwCarteraDiferidaAnual_2018_Mayo';

