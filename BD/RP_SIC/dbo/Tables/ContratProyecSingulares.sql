CREATE TABLE [dbo].[ContratProyecSingulares] (
    [idContratProyecSingulares] INT           IDENTITY (1, 1) NOT NULL,
    [Proyecto]                  VARCHAR (255) NOT NULL,
    [Año]                       INT           NOT NULL,
    [CodOferta]                 VARCHAR (10)  NULL,
    [DescripContrat]            VARCHAR (50)  NULL,
    [Importe]                   FLOAT (53)    CONSTRAINT [DF_ContratProyecSingulares_Importe] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ContratProyecSingulares] PRIMARY KEY CLUSTERED ([idContratProyecSingulares] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Proyecto]
    ON [dbo].[ContratProyecSingulares]([Proyecto] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Año]
    ON [dbo].[ContratProyecSingulares]([Año] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodOferta]
    ON [dbo].[ContratProyecSingulares]([CodOferta] ASC);

