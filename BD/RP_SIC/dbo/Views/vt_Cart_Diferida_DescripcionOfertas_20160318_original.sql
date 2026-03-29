
CREATE VIEW [dbo].[vt_Cart_Diferida_DescripcionOfertas_20160318_original]
AS
SELECT        dbo.[@aOfertas].CODOFER, dbo.[@aOfertas].DESOFER, dbo.[@aOfertas].CODCLIENTE, dbo.[@aOfertas].NOMCLIENTE
FROM            dbo.Cart_DiferidaOfertasContratosSQL INNER JOIN
                         dbo.[@aOfertas] ON dbo.Cart_DiferidaOfertasContratosSQL.CodOferta = dbo.[@aOfertas].CODOFER

