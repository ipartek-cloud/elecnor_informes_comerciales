CREATE TABLE [dbo].[ProyectosSingularesSQL] (
    [NomProyecto]     VARCHAR (255)  NOT NULL,
    [CodOferta]       VARCHAR (10)   NULL,
    [ClienteAgrupado] NVARCHAR (255) NULL,
    [Num]             NUMERIC (18)   NULL,
    [Ficha]           VARCHAR (255)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_NomProyecto]
    ON [dbo].[ProyectosSingularesSQL]([NomProyecto] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ClienteAgrupado]
    ON [dbo].[ProyectosSingularesSQL]([ClienteAgrupado] ASC);

