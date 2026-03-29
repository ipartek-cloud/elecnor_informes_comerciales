

CREATE VIEW [dbo].[Provincias_20160222 original]
AS


SELECT CAutonoma.CDAUT, CAutonoma.NMAUT, Provincias.CDPRO, Provincias.NMPRO, dbo.fnPais([CAutonoma].cdaut) AS Pais
FROM SIC.S44DD901.ICOMERF.IC05AP as Provincias INNER JOIN SIC.S44DD901.ICOMERF.IC11AP as CAutonoma ON Provincias.CDAUT = CAutonoma.CDAUT



