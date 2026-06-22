CREATE TABLE [dbo].[WEB_Usuarios_Informes] (
    [Informe_Web] NVARCHAR (50) NOT NULL,
    [Acceso_DG]   BIT           CONSTRAINT [DF_WEB_Usuarios_Informes_Acceso_DG] DEFAULT ((1)) NOT NULL,
    [Acceso_SDG]  BIT           CONSTRAINT [DF_WEB_Usuarios_Informes_Acceso_SDG] DEFAULT ((1)) NOT NULL,
    [Acceso_DN]   BIT           CONSTRAINT [DF_WEB_Usuarios_Informes_Acceso_DN] DEFAULT ((1)) NOT NULL,
    [Acceso_AREA] BIT           CONSTRAINT [DF_WEB_Usuarios_Informes_Acceso_AREA] DEFAULT ((1)) NOT NULL,
    [Acceso_DEL]  BIT           CONSTRAINT [DF_WEB_Usuarios_Informes_Acceso_DEL] DEFAULT ((1)) NOT NULL,
    [Acceso_CT]   BIT           CONSTRAINT [DF_WEB_Usuarios_Informes_Acceso_CT] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_WEB_Usuarios_Informes] PRIMARY KEY CLUSTERED ([Informe_Web] ASC)
);

