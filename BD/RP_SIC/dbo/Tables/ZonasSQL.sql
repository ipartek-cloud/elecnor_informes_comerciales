CREATE TABLE [dbo].[ZonasSQL] (
    [CodZona]     VARCHAR (3)   NOT NULL,
    [NombreZona]  VARCHAR (100) NOT NULL,
    [Responsable] VARCHAR (100) NULL,
    CONSTRAINT [PK_ZonasSQL] PRIMARY KEY CLUSTERED ([CodZona] ASC)
);

