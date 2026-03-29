CREATE TABLE [dbo].[ObjetivosZonasSQL] (
    [idObjetivosZonas] INT          IDENTITY (1, 1) NOT NULL,
    [Año]              INT          NOT NULL,
    [CodZona]          VARCHAR (3)  NOT NULL,
    [Presencia]        VARCHAR (50) NOT NULL,
    [Importe]          NUMERIC (9)  CONSTRAINT [DF_ObjetivosZonasSQL_Importe] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ObjetivosZonasSQL] PRIMARY KEY CLUSTERED ([idObjetivosZonas] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ObjetivosZonasSQL]
    ON [dbo].[ObjetivosZonasSQL]([Año] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ObjetivosZonasSQL_1]
    ON [dbo].[ObjetivosZonasSQL]([CodZona] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ObjetivosZonasSQL_2]
    ON [dbo].[ObjetivosZonasSQL]([Presencia] ASC);

