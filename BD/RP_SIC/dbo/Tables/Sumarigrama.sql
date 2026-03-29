CREATE TABLE [dbo].[Sumarigrama] (
    [Año]                     SMALLINT       NOT NULL,
    [CodDirGeneral]           VARCHAR (3)    NULL,
    [NombreDirGeneral]        NVARCHAR (100) NOT NULL,
    [CodSubDirGeneral]        VARCHAR (3)    NULL,
    [NombreSubDirGeneral]     NVARCHAR (100) NOT NULL,
    [CodDDirNegocio]          VARCHAR (3)    NULL,
    [NombreDirNegocio]        NVARCHAR (30)  NOT NULL,
    [CodSubDirNegocioArea]    VARCHAR (3)    NULL,
    [NombreSubDirNegocioArea] NVARCHAR (100) NOT NULL,
    [CodDelegacion]           VARCHAR (3)    NULL,
    [NombreDelegacion]        NVARCHAR (30)  NOT NULL,
    [CodCentro]               VARCHAR (3)    NULL,
    [NombreCentro]            NVARCHAR (30)  NOT NULL,
    [OrdenSubDirGeneral]      INT            NOT NULL
);




GO
CREATE CLUSTERED INDEX [CX_Sumarigrama_Contexto]
    ON [dbo].[Sumarigrama]([Año] ASC, [CodCentro] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrdenSubDirGeneral]
    ON [dbo].[Sumarigrama]([OrdenSubDirGeneral] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Sumarigrama_CodCentro]
    ON [dbo].[Sumarigrama]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Sumarigrama_Universal_Reporting]
    ON [dbo].[Sumarigrama]([CodCentro] ASC, [CodSubDirGeneral] ASC, [Año] ASC)
    INCLUDE([CodDDirNegocio], [NombreDirNegocio], [NombreCentro], [OrdenSubDirGeneral], [NombreSubDirGeneral], [CodDelegacion], [NombreDelegacion]) WITH (FILLFACTOR = 90);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Sumarigrama] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Sumarigrama] TO [USRGPROD]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Sumarigrama] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Sumarigrama] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Sumarigrama] TO [USRGPROD]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Sumarigrama] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Sumarigrama] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Sumarigrama] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Sumarigrama] TO [partnertec]
    AS [dbo];

