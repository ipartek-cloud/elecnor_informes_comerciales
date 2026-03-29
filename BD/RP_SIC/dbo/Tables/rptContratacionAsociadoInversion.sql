CREATE TABLE [dbo].[rptContratacionAsociadoInversion] (
    [idRptContratacion]                 INT             IDENTITY (1, 1) NOT NULL,
    [Año]                               INT             NULL,
    [Mercado]                           NVARCHAR (255)  NULL,
    [Mensual_Contratacion]              DECIMAL (19, 4) NULL,
    [Acumulado_Contratacion]            DECIMAL (19, 4) NULL,
    [Acumulado_ContratacionAñoAnterior] DECIMAL (19, 4) NULL,
    PRIMARY KEY CLUSTERED ([idRptContratacion] ASC)
);

