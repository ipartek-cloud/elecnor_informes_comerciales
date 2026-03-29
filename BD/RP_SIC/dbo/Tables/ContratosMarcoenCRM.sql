CREATE TABLE [dbo].[ContratosMarcoenCRM] (
    [CodOferta]      VARCHAR (10)  NULL,
    [Estado]         VARCHAR (255) NULL,
    [NombreContrato] VARCHAR (255) NULL,
    [Cliente]        VARCHAR (255) NULL
);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT VIEW CHANGE TRACKING
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT TAKE OWNERSHIP
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT CONTROL
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[ContratosMarcoenCRM] TO [partnertec]
    AS [dbo];

