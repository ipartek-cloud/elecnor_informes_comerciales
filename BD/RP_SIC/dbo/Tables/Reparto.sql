CREATE TABLE [dbo].[Reparto] (
    [CodCentro]         VARCHAR (3) NULL,
    [CodCentro_Destino] VARCHAR (3) NOT NULL,
    [Año]               INT         NOT NULL,
    [Reparto]           FLOAT (53)  CONSTRAINT [DF_Reparto_Reparto] DEFAULT ((0)) NOT NULL
);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Reparto] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Reparto] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Reparto] TO [partnertec]
    AS [dbo];

