CREATE TABLE [dbo].[Sumarigrama2023] (
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
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[Sumarigrama2023] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Sumarigrama2023] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Sumarigrama2023] TO [UsuDataLakeCIC]
    AS [dbo];

