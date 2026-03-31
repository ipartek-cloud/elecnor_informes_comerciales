
CREATE VIEW [dbo].[Enlaces]
AS
SELECT *
FROM OPENQUERY(SIC, '
SELECT     *
FROM         S44DD901.FICOSCO.CO005BP AS Enlaces')
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Enlaces] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Enlaces] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Enlaces] TO [partnertec]
    AS [dbo];

