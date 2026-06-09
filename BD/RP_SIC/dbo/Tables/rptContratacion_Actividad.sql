CREATE TABLE [dbo].[rptContratacion_Actividad] (
    [idContratacionActividad]               INT             IDENTITY (1, 1) NOT NULL,
    [Actividad]                             NVARCHAR (255)  NULL,
    [Año]                                   INT             NULL,
    [CodActividad]                          NVARCHAR (2)    NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoLastYear]    DECIMAL (18, 2) NULL,
    [Orden]                                 INT             NULL,
    [Pais]                                  NVARCHAR (255)  NULL,
    [NombreDirGeneral]                      VARCHAR (255)   NULL,
    [LoginUsuario]                          NVARCHAR (100)  NULL DEFAULT ('ACCESS'),
    [FechaCreacion]                         DATETIME        NULL DEFAULT (GETDATE()),
    CONSTRAINT [PK_rptContratacion_Actividad] PRIMARY KEY CLUSTERED ([idContratacionActividad] ASC)
);

CREATE NONCLUSTERED INDEX [IX_rptContrAct_LoginUsuario]
    ON [dbo].[rptContratacion_Actividad]([LoginUsuario] ASC);

