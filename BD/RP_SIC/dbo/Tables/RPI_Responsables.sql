CREATE TABLE [dbo].[RPI_Responsables] (
    [idAsunto]           INT          NOT NULL,
    [UsuarioResponsable] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_RPI_Responsables] PRIMARY KEY CLUSTERED ([idAsunto] ASC, [UsuarioResponsable] ASC),
    CONSTRAINT [FK_RPI_Responsables_RPI_Asuntos1] FOREIGN KEY ([idAsunto]) REFERENCES [dbo].[RPI_Asuntos] ([idAsunto]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_RPI_Responsables_WEB_Usuarios] FOREIGN KEY ([UsuarioResponsable]) REFERENCES [dbo].[WEB_Usuarios] ([Usuario]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_idAsunto]
    ON [dbo].[RPI_Responsables]([idAsunto] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UsuarioResponsable]
    ON [dbo].[RPI_Responsables]([UsuarioResponsable] ASC);

