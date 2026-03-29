CREATE TABLE [dbo].[Enlace_Provincias_Zonas_Presencia] (
    [CodProv]   VARCHAR (2)  NOT NULL,
    [CodZona]   VARCHAR (3)  NULL,
    [Presencia] VARCHAR (50) NULL,
    CONSTRAINT [PK_CodProv] PRIMARY KEY CLUSTERED ([CodProv] ASC),
    CONSTRAINT [FK_Enlace_Provincias_Zonas_Presencia_Presencia] FOREIGN KEY ([Presencia]) REFERENCES [dbo].[Presencia] ([Presencia]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Enlace_Provincias_Zonas_Presencia_Zonas] FOREIGN KEY ([CodZona]) REFERENCES [dbo].[Zonas] ([CodZona]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_CodZona]
    ON [dbo].[Enlace_Provincias_Zonas_Presencia]([CodZona] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Presencia]
    ON [dbo].[Enlace_Provincias_Zonas_Presencia]([Presencia] ASC);

