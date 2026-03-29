

CREATE VIEW [dbo].[vwWEB_CarteraDetalladaUsuarioCentro]
AS
SELECT CDUC.id, CDUC.Usuario, CDUC.Tipo,
		CDUC.TipoNombre, CDUC.CodOferta, 
		CDUC.ContratoMarco, CDUC.DescripcionOferta, 
		CDUC.FAdjudicacion, 
		--CASE ISNULL(dbo.OfertasSQL.idOfertasSQL, 0) 
		--	WHEN 0 THEN CDUC.ImporteContratado ELSE CDUCSQL.ImporteContratado_OfertasSQL
		--END AS ImporteContratado, 
		CASE WHEN ISNULL(CDUCSQL.CodOferta, '') = ''
			THEN CDUC.ImporteContratado 
			ELSE CDUCSQL.ImporteContratado_OfertasSQL
		END AS ImporteContratado, 
		CDUC.NombreObra, ISNULL(CDUC.ImporteProduccion, 0) ImporteProduccion, CDUC.ImporteFactura, CDUC.ImporteFot, 
		ISNULL(CDUC.Est, '') Est, CDUCNumObras.NumObras, 
		CDUC.FApertura, CDUC.FCierre, 
		CDUC.ImporteCarteraAgrupacion, 
		CASE Tipo 
			WHEN 'E' THEN 1 
			WHEN 'F' THEN 2 
			WHEN 'U' THEN 3 
			WHEN 'S' THEN 4 
			ELSE 0 END AS Orden, 
		--CASE ISNULL(dbo.OfertasSQL.idOfertasSQL, 0) 
		--	WHEN 0 
		--	THEN 0 
		--	ELSE 1 
		--END AS FromOfertasSQL, 
		CASE WHEN ISNULL(CDUCSQL.CodOferta, '') = '' 
			THEN 0 
			ELSE 1 
		END AS FromOfertasSQL, 
		CDUC.CodCliente, 
		ISNULL(CDUC.NombreCliente, '') AS NombreCliente
		, CASE WHEN ISNULL(CDUCSQL.CodOferta, '') = '' 
			THEN '' 
			ELSE CDUCSQL.CodCentro 
		END CodCentro
FROM dbo.WEB_CarteraDetalladaUsuarioCentro CDUC 
		INNER JOIN dbo.vwWEB_CarteraDetalladaUsuarioCentro_NumObras CDUCNumObras ON 
							CDUC.CodOferta = CDUCNumObras.CodOferta AND 
							CDUC.Usuario = CDUCNumObras.Usuario 
		LEFT OUTER JOIN dbo.vwWEB_CarteraDetalladaUsuarioCentro_OfertasSQL CDUCSQL ON 
							CDUC.Usuario = CDUCSQL.Usuario AND 
							CDUC.CodOferta = CDUCSQL.CodOferta 
		--LEFT OUTER JOIN dbo.OfertasSQL ON 
		--					CDUC.ImporteContratado = dbo.OfertasSQL.ImporteContratado AND 
		--					CDUC.CodOferta = dbo.OfertasSQL.CodOferta




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1530
         Table = 3105
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDetalladaUsuarioCentro';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDetalladaUsuarioCentro';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[15] 2[20] 3) )"
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
         Begin Table = "WEB_CarteraDetalladaUsuarioCentro"
            Begin Extent = 
               Top = 26
               Left = 610
               Bottom = 414
               Right = 955
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "vwWEB_CarteraDetalladaUsuarioCentro_NumObras"
            Begin Extent = 
               Top = 13
               Left = 40
               Bottom = 132
               Right = 415
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwWEB_CarteraDetalladaUsuarioCentro_OfertasSQL"
            Begin Extent = 
               Top = 152
               Left = 41
               Bottom = 270
               Right = 413
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OfertasSQL"
            Begin Extent = 
               Top = 6
               Left = 1151
               Bottom = 372
               Right = 1360
            End
            DisplayFlags = 280
            TopColumn = 3
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
         Width = 2685
         Width = 2505
         Width = 3135
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2325
         Width = 1500
         Width = 1500
         ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwWEB_CarteraDetalladaUsuarioCentro';

