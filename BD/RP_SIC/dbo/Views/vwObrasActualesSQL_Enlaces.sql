CREATE VIEW dbo.vwObrasActualesSQL_Enlaces
AS
SELECT        dbo.Enlaces.CDOFT, dbo.ObrasActualesSQL.idObras, dbo.ObrasActualesSQL.Año, dbo.ObrasActualesSQL.Mes, dbo.ObrasActualesSQL.CTR, 
                         dbo.ObrasActualesSQL.OBRA, dbo.ObrasActualesSQL.OBRAL, dbo.ObrasActualesSQL.DSOBR, dbo.ObrasActualesSQL.RSOBR, dbo.ObrasActualesSQL.CDACT, 
                         dbo.ObrasActualesSQL.FCONT, dbo.ObrasActualesSQL.CDCLI, dbo.ObrasActualesSQL.PPFAC, dbo.ObrasActualesSQL.PCOST, dbo.ObrasActualesSQL.SRET, 
                         dbo.ObrasActualesSQL.SANT, dbo.ObrasActualesSQL.SCOMP, dbo.ObrasActualesSQL.SMP, dbo.ObrasActualesSQL.SMF, dbo.ObrasActualesSQL.SML, 
                         dbo.ObrasActualesSQL.SMMO, dbo.ObrasActualesSQL.SMMA, dbo.ObrasActualesSQL.SME, dbo.ObrasActualesSQL.SMT, dbo.ObrasActualesSQL.SMS, 
                         dbo.ObrasActualesSQL.SMV, dbo.ObrasActualesSQL.SMI, dbo.ObrasActualesSQL.SMCL, dbo.ObrasActualesSQL.SMH, dbo.ObrasActualesSQL.SMPR, 
                         dbo.ObrasActualesSQL.SAP, dbo.ObrasActualesSQL.SAF, dbo.ObrasActualesSQL.SAL, dbo.ObrasActualesSQL.SAMO, dbo.ObrasActualesSQL.SAMA, 
                         dbo.ObrasActualesSQL.SAE, dbo.ObrasActualesSQL.SAT, dbo.ObrasActualesSQL.SAS, dbo.ObrasActualesSQL.SAV, dbo.ObrasActualesSQL.SAI, 
                         dbo.ObrasActualesSQL.SACL, dbo.ObrasActualesSQL.SAH, dbo.ObrasActualesSQL.SAPR, dbo.ObrasActualesSQL.SOP, dbo.ObrasActualesSQL.SOF, 
                         dbo.ObrasActualesSQL.SOL, dbo.ObrasActualesSQL.SOMO, dbo.ObrasActualesSQL.SOMA, dbo.ObrasActualesSQL.SOE, dbo.ObrasActualesSQL.SOT, 
                         dbo.ObrasActualesSQL.SOS, dbo.ObrasActualesSQL.SOV, dbo.ObrasActualesSQL.SOI, dbo.ObrasActualesSQL.SOCL, dbo.ObrasActualesSQL.SOH, 
                         dbo.ObrasActualesSQL.SOPR, dbo.ObrasActualesSQL.VPC, dbo.ObrasActualesSQL.CC, dbo.ObrasActualesSQL.STOBR, dbo.ObrasActualesSQL.CGC, 
                         dbo.ObrasActualesSQL.CDPRO
FROM            dbo.Enlaces INNER JOIN
                         dbo.ObrasActualesSQL ON dbo.Enlaces.CTRO = dbo.ObrasActualesSQL.CTR AND dbo.Enlaces.OBRA = dbo.ObrasActualesSQL.OBRA + dbo.ObrasActualesSQL.OBRAL

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[15] 3) )"
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
         Begin Table = "Enlaces"
            Begin Extent = 
               Top = 43
               Left = 440
               Bottom = 283
               Right = 649
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ObrasActualesSQL"
            Begin Extent = 
               Top = 29
               Left = 42
               Bottom = 264
               Right = 349
            End
            DisplayFlags = 280
            TopColumn = 25
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 66
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
        ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwObrasActualesSQL_Enlaces';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' Width = 1500
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
         Alias = 1485
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwObrasActualesSQL_Enlaces';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwObrasActualesSQL_Enlaces';

