CREATE TABLE [dbo].[CarterasContratacionSQL] (
    [AnioInforme]          INT             NOT NULL,
    [MesInforme]           INT             NOT NULL,
    [Anio]                 INT             NOT NULL,
    [Mes]                  INT             NOT NULL,
    [DN]                   CHAR (5)        NOT NULL,
    [CentroChar]           CHAR (5)        NOT NULL,
    [Obra]                 CHAR (20)       NOT NULL,
    [ProvPais]             CHAR (20)       NOT NULL,
    [Pais]                 NVARCHAR (300)  NOT NULL,
    [TipoOferta]           CHAR (2)        NOT NULL,
    [AuxiliarVehiculo]     CHAR (20)       NOT NULL,
    [NombredeVehiculo]     NVARCHAR (300)  NOT NULL,
    [MonedaLocal]          CHAR (20)       NOT NULL,
    [ImporteMonedaLocal]   NUMERIC (20, 5) NOT NULL,
    [Cambio]               NUMERIC (21, 6) NOT NULL,
    [ImporteEUR]           NUMERIC (20, 5) NOT NULL,
    [CodOferta]            VARCHAR (10)    NULL,
    [DesOferta]            NVARCHAR (300)  NOT NULL,
    [CodCliente]           CHAR (20)       NOT NULL,
    [NomCliente]           NVARCHAR (300)  NOT NULL,
    [OfertaRegularicacion] CHAR (2)        NOT NULL,
    [NumeroRegularizacion] INT             NOT NULL,
    [Causa]                NVARCHAR (300)  NOT NULL,
    [Localidad]            NVARCHAR (300)  NOT NULL,
    [Fecha]                DATE            NOT NULL,
    [Actividad]            CHAR (20)       NOT NULL,
    [CM]                   INT             NOT NULL,
    [CPA]                  INT             NOT NULL,
    [Centro]               VARCHAR (3)     NULL,
    [RowId]                INT             IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_CarterasContratacionSQL] PRIMARY KEY CLUSTERED ([RowId] ASC)
);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT VIEW CHANGE TRACKING
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT TAKE OWNERSHIP
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT CONTROL
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[CarterasContratacionSQL] TO [partnertec]
    AS [dbo];

