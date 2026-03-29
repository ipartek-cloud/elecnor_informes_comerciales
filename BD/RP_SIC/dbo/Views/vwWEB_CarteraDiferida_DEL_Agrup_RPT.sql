CREATE VIEW dbo.vwWEB_CarteraDiferida_DEL_Agrup_RPT
AS
SELECT        dbo.vwWEB_CarteraDiferida_DEL_Agrup.Usuario, dbo.vwWEB_CarteraDiferida_DEL_Agrup.Año, dbo.vwWEB_CarteraDiferida_DEL_Agrup.Mes, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Gerencia, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Total_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Lineal_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Contrat_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.CarteraPendiente_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Produccion_A_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.MargenProduccion_A_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.PorcentajeProduccion_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.A_Año_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.A_Año1_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Facturacion_Origen_A_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Facturacion_Anticipada_A_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Produccion_Curso_A_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Facturacion_A_GER, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Cliente, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Total_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Lineal_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Contrat_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.CarteraPendiente_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Produccion_A_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.MargenProduccion_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.PorcentajeProduccion_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.A_Año_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.A_Año1_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Facturacion_Origen_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Facturacion_Anticipada_A_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Produccion_Curso_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Facturacion_A_CLI, dbo.vwWEB_CarteraDiferida_DEL_Agrup.Contrato, 
                         ISNULL(dbo.vwWEB_CarteraDiferida_DEL_Agrup.FInicio, '') AS Finicio, ISNULL(dbo.vwWEB_CarteraDiferida_DEL_Agrup.FFinal, '') AS FFinal, 
                         ISNULL(dbo.vwWEB_CarteraDiferida_DEL_Agrup.Prorroga, '') AS Prorroga, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Total_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Lineal_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Contrat_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.CarteraPendiente_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Produccion_A_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.MargenProduccion_A_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.PorcentajeProduccion_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.A_Año_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.A_Año1_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Facturacion_Origen_A_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Facturacion_Anticipada_A_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Produccion_Curso_A_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Facturacion_A_CON, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.CodDDirNegocio, RTRIM(dbo.vwWEB_CarteraDiferida_DEL_Agrup.NombreDirNegocio) 
                         + ' (' + LTRIM(STR(dbo.vwWEB_CarteraDiferida_DEL_Agrup.CodDDirNegocio)) + ')' AS NombreDirNegocio, dbo.vwWEB_CarteraDiferida_DN_RPT.Total_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.Lineal_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.Contrat_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.CarteraPendiente_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.Produccion_A_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.MargenProduccion_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.PorcentajeProduccion_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.A_Año_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.A_Año1_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.Facturacion_Origen_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.Facturacion_Anticipada_A_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.Produccion_Curso_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.Facturacion_A_DN, dbo.vwWEB_CarteraDiferida_DEL_Agrup.CodDelegacion, 
                         RTRIM(dbo.vwWEB_CarteraDiferida_DEL_Agrup.NombreDelegacion) + ' (' + LTRIM(STR(dbo.vwWEB_CarteraDiferida_DEL_Agrup.CodDelegacion)) 
                         + ')' AS NombreDelegacion, dbo.vwWEB_CarteraDiferida_DEL_Agrup.Total, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Total / 12 * dbo.vwWEB_CarteraDiferida_DEL_Agrup.Mes AS Lineal, dbo.vwWEB_CarteraDiferida_DEL_Agrup.Contrat, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.CarteraPendiente, dbo.vwWEB_CarteraDiferida_DEL_Agrup.Produccion_A, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.MargenProduccion_A, 
                         CASE Produccion_A WHEN 0 THEN 0 ELSE 100 * MargenProduccion_A / Produccion_A END AS PorcentajeProduccion, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.A_Año, dbo.vwWEB_CarteraDiferida_DEL_Agrup.A_Año1, dbo.vwWEB_CarteraDiferida_DEL_Agrup.Facturacion_Origen_A, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Facturacion_Anticipada_A, dbo.vwWEB_CarteraDiferida_DEL_Agrup.Produccion_Curso_A, 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Facturacion_A
FROM            dbo.vwWEB_CarteraDiferida_DEL_Agrup INNER JOIN
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT ON dbo.vwWEB_CarteraDiferida_DEL_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Gerencia INNER JOIN
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT ON dbo.vwWEB_CarteraDiferida_DEL_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Gerencia AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Cliente INNER JOIN
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT ON dbo.vwWEB_CarteraDiferida_DEL_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Gerencia AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Cliente AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Contrato = dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Contrato INNER JOIN
                         dbo.vwWEB_CarteraDiferida_DN_RPT ON dbo.vwWEB_CarteraDiferida_DEL_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_DN_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_DN_RPT.Gerencia AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_DN_RPT.Cliente AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.Contrato = dbo.vwWEB_CarteraDiferida_DN_RPT.Contrato AND 
                         dbo.vwWEB_CarteraDiferida_DEL_Agrup.CodDDirNegocio = dbo.vwWEB_CarteraDiferida_DN_RPT.CodDDirNegocio

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'      Width = 1695
         Width = 2310
         Width = 2340
         Width = 1500
         Width = 1500
         Width = 2700
         Width = 2640
         Width = 2235
         Width = 1710
         Width = 1500
         Width = 1695
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
         Width = 2265
         Width = 2580
         Width = 2175
         Width = 1650
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
         Column = 5115
         Alias = 1515
         Table = 4950
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_DEL_Agrup_RPT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_DEL_Agrup_RPT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[29] 4[35] 2[7] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1[36] 4[26] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[38] 2[37] 3) )"
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
         Begin Table = "vwWEB_CarteraDiferida_DEL_Agrup"
            Begin Extent = 
               Top = 12
               Left = 21
               Bottom = 304
               Right = 390
            End
            DisplayFlags = 280
            TopColumn = 15
         End
         Begin Table = "vwWEB_CarteraDiferida_GERENCIA_RPT"
            Begin Extent = 
               Top = 9
               Left = 767
               Bottom = 70
               Right = 1105
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "vwWEB_CarteraDiferida_CLIENTE_RPT"
            Begin Extent = 
               Top = 71
               Left = 766
               Bottom = 132
               Right = 1109
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "vwWEB_CarteraDiferida_DN_RPT"
            Begin Extent = 
               Top = 212
               Left = 777
               Bottom = 273
               Right = 1113
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "vwWEB_CarteraDiferida_CONTRATO_RPT"
            Begin Extent = 
               Top = 141
               Left = 774
               Bottom = 202
               Right = 1111
            End
            DisplayFlags = 280
            TopColumn = 8
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 72
         Width = 284
         Width = 1500
         Width = 525
         Width = 525
         Width = 1395
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
   ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_DEL_Agrup_RPT';

