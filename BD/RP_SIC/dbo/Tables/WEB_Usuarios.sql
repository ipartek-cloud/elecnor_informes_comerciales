CREATE TABLE [dbo].[WEB_Usuarios] (
    [Usuario]                    VARCHAR (50)  NOT NULL,
    [NombreUsuario]              VARCHAR (100) NULL,
    [Puesto]                     VARCHAR (5)   NOT NULL,
    [CodEntidad]                 VARCHAR (3)   NULL,
    [FActividad]                 DATETIME      NULL,
    [AccesoCartera]              BIT           CONSTRAINT [DF_WEB_Usuarios_AccesoCartera] DEFAULT ((1)) NOT NULL,
    [CodEntidadReferencias]      VARCHAR (3)   NULL,
    [AccesoReferencias]          BIT           CONSTRAINT [DF_WEB_Usuarios_AccesoCartera1] DEFAULT ((0)) NOT NULL,
    [AccesoReferencias_Gerencia] BIT           CONSTRAINT [DF_WEB_Usuarios_AccesoAsuntos_VerMontos1] DEFAULT ((0)) NULL,
    [AccesoDocumentacion]        BIT           CONSTRAINT [DF_WEB_Usuarios_AccesoReferencias1] DEFAULT ((0)) NULL,
    [AccesoAsuntos]              BIT           CONSTRAINT [DF_WEB_Usuarios_AccesoAsuntos] DEFAULT ((0)) NULL,
    [AccesoAsuntos_VerMontos]    BIT           CONSTRAINT [DF_WEB_Usuarios_AccesoAsuntos1] DEFAULT ((0)) NULL,
    [Acceso_CarteraDiferida]     BIT           CONSTRAINT [DF_WEB_Usuarios_AccesoAsuntos_VerMontos1_1] DEFAULT ((0)) NULL,
    [Acceso_Tendencias]          BIT           CONSTRAINT [DF_WEB_Usuarios_Acceso_CarteraDiferida1] DEFAULT ((0)) NULL,
    [Acceso_Informes]            BIT           CONSTRAINT [DF_WEB_Usuarios_Acceso_Informes] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED ([Usuario] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Puesto]
    ON [dbo].[WEB_Usuarios]([Puesto] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DG, SDG, DN, AREA, DEL, CT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WEB_Usuarios', @level2type = N'COLUMN', @level2name = N'Puesto';

