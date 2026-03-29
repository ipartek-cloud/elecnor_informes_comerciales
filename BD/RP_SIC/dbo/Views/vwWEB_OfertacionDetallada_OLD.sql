
CREATE VIEW [dbo].[vwWEB_OfertacionDetallada_OLD]
AS
SELECT        TOP (100) PERCENT dbo.WEB_OfertacionDetalladaUsuarioCentro.Usuario, dbo.WEB_OfertacionDetalladaUsuarioCentro.CodCentro, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.CodOferta, dbo.WEB_OfertacionDetalladaUsuarioCentro.FAlta, dbo.WEB_OfertacionDetalladaUsuarioCentro.ImporteAlta, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.FPresentacion, dbo.WEB_OfertacionDetalladaUsuarioCentro.ImportePresentacion, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.FAdjudicacion, dbo.WEB_OfertacionDetalladaUsuarioCentro.DescripcionOferta, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.Regularizacion, dbo.WEB_OfertacionDetalladaUsuarioCentro.CausaRegularizacion, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.ImporteContratado, dbo.WEB_OfertacionDetalladaUsuarioCentro.Localidad, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.CodCliente, dbo.WEB_OfertacionDetalladaUsuarioCentro.CodAct1, 
                         dbo.WEB_OfertacionDetalladaUsuarioCentro.CodAct2, dbo.WEB_OfertacionDetalladaUsuarioCentro.CodProv, dbo.Provincias.NMPRO AS NombreProvincia, 
                         dbo.Provincias.Pais, dbo.WEB_OfertacionDetalladaUsuarioCentro.Adjudicada, dbo.WEB_OfertacionDetalladaUsuarioCentro.CodResponsable, 
                         ISNULL(dbo.ClientesSQL.NombreCliente, dbo.Ofertas.DESPRO) AS NombreCliente
FROM            dbo.WEB_OfertacionDetalladaUsuarioCentro LEFT OUTER JOIN
                         dbo.Ofertas ON dbo.WEB_OfertacionDetalladaUsuarioCentro.CodOferta = dbo.Ofertas.CDOFT LEFT OUTER JOIN
                         dbo.Provincias ON dbo.WEB_OfertacionDetalladaUsuarioCentro.CodProv = dbo.Provincias.CDPRO LEFT OUTER JOIN
                         dbo.ClientesSQL ON dbo.WEB_OfertacionDetalladaUsuarioCentro.CodCliente = dbo.ClientesSQL.CodCliente

