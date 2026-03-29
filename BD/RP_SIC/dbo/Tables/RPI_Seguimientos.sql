CREATE TABLE [dbo].[RPI_Seguimientos] (
    [idSeguimiento] INT            IDENTITY (1, 1) NOT NULL,
    [idAsunto]      INT            NOT NULL,
    [Fecha]         VARCHAR (10)   NOT NULL,
    [Descripcion]   VARCHAR (5000) NOT NULL,
    [Tipo]          NCHAR (1)      NOT NULL,
    CONSTRAINT [PK_Table_idSeguimiento] PRIMARY KEY CLUSTERED ([idSeguimiento] ASC),
    CONSTRAINT [FK_RPI_Seguimientos_RPI_Asuntos] FOREIGN KEY ([idAsunto]) REFERENCES [dbo].[RPI_Asuntos] ([idAsunto]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Table_idAsunto]
    ON [dbo].[RPI_Seguimientos]([idAsunto] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Table_Fecha]
    ON [dbo].[RPI_Seguimientos]([Fecha] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'C-Comercial, F-Financiero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RPI_Seguimientos', @level2type = N'COLUMN', @level2name = N'Tipo';

