CREATE VIEW dbo.vwWEB_CarteraDiferida_OBRA_Agrup_RPT
AS
SELECT        dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Usuario, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Año, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Mes, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Gerencia, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Total_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Lineal_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Contrat_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.CarteraPendiente_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Produccion_A_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.MargenProduccion_A_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.PorcentajeProduccion_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.A_Año_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.A_Año1_GER, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Cliente, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Total_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Lineal_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Contrat_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.CarteraPendiente_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Produccion_A_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.MargenProduccion_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.PorcentajeProduccion_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.A_Año_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.A_Año1_CLI, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Contrato, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.FInicio, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.FFinal, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Prorroga, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Total_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Lineal_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Contrat_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.CarteraPendiente_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Produccion_A_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.MargenProduccion_A_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.PorcentajeProduccion_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.A_Año_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.A_Año1_CON, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodDDirNegocio, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.NombreDirNegocio, dbo.vwWEB_CarteraDiferida_DN_RPT.Total_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.Lineal_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.Contrat_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.CarteraPendiente_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.Produccion_A_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.MargenProduccion_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.PorcentajeProduccion_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.A_Año_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.A_Año1_DN, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodDelegacion, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.NombreDelegacion, dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Total_DEL, 
                         dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Lineal_DEL, dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Contrat_DEL, 
                         dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.CarteraPendiente_DEL, dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Produccion_A_DEL, 
                         dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.MargenProduccion_A_DEL, dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.PorcentajeProduccion_DEL, 
                         dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.A_Año_DEL, dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.A_Año1_DEL, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodCentro, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.NombreCentro, 
                         dbo.vwWEB_CarteraDiferida_CT_RPT.Total_CT, dbo.vwWEB_CarteraDiferida_CT_RPT.Lineal_CT, dbo.vwWEB_CarteraDiferida_CT_RPT.Contrat_CT, 
                         dbo.vwWEB_CarteraDiferida_CT_RPT.CarteraPendiente_CT, dbo.vwWEB_CarteraDiferida_CT_RPT.Produccion_A_CT, 
                         dbo.vwWEB_CarteraDiferida_CT_RPT.MargenProduccion_A_CT, dbo.vwWEB_CarteraDiferida_CT_RPT.PorcentajeProduccion_CT, 
                         dbo.vwWEB_CarteraDiferida_CT_RPT.A_Año_CT, dbo.vwWEB_CarteraDiferida_CT_RPT.A_Año1_CT, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Oferta, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.NTrimestre, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.MontoTrimestre, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Total, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Total / 12 * dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Mes AS Lineal, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Contrat, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CarteraPendiente, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Produccion_A, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.MargenProduccion_A, 
                         CASE Produccion_A WHEN 0 THEN 0 ELSE 100 * MargenProduccion_A / Produccion_A END AS PorcentajeProduccion, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.A_Año, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.A_Año1, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.LiteralSIN, 
                         dbo.vwWEB_Ofertas_Obras.Obra, dbo.vwWEB_Ofertas_Obras.NombreObra, dbo.vwWEB_Ofertas_Obras.FechaApertura_Obra, 
                         dbo.vwWEB_Ofertas_Obras.FechaCierre_Obra, ISNULL(dbo.vwWEB_Ofertas_Obras.Produccion_A_Obra, 0) AS Produccion_A_Obra, 
                         ISNULL(dbo.vwWEB_Ofertas_Obras.MargenProduccion_A_Obra, 0) AS MargenProduccion_A_Obra, 
                         ISNULL(CASE Produccion_A_Obra WHEN 0 THEN 0 ELSE 100 * MargenProduccion_A_Obra / Produccion_A_Obra END, 0) AS PorcentajeProduccion_Obra, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Facturacion_Origen_A, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Facturacion_Anticipada_A, 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Produccion_Curso_A, dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Facturacion_A, 
                         ISNULL(dbo.vwWEB_Ofertas_Obras.Facturacion_A, 0) AS Facturacion, ISNULL(dbo.vwWEB_Ofertas_Obras.Facturacion_Origen_A, 0) AS Facturacion_Origen, 
                         ISNULL(dbo.vwWEB_Ofertas_Obras.Facturacion_Anticipada_A, 0) AS Facturacion_Anticipada, ISNULL(dbo.vwWEB_Ofertas_Obras.Produccion_Curso_A, 0) 
                         AS Produccion_Curso, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Facturacion_Origen_A_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Facturacion_Anticipada_A_GER, dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Produccion_Curso_A_GER, 
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Facturacion_A_GER, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Facturacion_Origen_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Facturacion_Anticipada_A_CLI, dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Produccion_Curso_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Facturacion_A_CLI, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Facturacion_Origen_A_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Facturacion_Anticipada_A_CON, dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Produccion_Curso_A_CON, 
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Facturacion_A_CON, dbo.vwWEB_CarteraDiferida_DN_RPT.Facturacion_Origen_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.Facturacion_Anticipada_A_DN, dbo.vwWEB_CarteraDiferida_DN_RPT.Produccion_Curso_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_RPT.Facturacion_A_DN, dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Facturacion_Origen_A_DEL, 
                         dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Facturacion_Anticipada_A_DEL, dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Produccion_Curso_A_DEL, 
                         dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Facturacion_A_DEL, dbo.vwWEB_CarteraDiferida_CT_RPT.Facturacion_Origen_A_CT, 
                         dbo.vwWEB_CarteraDiferida_CT_RPT.Facturacion_Anticipada_A_CT, dbo.vwWEB_CarteraDiferida_CT_RPT.Produccion_Curso_A_CT, 
                         dbo.vwWEB_CarteraDiferida_CT_RPT.Facturacion_A_CT
FROM            dbo.vwWEB_CarteraDiferida_OFERTA_Agrup INNER JOIN
                         dbo.vwWEB_CarteraDiferida_GERENCIA_RPT ON dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_GERENCIA_RPT.Gerencia INNER JOIN
                         dbo.vwWEB_CarteraDiferida_CLIENTE_RPT ON dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Gerencia AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_CLIENTE_RPT.Cliente INNER JOIN
                         dbo.vwWEB_CarteraDiferida_CONTRATO_RPT ON 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Gerencia AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Cliente AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Contrato = dbo.vwWEB_CarteraDiferida_CONTRATO_RPT.Contrato INNER JOIN
                         dbo.vwWEB_CarteraDiferida_DN_RPT ON dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_DN_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_DN_RPT.Gerencia AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_DN_RPT.Cliente AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Contrato = dbo.vwWEB_CarteraDiferida_DN_RPT.Contrato AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodDDirNegocio = dbo.vwWEB_CarteraDiferida_DN_RPT.CodDDirNegocio INNER JOIN
                         dbo.vwWEB_CarteraDiferida_DELEGACION_RPT ON 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Gerencia AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Cliente AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Contrato = dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.Contrato AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodDDirNegocio = dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.CodDDirNegocio AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodDelegacion = dbo.vwWEB_CarteraDiferida_DELEGACION_RPT.CodDelegacion INNER JOIN
                         dbo.vwWEB_CarteraDiferida_CT_RPT ON dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_CT_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Gerencia = dbo.vwWEB_CarteraDiferida_CT_RPT.Gerencia AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_CT_RPT.Cliente AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Contrato = dbo.vwWEB_CarteraDiferida_CT_RPT.Contrato AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodDDirNegocio = dbo.vwWEB_CarteraDiferida_CT_RPT.CodDDirNegocio AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodDelegacion = dbo.vwWEB_CarteraDiferida_CT_RPT.CodDelegacion AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodCentro = dbo.vwWEB_CarteraDiferida_CT_RPT.CodCentro LEFT OUTER JOIN
                         dbo.vwWEB_Ofertas_Obras ON dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Año = dbo.vwWEB_Ofertas_Obras.Año AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.Mes = dbo.vwWEB_Ofertas_Obras.Mes AND 
                         dbo.vwWEB_CarteraDiferida_OFERTA_Agrup.CodOferta = dbo.vwWEB_Ofertas_Obras.CodOferta

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
         Configuration = "(H (1[50] 4[25] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1[54] 3) )"
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
         Configuration = "(H (1[75] 4) )"
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
         Begin Table = "vwWEB_CarteraDiferida_OFERTA_Agrup"
            Begin Extent = 
               Top = 35
               Left = 29
               Bottom = 352
               Right = 368
            End
            DisplayFlags = 280
            TopColumn = 19
         End
         Begin Table = "vwWEB_CarteraDiferida_GERENCIA_RPT"
            Begin Extent = 
               Top = 0
               Left = 614
               Bottom = 61
               Right = 925
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwWEB_CarteraDiferida_CLIENTE_RPT"
            Begin Extent = 
               Top = 58
               Left = 616
               Bottom = 119
               Right = 923
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "vwWEB_CarteraDiferida_CONTRATO_RPT"
            Begin Extent = 
               Top = 111
               Left = 618
               Bottom = 172
               Right = 926
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "vwWEB_CarteraDiferida_DN_RPT"
            Begin Extent = 
               Top = 168
               Left = 622
               Bottom = 229
               Right = 921
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "vwWEB_CarteraDiferida_DELEGACION_RPT"
            Begin Extent = 
               Top = 227
               Left = 625
               Bottom = 288
               Right = 931
            End
            DisplayFlags = 280
            TopColumn = 16
         End
         Begin Table = "vwWEB_CarteraDiferida_CT_RPT"
       ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_OBRA_Agrup_RPT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'     Begin Extent = 
               Top = 292
               Left = 625
               Bottom = 353
               Right = 938
            End
            DisplayFlags = 280
            TopColumn = 14
         End
         Begin Table = "vwWEB_Ofertas_Obras"
            Begin Extent = 
               Top = 6
               Left = 1172
               Bottom = 309
               Right = 1409
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
      Begin ColumnWidths = 92
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
         Width = 3885
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 4230
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
         Column = 10245
         Alias = 3510
         Table = 5655
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_OBRA_Agrup_RPT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDiferida_OBRA_Agrup_RPT';

