-- Tabla de trabajo multiusuario con aislamiento por LoginUsuario.
-- Informe: DG - Unidades Negocio - Mercado (SDG 221).
-- Origen: spContratacion_DG_SDG_DN_SDNA_Deleg_Ajuste.

CREATE TABLE [dbo].[rptContratacion_DG_SDG_DN_SDNA_Deleg] (
    [idContratacionMensualInfraEstructuras] INT             IDENTITY (1, 1) NOT NULL,
    [Año]                                   INT             NULL,
    [CodDDirNegocio]                        NVARCHAR (255)  NULL,
    [CodDelegacion]                         NVARCHAR (255)  NULL,
    [CodSubDirGeneral]                      NVARCHAR (255)  NULL,
    [CodSubDirNegocioArea]                  NVARCHAR (255)  NULL,
    [ImporteContratado]                     DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [NombreDelegacion]                      NVARCHAR (255)  NULL,
    [NombreDirNegocio]                      NVARCHAR (255)  NULL,
    [NombreSubDirGeneral]                   NVARCHAR (255)  NULL,
    [NombreSubDirNegocioArea]               NVARCHAR (255)  NULL,
    [Pais]                                  NVARCHAR (255)  NULL,
    [LoginUsuario]                          NVARCHAR (100)  NULL CONSTRAINT [DF_rptContratacion_DG_SDG_DN_SDNA_Deleg_LoginUsuario] DEFAULT ('ACCESS'),
    [FechaCreacion]                         DATETIME        NULL CONSTRAINT [DF_rptContratacion_DG_SDG_DN_SDNA_Deleg_FechaCreacion] DEFAULT (GETDATE()),
    CONSTRAINT [PK_rptContratacion_DG_SDG_DN_SDNA_Deleg] PRIMARY KEY CLUSTERED ([idContratacionMensualInfraEstructuras] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_rptContratacion_DG_SDG_DN_SDNA_Deleg_LoginUsuario]
    ON [dbo].[rptContratacion_DG_SDG_DN_SDNA_Deleg]([LoginUsuario] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_rptContratacion_DG_SDG_DN_SDNA_Deleg_Anio]
    ON [dbo].[rptContratacion_DG_SDG_DN_SDNA_Deleg]([Año] ASC);
GO
