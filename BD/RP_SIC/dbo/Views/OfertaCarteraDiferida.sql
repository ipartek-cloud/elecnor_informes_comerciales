

CREATE VIEW [dbo].[OfertaCarteraDiferida]
AS
SELECT JMAYNB CodOferta, JMB8ST TipoContratoGestion -- N=Normal (para Contratos Marco) / E=Especial (para otros tipos de contrato)
FROM         SIC.S44DD901.ICOMERF.ICPOFC AS OfertaCarteraDiferida
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[OfertaCarteraDiferida] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[OfertaCarteraDiferida] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[OfertaCarteraDiferida] TO [partnertec]
    AS [dbo];

