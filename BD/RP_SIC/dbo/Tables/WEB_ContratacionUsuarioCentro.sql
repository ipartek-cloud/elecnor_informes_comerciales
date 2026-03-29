CREATE TABLE [dbo].[WEB_ContratacionUsuarioCentro] (
    [id]                                       INT            IDENTITY (1, 1) NOT NULL,
    [Usuario]                                  VARCHAR (50)   NOT NULL,
    [Año]                                      INT            NOT NULL,
    [Mes]                                      INT            NOT NULL,
    [CodDirGeneral]                            VARCHAR (3)    NULL,
    [NombreDirGeneral]                         NVARCHAR (100) NULL,
    [CodSubDirGeneral]                         VARCHAR (3)    NULL,
    [NombreSubDirGeneral]                      NVARCHAR (100) NULL,
    [CodDDirNegocio]                           VARCHAR (3)    NULL,
    [NombreDirNegocio]                         NVARCHAR (30)  NULL,
    [CodSubDirNegocioArea]                     VARCHAR (3)    NULL,
    [NombreSubDirNegocioArea]                  NVARCHAR (100) NULL,
    [CodDelegacion]                            VARCHAR (3)    NULL,
    [NombreDelegacion]                         NVARCHAR (30)  NULL,
    [CodCentro]                                VARCHAR (3)    NULL,
    [NombreCentro]                             NVARCHAR (30)  NULL,
    [ImporteContratado]                        FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteContratado] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumulado]               FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteContratadoAcumulado] DEFAULT ((0)) NULL,
    [ImporteContratadoMesAnterior]             FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteContratadoMesAnterior] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoMesAnterior]    FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteContratadoAcumuladoMesAnterior] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoAñoAnterior]    FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteContratadoAcumuladoAñoAnterior] DEFAULT ((0)) NULL,
    [ImporteCarteraPdteAñoActual]              FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteCarteraPdteAñoActual] DEFAULT ((0)) NULL,
    [ImporteCarteraPdteAñoActualMesAnterior]   FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteCarteraPdteAñoActual1_1] DEFAULT ((0)) NULL,
    [ImporteCarteraPdteAñoAnterior]            FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteCarteraPdteAñoActual1] DEFAULT ((0)) NULL,
    [ImporteCarteraPdteAñoAnteriorMesAnterior] FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_ImporteCarteraPdteAñoAnterior1] DEFAULT ((0)) NULL,
    [VariacionContratacion]                    AS             ([dbo].[fnImporteVariacion]([ImporteContratadoAcumulado],[ImporteContratadoAcumuladoAñoAnterior])),
    [VariacionCartera]                         AS             ([dbo].[fnImporteVariacion]([ImporteCarteraPdteAñoActual],[ImporteCarteraPdteAñoAnterior])),
    [VariacionCarteraMesAnterior]              AS             ([dbo].[fnImporteVariacion]([ImporteCarteraPdteAñoActualMesAnterior],[ImporteCarteraPdteAñoAnteriorMesAnterior])),
    [NumOfertasCarteraNegativa]                INT            CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_NumOfertasCarteraNegativa] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_WEB_ContratacionUsuarioCentro_1] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Usuario]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodDirGeneral]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([CodDirGeneral] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodSubDirGeneral]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([CodSubDirGeneral] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodDDirNegocio]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([CodDDirNegocio] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodSubDirNegocioArea]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([CodSubDirNegocioArea] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodDelegacion]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([CodDelegacion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodCentro]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_ContratacionUsuarioCentro_Usuario]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([Usuario] ASC)
    INCLUDE([id], [CodCentro]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_ContratacionUsuarioCentro_Usuario_Centro]
    ON [dbo].[WEB_ContratacionUsuarioCentro]([Usuario] ASC, [CodCentro] ASC)
    INCLUDE([id]);

