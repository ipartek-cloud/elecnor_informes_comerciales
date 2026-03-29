CREATE TABLE [dbo].[WEB_UsuariosGerencias] (
    [Usuario]  VARCHAR (50) NOT NULL,
    [Gerencia] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_WEB_UsuariosGerencias] PRIMARY KEY CLUSTERED ([Usuario] ASC, [Gerencia] ASC),
    CONSTRAINT [FK_WEB_UsuariosGerencias_WEB_Usuarios] FOREIGN KEY ([Usuario]) REFERENCES [dbo].[WEB_Usuarios] ([Usuario]) ON DELETE CASCADE ON UPDATE CASCADE
);

