CREATE TABLE [dbo].[SumarigramaHistorico] (
    [Año]                     SMALLINT       NOT NULL,
    [CodDirGeneral]           NVARCHAR (50)  NOT NULL,
    [NombreDirGeneral]        NVARCHAR (100) NOT NULL,
    [CodSubDirGeneral]        NVARCHAR (50)  NOT NULL,
    [NombreSubDirGeneral]     NVARCHAR (100) NOT NULL,
    [CodDDirNegocio]          NVARCHAR (50)  NOT NULL,
    [NombreDirNegocio]        NVARCHAR (30)  NOT NULL,
    [CodSubDirNegocioArea]    NVARCHAR (50)  NOT NULL,
    [NombreSubDirNegocioArea] NVARCHAR (100) NOT NULL,
    [CodDelegacion]           NVARCHAR (50)  NOT NULL,
    [NombreDelegacion]        NVARCHAR (30)  NOT NULL,
    [CodCentro]               NVARCHAR (50)  NOT NULL,
    [NombreCentro]            NVARCHAR (30)  NOT NULL,
    [OrdenSubDirGeneral]      INT            NOT NULL,
    CONSTRAINT [PK_SumarigramaHistorico] PRIMARY KEY CLUSTERED ([Año] ASC, [CodDirGeneral] ASC, [CodSubDirGeneral] ASC, [CodDDirNegocio] ASC, [CodSubDirNegocioArea] ASC, [CodDelegacion] ASC, [CodCentro] ASC)
);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SumarigramaHistorico] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SumarigramaHistorico] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[SumarigramaHistorico] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[SumarigramaHistorico] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[SumarigramaHistorico] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[SumarigramaHistorico] TO [partnertec]
    AS [dbo];

