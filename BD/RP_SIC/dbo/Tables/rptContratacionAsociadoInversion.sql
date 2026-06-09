CREATE TABLE [dbo].[rptContratacionAsociadoInversion] (
    [idRptContratacion]                 INT             IDENTITY (1, 1) NOT NULL,
    [Año]                               INT             NULL,
    [Mercado]                           NVARCHAR (255)  NULL,
    [Mensual_Contratacion]              DECIMAL (19, 4) NULL,
    [Acumulado_Contratacion]            DECIMAL (19, 4) NULL,
    [Acumulado_ContratacionAñoAnterior] DECIMAL (19, 4) NULL,
    [LoginUsuario]                      NVARCHAR (100)  NULL DEFAULT ('ACCESS'),
    [FechaCreacion]                     DATETIME        NULL DEFAULT (GETDATE()),
    PRIMARY KEY CLUSTERED ([idRptContratacion] ASC)
);

CREATE NONCLUSTERED INDEX [IX_rptContrAI_LoginUsuario]
    ON [dbo].[rptContratacionAsociadoInversion]([LoginUsuario] ASC);

