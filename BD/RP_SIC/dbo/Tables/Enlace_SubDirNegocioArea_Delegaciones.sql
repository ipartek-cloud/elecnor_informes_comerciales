CREATE TABLE [dbo].[Enlace_SubDirNegocioArea_Delegaciones] (
    [CodDirNegocio]        VARCHAR (3) NOT NULL,
    [CodSubDirNegocioArea] VARCHAR (3) NULL,
    [CodDelegacion]        VARCHAR (3) NULL,
    CONSTRAINT [FK_Enlace_SubDirNegocioArea_Delegaciones_SubDirNegocioArea] FOREIGN KEY ([CodDirNegocio], [CodSubDirNegocioArea]) REFERENCES [dbo].[SubDirNegocioArea] ([CodDirNegocio], [CodSubDirNegocioArea])
);

