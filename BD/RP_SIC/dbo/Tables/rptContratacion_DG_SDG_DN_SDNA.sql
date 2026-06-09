CREATE TABLE [dbo].[rptContratacion_DG_SDG_DN_SDNA] (
    [idContratacionMensualInfraEstructuras] INT             IDENTITY (1, 1) NOT NULL,
    [Año]                                   INT             NULL,
    [CodSubDirGeneral]                      NVARCHAR (255)  NULL,
    [NombreSubDirGeneral]                   NVARCHAR (255)  NULL,
    [NombreDirNegocio]                      NVARCHAR (255)  NULL,
    [NombreSubDirNegocioArea]               NVARCHAR (255)  NULL,
    [Pais]                                  NVARCHAR (255)  NULL,
    [ImporteContratado]                     DECIMAL (19, 4) NULL,
    [ImporteContratadoAcumulado]            DECIMAL (19, 4) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (19, 4) NULL,
    [ImporteObjetivo]                       DECIMAL (19, 4) NULL,
    [LoginUsuario]                          NVARCHAR (100)  NULL DEFAULT ('ACCESS'),
    [FechaCreacion]                         DATETIME        NULL DEFAULT (GETDATE()),
    PRIMARY KEY CLUSTERED ([idContratacionMensualInfraEstructuras] ASC)
);

CREATE NONCLUSTERED INDEX [IX_rptContr_DG_LoginUsuario]
    ON [dbo].[rptContratacion_DG_SDG_DN_SDNA]([LoginUsuario] ASC);

