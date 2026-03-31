

CREATE VIEW [dbo].[Clientes]
AS
	SELECT        *
	FROM    OPENQUERY(SIC,'
			SELECT * FROM S44DD901.FICOS.CGA06AP AS Clientes
			WHERE CIA = ''001'' AND CNAUX = ''C''
			')
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Clientes] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Clientes] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Clientes] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Clientes] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Clientes] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Clientes] TO [partnertec]
    AS [dbo];

