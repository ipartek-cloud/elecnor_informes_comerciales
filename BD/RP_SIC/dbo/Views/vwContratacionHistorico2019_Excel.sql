CREATE VIEW dbo.vwContratacionHistorico2019_Excel
AS
SELECT     HCGS.Año, HCGS.Mes, HCGS.Mercado, ISNULL(P.NOMBREPAIS, 'España') AS Pais, RIGHT('000' + CAST(S.CodDDirNegocio AS varchar(3)), 3) AS [DN-], S.NombreDirNegocio AS Descrip_DN, RIGHT('000' + CAST(HCGS.CodCentro AS varchar(3)), 3) AS CodCentro, 
                  HCGS.CodOferta AS CodOfer, O.CodCliente, O.NombreCliente, O.DescripcionOferta, HCGS.Importe, '' AS Reg, O.Tipo AS [Tipo Oferta], O.Actividad, '' AS CodObra, O.PaisProv AS [Pro/Pais], CASE WHEN CM.CodOferta IS NULL THEN 'N' ELSE 'S' END AS CM
FROM        dbo.HistoricoContratacionGrupoSQL AS HCGS LEFT OUTER JOIN
                      (SELECT     PROOF AS PaisProv, CDCEN AS CodCentro, CDOFT AS CodOferta, CDCLI AS CodCliente, DESPRO AS NombreCliente, DCOF AS DescripcionOferta, WS10 AS Tipo, CAST(CDAC1 + CDAC2 AS int) AS Actividad
                       FROM        dbo.Ofertas
                       UNION
                       SELECT     MIN(CodProv) AS PaisProv, MIN(CodCentro) AS CodCentro, CodOferta, MIN(CodCliente) AS CodCliente, '' AS NombreCliente, MIN(DescripcionOferta) AS DescripcionOferta, '' AS Tipo, MIN(CAST(CodAct1 + CodAct2 AS int)) AS Actividad
                       FROM        dbo.OfertasSQL
                       WHERE     (Reparto = 0)
                       GROUP BY CodOferta) AS O ON HCGS.CodOferta = O.CodOferta LEFT OUTER JOIN
                      (SELECT     CodCentro, CodDDirNegocio, NombreDirNegocio
                       FROM        dbo.Sumarigrama2019) AS S ON HCGS.CodCentro = S.CodCentro LEFT OUTER JOIN
                  dbo.GCIPaises AS P ON O.PaisProv = P.IDPAIS LEFT OUTER JOIN
                      (SELECT DISTINCT CDOC2016.CodOferta, CDCS.Tipo
                       FROM        dbo.Cart_DiferidaOfertasContratos_2016SQL AS CDOC2016 INNER JOIN
                                         dbo.Cart_DiferidaContratosSQL AS CDCS ON CDOC2016.ID = CDCS.ID
                       WHERE     (CDCS.Tipo = 'T')) AS CM ON HCGS.CodOferta = CM.CodOferta
WHERE     (HCGS.Año = 2019)

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
         Begin Table = "HCGS"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 292
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "O"
            Begin Extent = 
               Top = 7
               Left = 340
               Bottom = 170
               Right = 584
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "S"
            Begin Extent = 
               Top = 7
               Left = 632
               Bottom = 148
               Right = 876
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 7
               Left = 924
               Bottom = 148
               Right = 1168
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CM"
            Begin Extent = 
               Top = 7
               Left = 1216
               Bottom = 126
               Right = 1460
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwContratacionHistorico2019_Excel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwContratacionHistorico2019_Excel';

