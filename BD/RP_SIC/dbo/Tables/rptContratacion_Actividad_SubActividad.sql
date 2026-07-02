CREATE TABLE [dbo].[rptContratacion_Actividad_SubActividad] (
    [idContratacionActividad]               INT             IDENTITY (1, 1) NOT NULL,
    [Año]                                   INT             NULL,
    [Orden]                                 INT             NULL,
    [CodActividad]                          NVARCHAR (2)    NULL,
    [Actividad]                             NVARCHAR (255)  NULL,
    [CodAct1]                               NVARCHAR (2)    NULL,
    [CodAct2]                               NVARCHAR (2)    NULL,
    [Pais]                                  NVARCHAR (255)  NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [Desglose_AñoAnterior]                  BIT             DEFAULT ((0)) NOT NULL,
    [LoginUsuario]                          NVARCHAR (100)  CONSTRAINT [DF_rptContrActSub_Login] DEFAULT ('ACCESS') NULL,
    [FechaCreacion]                         DATETIME        CONSTRAINT [DF_rptContrActSub_Fecha] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_rptContratacion_Actividad_SubActividad] PRIMARY KEY CLUSTERED ([idContratacionActividad] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_rptContrActSub_LoginUsuario]
    ON [dbo].[rptContratacion_Actividad_SubActividad]([LoginUsuario] ASC);

