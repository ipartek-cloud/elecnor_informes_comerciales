CREATE TABLE [dbo].[SubDirNegocioArea] (
    [CodDirNegocio]           VARCHAR (3)   NOT NULL,
    [CodSubDirNegocioArea]    VARCHAR (3)   NOT NULL,
    [NombreSubDirNegocioArea] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_SubDirNegocioArea] PRIMARY KEY CLUSTERED ([CodDirNegocio] ASC, [CodSubDirNegocioArea] ASC)
);

