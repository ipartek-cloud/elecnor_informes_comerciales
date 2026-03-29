CREATE TABLE [dbo].[Enlace_SubDirGeneral_DirNegocio] (
    [CodDirGeneral]    VARCHAR (3) NULL,
    [CodSubDirGeneral] VARCHAR (3) NULL,
    [CodDirNegocio]    VARCHAR (3) NOT NULL,
    CONSTRAINT [FK_Enlace_SubDirGeneral_DirNegocio_SubDirGeneral] FOREIGN KEY ([CodDirGeneral], [CodSubDirGeneral]) REFERENCES [dbo].[SubDirGeneral] ([CodDirGeneral], [CodSubDirGeneral])
);

