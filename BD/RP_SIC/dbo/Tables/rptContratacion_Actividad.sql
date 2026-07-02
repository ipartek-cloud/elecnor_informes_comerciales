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
    [LoginUsuario]                          NVARCHAR (100)  CONSTRAINT [DF_rptContrAct_Login] DEFAULT ('ACCESS') NULL,
    [FechaCreacion]                         DATETIME        CONSTRAINT [DF_rptContrAct_Fecha] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_rptContratacion_Actividad] PRIMARY KEY CLUSTERED ([idContratacionActividad] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_rptContrAct_LoginUsuario]
    ON [dbo].[rptContratacion_Actividad]([LoginUsuario] ASC);

