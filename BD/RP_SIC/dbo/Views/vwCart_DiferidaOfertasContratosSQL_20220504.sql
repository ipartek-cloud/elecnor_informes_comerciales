
CREATE VIEW [dbo].[vwCart_DiferidaOfertasContratosSQL_20220504]
AS
SELECT        dbo.Cart_DiferidaContratosSQL.ID, dbo.Cart_DiferidaContratosSQL.Contrato, dbo.Cart_DiferidaContratosSQL.Cliente, dbo.Cart_DiferidaContratosSQL.FInicio, 
                         dbo.Cart_DiferidaContratosSQL.FFinal, dbo.Cart_DiferidaContratosSQL.FFinalEfectiva, dbo.Cart_DiferidaContratosSQL.Tipo, dbo.Cart_DiferidaContratosSQL.Mercado, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Año, dbo.Cart_DiferidaOfertasContratos_2016SQL.Centro, dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta, 
                         dbo.NomOfertasSQL.DesOferta, dbo.Cart_DiferidaOfertasContratos_2016SQL.CartInicio, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoAnual, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.NTrimestres, dbo.Cart_DiferidaOfertasContratos_2016SQL.MontoTrimestre, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto1, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto2, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto3, dbo.Cart_DiferidaOfertasContratos_2016SQL.Previsto4, 
                         dbo.Cart_DiferidaOfertasContratos_2016SQL.Meses
FROM            dbo.Cart_DiferidaContratosSQL INNER JOIN
                         dbo.Cart_DiferidaOfertasContratos_2016SQL ON dbo.Cart_DiferidaContratosSQL.ID = dbo.Cart_DiferidaOfertasContratos_2016SQL.ID INNER JOIN
                         dbo.NomOfertasSQL ON dbo.Cart_DiferidaOfertasContratos_2016SQL.CodOferta = dbo.NomOfertasSQL.CodOferta
WHERE        (dbo.Cart_DiferidaContratosSQL.Tipo = 'T') AND (dbo.Cart_DiferidaContratosSQL.Vigente = 1) OR
                         (dbo.Cart_DiferidaContratosSQL.Tipo = 'A') AND (dbo.Cart_DiferidaContratosSQL.Vigente = 1)

