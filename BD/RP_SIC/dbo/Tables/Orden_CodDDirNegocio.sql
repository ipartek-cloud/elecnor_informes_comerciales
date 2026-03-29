CREATE TABLE [dbo].[Orden_CodDDirNegocio] (
    [CodDDirNegocio]       NVARCHAR (255) NOT NULL,
    [NombreDDirNegocio]    NVARCHAR (255) NULL,
    [Orden_CodDDirNegocio] INT            NULL,
    CONSTRAINT [PK_Orden_CodDDirNegocio] PRIMARY KEY CLUSTERED ([CodDDirNegocio] ASC)
);

