CREATE VIEW dbo.vwTIPOUNO_ProduccionElecnor_Detallado
AS
SELECT        dbo.ObrasActualesSQL.Año, dbo.ObrasActualesSQL.Mes, dbo.vwTipoUNO.CTRO AS CodCentro, 'E' AS TipoOferta, 1 AS CodOferta, 0 AS ContratoMarco, 
                         '' AS DescripcionOferta, '-' AS FAdjudicacion, 0 AS ImporteContratado, 
                         dbo.vwTipoUNO.OBRA + '-' + dbo.vwTipoUNO.OBRAL + ' ' + dbo.ObrasActualesSQL.DSOBR AS NombreObra, SUM(dbo.ObrasActualesSQL.SOP) 
                         AS ImporteProduccion, dbo.ObrasActualesSQL.SOF AS ImporteFactura, dbo.ObrasActualesSQL.SOL AS ImporteFot, dbo.ObrasActualesSQL.STOBR AS Est, 
                         dbo.vwTipoUNO.FechaApertura, dbo.vwTipoUNO.FechaCierre, dbo.ObrasActualesSQL.CDCLI AS CodCliente
FROM            dbo.vwTipoUNO INNER JOIN
                         dbo.ObrasActualesSQL ON dbo.vwTipoUNO.CTRO = dbo.ObrasActualesSQL.CTR AND dbo.vwTipoUNO.OBRA = dbo.ObrasActualesSQL.OBRA AND 
                         dbo.vwTipoUNO.OBRAL = dbo.ObrasActualesSQL.OBRAL
GROUP BY dbo.ObrasActualesSQL.Año, dbo.ObrasActualesSQL.Mes, dbo.vwTipoUNO.CTRO, dbo.vwTipoUNO.OBRA, dbo.vwTipoUNO.OBRAL, dbo.ObrasActualesSQL.DSOBR, 
                         dbo.ObrasActualesSQL.STOBR, dbo.vwTipoUNO.FechaApertura, dbo.vwTipoUNO.FechaCierre, dbo.ObrasActualesSQL.SOL, dbo.ObrasActualesSQL.SOF, 
                         dbo.ObrasActualesSQL.CDCLI

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[38] 4[24] 2[17] 3) )"
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
         Begin Table = "vwTipoUNO"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 166
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ObrasActualesSQL"
            Begin Extent = 
               Top = 0
               Left = 358
               Bottom = 272
               Right = 625
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
      Begin ColumnWidths = 19
         Width = 284
         Width = 1050
         Width = 1020
         Width = 1410
         Width = 1620
         Width = 1335
         Width = 1500
         Width = 1335
         Width = 1725
         Width = 1065
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
      Begin ColumnWidths = 12
         Column = 6600
         Alias = 1725
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwTIPOUNO_ProduccionElecnor_Detallado';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwTIPOUNO_ProduccionElecnor_Detallado';

