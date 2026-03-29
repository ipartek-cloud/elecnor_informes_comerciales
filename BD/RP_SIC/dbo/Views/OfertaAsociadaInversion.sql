

CREATE VIEW [dbo].[OfertaAsociadaInversion]
AS
	SELECT *
	FROM OPENQUERY(SIC, 'SELECT * FROM  S44DD901.ICOMERF.ICPOAI') AS OfertaAsociadaInversion
