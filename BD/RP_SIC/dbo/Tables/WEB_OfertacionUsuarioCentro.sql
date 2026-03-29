CREATE TABLE [dbo].[WEB_OfertacionUsuarioCentro] (
    [id]                      INT            IDENTITY (1, 1) NOT NULL,
    [Usuario]                 VARCHAR (50)   NOT NULL,
    [Año]                     INT            NOT NULL,
    [Mes]                     INT            NOT NULL,
    [CodDirGeneral]           VARCHAR (3)    NULL,
    [NombreDirGeneral]        NVARCHAR (100) NULL,
    [CodSubDirGeneral]        VARCHAR (3)    NULL,
    [NombreSubDirGeneral]     NVARCHAR (100) NULL,
    [CodDDirNegocio]          VARCHAR (3)    NULL,
    [NombreDirNegocio]        NVARCHAR (30)  NULL,
    [CodSubDirNegocioArea]    VARCHAR (3)    NULL,
    [NombreSubDirNegocioArea] NVARCHAR (100) NULL,
    [CodDelegacion]           VARCHAR (3)    NULL,
    [NombreDelegacion]        NVARCHAR (30)  NULL,
    [CodCentro]               VARCHAR (3)    NULL,
    [NombreCentro]            NVARCHAR (30)  NULL,
    [Cantidad_Abiertas]       INT            CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Cantidad_Abiertas] DEFAULT ((0)) NOT NULL,
    [Monto_Abiertas]          FLOAT (53)     CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Monto_Abiertas] DEFAULT ((0)) NOT NULL,
    [Cantidad_PdtesPresentar] INT            CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Cantidad_PdtesPresentar] DEFAULT ((0)) NOT NULL,
    [Monto_PdtesPresentar]    FLOAT (53)     CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Monto_PdtesPresentar] DEFAULT ((0)) NOT NULL,
    [Cantidad_PdtesDecidir]   INT            CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Cantidad_PdtesDecidir] DEFAULT ((0)) NOT NULL,
    [Monto_PdtesDecidir]      FLOAT (53)     CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Monto_PdtesDecidir] DEFAULT ((0)) NOT NULL,
    [Cantidad_Denegadas]      INT            CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Cantidad_Denegadas] DEFAULT ((0)) NOT NULL,
    [Monto_Denegadas]         FLOAT (53)     CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Monto_Denegadas] DEFAULT ((0)) NOT NULL,
    [Cantidad_Adjudicadas]    INT            CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Cantidad_Adjudicadas] DEFAULT ((0)) NOT NULL,
    [Monto_Adjudicadas]       FLOAT (53)     CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_Monto_Adjudicadas] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_WEB_OfertacionUsuarioCentro] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro]
    ON [dbo].[WEB_OfertacionUsuarioCentro]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro_1]
    ON [dbo].[WEB_OfertacionUsuarioCentro]([CodDirGeneral] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro_2]
    ON [dbo].[WEB_OfertacionUsuarioCentro]([CodSubDirGeneral] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro_3]
    ON [dbo].[WEB_OfertacionUsuarioCentro]([CodDDirNegocio] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro_4]
    ON [dbo].[WEB_OfertacionUsuarioCentro]([CodSubDirNegocioArea] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro_5]
    ON [dbo].[WEB_OfertacionUsuarioCentro]([CodDelegacion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro_6]
    ON [dbo].[WEB_OfertacionUsuarioCentro]([CodCentro] ASC);

