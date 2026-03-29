
CREATE VIEW [dbo].[vwCart_DiferidaOfertasContratosSQL_20160318_original]
AS
SELECT        dbo.Cart_DiferidaOfertasContratosSQL.Año, dbo.Cart_DiferidaOfertasContratosSQL.CodOferta
FROM            dbo.Cart_DiferidaContratosSQL INNER JOIN
                         dbo.Cart_DiferidaOfertasContratosSQL ON dbo.Cart_DiferidaContratosSQL.Contrato = dbo.Cart_DiferidaOfertasContratosSQL.Contrato AND 
                         dbo.Cart_DiferidaContratosSQL.Cliente = dbo.Cart_DiferidaOfertasContratosSQL.Cliente
WHERE        (dbo.Cart_DiferidaContratosSQL.Tipo = 'T')

