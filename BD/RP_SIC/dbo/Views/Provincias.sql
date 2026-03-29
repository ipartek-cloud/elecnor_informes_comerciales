




CREATE VIEW [dbo].[Provincias]
AS


SELECT CAutonoma.CDAUT, CAutonoma.NMAUT, Provincias.CDPRO, Provincias.NMPRO, dbo.fnPais([CAutonoma].cdaut) AS Pais
FROM SIC.S44DD901.ICOMERF.IC05AP as Provincias INNER JOIN SIC.S44DD901.ICOMERF.IC11AP as CAutonoma ON Provincias.CDAUT = CAutonoma.CDAUT
GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Provincias] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Provincias] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Provincias] TO [UsuDataLakeCIC]
    AS [dbo];

