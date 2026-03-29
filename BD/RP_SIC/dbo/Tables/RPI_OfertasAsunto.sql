CREATE TABLE [dbo].[RPI_OfertasAsunto] (
    [idOfertaAsunto] INT          IDENTITY (1, 1) NOT NULL,
    [idAsunto]       INT          NOT NULL,
    [CDOFT]          NUMERIC (10) NOT NULL,
    CONSTRAINT [PK_idOfertaAsunto] PRIMARY KEY CLUSTERED ([idOfertaAsunto] ASC),
    CONSTRAINT [FK_RPI_OfertasAsunto_RPI_Asuntos] FOREIGN KEY ([idAsunto]) REFERENCES [dbo].[RPI_Asuntos] ([idAsunto]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_idAsunto]
    ON [dbo].[RPI_OfertasAsunto]([idAsunto] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CDOFT]
    ON [dbo].[RPI_OfertasAsunto]([CDOFT] ASC);

