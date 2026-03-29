CREATE TABLE [dbo].[WEB_CarteraUsuarioCentro] (
    [id]                            INT            IDENTITY (1, 1) NOT NULL,
    [Usuario]                       VARCHAR (50)   NOT NULL,
    [Año]                           INT            NOT NULL,
    [Mes]                           INT            NOT NULL,
    [CodDirGeneral]                 VARCHAR (3)    NULL,
    [NombreDirGeneral]              NVARCHAR (100) NULL,
    [CodSubDirGeneral]              VARCHAR (3)    NULL,
    [NombreSubDirGeneral]           NVARCHAR (100) NULL,
    [CodDDirNegocio]                VARCHAR (3)    NULL,
    [NombreDirNegocio]              NVARCHAR (30)  NULL,
    [CodSubDirNegocioArea]          VARCHAR (3)    NULL,
    [NombreSubDirNegocioArea]       NVARCHAR (100) NULL,
    [CodDelegacion]                 VARCHAR (3)    NULL,
    [NombreDelegacion]              NVARCHAR (30)  NULL,
    [CodCentro]                     VARCHAR (3)    NULL,
    [ImporteCarteraPdteMesActual]   FLOAT (53)     CONSTRAINT [DF_WEB_CarteraUsuarioCentro_ImporteCarteraPdteMesActual] DEFAULT ((0)) NULL,
    [ImporteCarteraPdteMesAnterior] FLOAT (53)     CONSTRAINT [DF_WEB_CarteraUsuarioCentro_ImporteCarteraPdteMesActual1] DEFAULT ((0)) NULL,
    [NombreCentro]                  NVARCHAR (30)  NULL,
    [Ajustado]                      BIT            CONSTRAINT [DF_WEB_CarteraUsuarioCentro_Ajustado] DEFAULT ((0)) NULL,
    [Total]                         AS             (((isnull([ImporteElecnor],(0))+isnull([ImporteFilial],(0)))+isnull([ImporteUTE],(0)))+isnull([ImporteSucursal],(0))),
    [ImporteElecnor]                FLOAT (53)     CONSTRAINT [DF_WEB_CarteraUsuarioCentro_ImporteElecnor] DEFAULT ((0)) NULL,
    [ImporteFilial]                 FLOAT (53)     CONSTRAINT [DF_WEB_CarteraUsuarioCentro_ImporteFilial] DEFAULT ((0)) NULL,
    [ImporteUTE]                    FLOAT (53)     CONSTRAINT [DF_WEB_CarteraUsuarioCentro_ImporteUTE] DEFAULT ((0)) NULL,
    [ImporteSucursal]               FLOAT (53)     CONSTRAINT [DF_WEB_CarteraUsuarioCentro_ImporteSucursal] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_WEB_id] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_Usuario_CodCentro]
    ON [dbo].[WEB_CarteraUsuarioCentro]([Usuario] ASC, [CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CodDirGeneral]
    ON [dbo].[WEB_CarteraUsuarioCentro]([CodDirGeneral] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CodSubDirGeneral]
    ON [dbo].[WEB_CarteraUsuarioCentro]([CodSubDirGeneral] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CodDDirNegocio]
    ON [dbo].[WEB_CarteraUsuarioCentro]([CodDDirNegocio] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CodSubDirNegocioArea]
    ON [dbo].[WEB_CarteraUsuarioCentro]([CodSubDirNegocioArea] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_AÑO_MES_CODCENTRO]
    ON [dbo].[WEB_CarteraUsuarioCentro]([Año] ASC, [Mes] ASC, [CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CodDelegacion]
    ON [dbo].[WEB_CarteraUsuarioCentro]([CodDelegacion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CodCentro]
    ON [dbo].[WEB_CarteraUsuarioCentro]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraUsuarioCentro_Usuario]
    ON [dbo].[WEB_CarteraUsuarioCentro]([Usuario] ASC)
    INCLUDE([id], [CodCentro]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraUsuarioCentro_CodCentro]
    ON [dbo].[WEB_CarteraUsuarioCentro]([CodCentro] ASC)
    INCLUDE([id]);

