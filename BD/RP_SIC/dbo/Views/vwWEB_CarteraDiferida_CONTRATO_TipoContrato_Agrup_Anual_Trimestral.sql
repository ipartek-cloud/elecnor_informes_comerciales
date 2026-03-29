CREATE VIEW dbo.vwWEB_CarteraDiferida_CONTRATO_TipoContrato_Agrup_Anual_Trimestral
AS
SELECT        Usuario, Año, Mes, Gerencia, AGRUP, Cliente, Contrato, SUM(CASE TIPO WHEN 'T' THEN NTrimestre * MontoTrimestre ELSE MontoAnual END) AS Total, 
                         SUM(Contrat) AS Contrat, SUM(CarteraPendiente) AS CarteraPendiente, SUM(Produccion_A) AS Produccion_A, SUM(MargenProduccion_A) AS MargenProduccion_A, 
                         SUM(A_Año) AS A_Año, SUM(A_Año1) AS A_Año1, FInicio, FFinal, FFinalEfectiva AS Prorroga, SUM(Facturacion_Origen_A) AS Facturacion_Origen_A, 
                         SUM(Facturacion_Anticipada_A) AS Facturacion_Anticipada_A, SUM(Produccion_Curso_A) AS Produccion_Curso_A, SUM(Facturacion_A) AS Facturacion_A
FROM            dbo.WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
WHERE        (NOT (CASE TIPO WHEN 'T' THEN NTrimestre * MontoTrimestre ELSE MontoAnual END < 0.5)) OR
                         (NOT (Contrat < 0.5)) OR
                         (NOT (CarteraPendiente < 0.5)) OR
                         (NOT (Facturacion_A < 0.5)) OR
                         (NOT (Produccion_A < 0.5)) OR
                         (NOT (Facturacion_Anticipada_A < 0.5)) OR
                         (NOT (Produccion_Curso_A < 0.5)) OR
                         (NOT (A_Año1 < 0.5)) OR
                         (NOT (A_Año < 0.5))
GROUP BY Usuario, Año, Mes, Gerencia, Cliente, AGRUP, Contrato, FInicio, FFinal, FFinalEfectiva

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
         Begin Table = "WEB_CarteraDiferidaPdteEjecutarUsuarioCentro"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 291
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
      Begin ColumnWidths = 18
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
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_CONTRATO_TipoContrato_Agrup_Anual_Trimestral';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_CONTRATO_TipoContrato_Agrup_Anual_Trimestral';

