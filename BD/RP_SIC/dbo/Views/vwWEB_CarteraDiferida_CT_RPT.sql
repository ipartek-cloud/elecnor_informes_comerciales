CREATE VIEW dbo.vwWEB_CarteraDiferida_CT_RPT
AS
SELECT        Usuario, Gerencia, Cliente, Contrato, CodDDirNegocio, CodDelegacion, CodCentro, SUM(Total) AS Total_CT, SUM(Total / 12 * Mes) AS Lineal_CT, SUM(Contrat) 
                         AS Contrat_CT, SUM(CarteraPendiente) AS CarteraPendiente_CT, SUM(Produccion_A) AS Produccion_A_CT, SUM(MargenProduccion_A) AS MargenProduccion_A_CT, 
                         CASE SUM(Produccion_A) WHEN 0 THEN 0 ELSE 100 * SUM(MargenProduccion_A) / SUM(Produccion_A) END AS PorcentajeProduccion_CT, SUM(A_Año) 
                         AS A_Año_CT, SUM(A_Año1) AS A_Año1_CT, SUM(Facturacion_Origen_A) AS Facturacion_Origen_A_CT, SUM(Facturacion_Anticipada_A) 
                         AS Facturacion_Anticipada_A_CT, SUM(Produccion_Curso_A) AS Produccion_Curso_A_CT, SUM(Facturacion_A) AS Facturacion_A_CT
FROM            dbo.vwWEB_CarteraDiferida_CT_Agrup
GROUP BY Usuario, Gerencia, Cliente, Contrato, CodDDirNegocio, CodDelegacion, CodCentro

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
         Begin Table = "vwWEB_CarteraDiferida_CT_Agrup"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 352
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 9
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
      Begin ColumnWidths = 12
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_CT_RPT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_CT_RPT';

