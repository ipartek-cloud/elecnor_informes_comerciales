CREATE TABLE [dbo].[Zonas_SubZonasSQL] (
    [CodZona]     VARCHAR (3)   NOT NULL,
    [CodSubZona]  VARCHAR (3)   NOT NULL,
    [NombreZona]  VARCHAR (100) NULL,
    [Responsable] VARCHAR (100) NULL,
    CONSTRAINT [PK_Zonas_SubZonasSQL] PRIMARY KEY CLUSTERED ([CodZona] ASC, [CodSubZona] ASC)
);

