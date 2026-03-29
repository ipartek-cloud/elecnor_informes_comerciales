CREATE TABLE [dbo].[WEB_CarteraDiferidaPdteEjecutarUsuarioCentro] (
    [id]                       INT            IDENTITY (1, 1) NOT NULL,
    [Usuario]                  VARCHAR (50)   NOT NULL,
    [Año]                      INT            NOT NULL,
    [Mes]                      INT            NOT NULL,
    [CodDirGeneral]            VARCHAR (3)    NULL,
    [NombreDirGeneral]         NVARCHAR (100) NOT NULL,
    [CodSubDirGeneral]         VARCHAR (3)    NULL,
    [NombreSubDirGeneral]      NVARCHAR (100) NOT NULL,
    [CodDDirNegocio]           VARCHAR (3)    NULL,
    [NombreDirNegocio]         NVARCHAR (30)  NOT NULL,
    [CodSubDirNegocioArea]     VARCHAR (3)    NULL,
    [NombreSubDirNegocioArea]  NVARCHAR (100) NOT NULL,
    [CodDelegacion]            VARCHAR (3)    NULL,
    [NombreDelegacion]         NVARCHAR (30)  NOT NULL,
    [CodCentro]                VARCHAR (3)    NULL,
    [NombreCentro]             NVARCHAR (30)  NOT NULL,
    [Tipo]                     VARCHAR (1)    NULL,
    [Gerencia]                 VARCHAR (100)  NULL,
    [MarcaGerencia]            AS             ([dbo].[fnGerentesMarca_NombreGerente]([Gerencia])),
    [AGRUP]                    VARCHAR (100)  NULL,
    [Cliente]                  VARCHAR (100)  NULL,
    [Contrato]                 VARCHAR (100)  NULL,
    [FInicio]                  DATE           NULL,
    [FFinal]                   DATE           NULL,
    [FFinalEfectiva]           DATE           NULL,
    [CodOferta]                VARCHAR (10)   NULL,
    [DesOfer]                  VARCHAR (150)  NULL,
    [TipoOferta]               VARCHAR (1)    NULL,
    [Mercado]                  VARCHAR (50)   NULL,
    [CartInicio]               FLOAT (53)     CONSTRAINT [DF_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_CartInicio] DEFAULT ((0)) NULL,
    [NTrimestre]               INT            NULL,
    [MontoTrimestre]           FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1] DEFAULT ((0)) NULL,
    [MontoAnual]               FLOAT (53)     CONSTRAINT [DF_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_MontoTrimestre1] DEFAULT ((0)) NULL,
    [PrevistoAño]              FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_1] DEFAULT ((0)) NULL,
    [Nuevo]                    FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_2] DEFAULT ((0)) NULL,
    [Contrat]                  FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_3] DEFAULT ((0)) NULL,
    [CarteraPendiente]         FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_9] DEFAULT ((0)) NULL,
    [TrimSQL]                  FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_4] DEFAULT ((0)) NULL,
    [Regu]                     FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_5] DEFAULT ((0)) NULL,
    [A_Año]                    FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_6] DEFAULT ((0)) NULL,
    [A_Año1]                   FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_7] DEFAULT ((0)) NULL,
    [A_Año2]                   FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_8] DEFAULT ((0)) NULL,
    [Prorrogable]              VARCHAR (100)  NULL,
    [Produccion_A]             FLOAT (53)     CONSTRAINT [DF_Table_1_CartInicio1_10] DEFAULT ((0)) NULL,
    [MargenProduccion_A]       FLOAT (53)     CONSTRAINT [DF_Table_1_Produccion_A1_1] DEFAULT ((0)) NULL,
    [CostoTotal_A]             FLOAT (53)     CONSTRAINT [DF_Table_1_Produccion_A1] DEFAULT ((0)) NULL,
    [PorcProduccion_A]         FLOAT (53)     CONSTRAINT [DF_Table_1_Produccion_A1_2] DEFAULT ((0)) NULL,
    [Produccion]               FLOAT (53)     CONSTRAINT [DF_Table_1_Produccion_A1_3] DEFAULT ((0)) NULL,
    [Facturacion_A]            FLOAT (53)     CONSTRAINT [DF_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Facturacion_Origen_A1_1] DEFAULT ((0)) NULL,
    [Facturacion_Origen_A]     FLOAT (53)     CONSTRAINT [DF_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Produccion_A1] DEFAULT ((0)) NULL,
    [Facturacion_Anticipada_A] FLOAT (53)     CONSTRAINT [DF_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Facturacion_Origen_A1] DEFAULT ((0)) NULL,
    [Produccion_Curso_A]       FLOAT (53)     CONSTRAINT [DF_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Facturacion_Anticipada_A1] DEFAULT ((0)) NULL,
    [TotalObrasOferta]         INT            CONSTRAINT [DF_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_TotalObrasOferta] DEFAULT ((0)) NULL,
    [LiteralSIN]               VARCHAR (50)   NULL,
    [MarcaCodCentro]           AS             ([dbo].[fnGerentesMarca_CodCentro]([CodCentro])),
    CONSTRAINT [PK_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Table_Usuario]
    ON [dbo].[WEB_CarteraDiferidaPdteEjecutarUsuarioCentro]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_CodOferta]
    ON [dbo].[WEB_CarteraDiferidaPdteEjecutarUsuarioCentro]([CodOferta] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Usuario3]
    ON [dbo].[WEB_CarteraDiferidaPdteEjecutarUsuarioCentro]([Usuario] ASC)
    INCLUDE([id], [CodOferta], [DesOfer]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Usuario2]
    ON [dbo].[WEB_CarteraDiferidaPdteEjecutarUsuarioCentro]([Usuario] ASC)
    INCLUDE([id], [CodCentro], [CodOferta]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Usuario]
    ON [dbo].[WEB_CarteraDiferidaPdteEjecutarUsuarioCentro]([Usuario] ASC)
    INCLUDE([id], [CodCentro], [CodOferta], [Produccion_A]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Usuario_DesOfer]
    ON [dbo].[WEB_CarteraDiferidaPdteEjecutarUsuarioCentro]([Usuario] ASC, [DesOfer] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDiferidaPdteEjecutarUsuarioCentro_Usuario_Produccion_A_DesOfer]
    ON [dbo].[WEB_CarteraDiferidaPdteEjecutarUsuarioCentro]([Usuario] ASC, [Produccion_A] ASC, [DesOfer] ASC);

