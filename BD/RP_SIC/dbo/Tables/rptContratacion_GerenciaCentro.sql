CREATE TABLE [dbo].[rptContratacion_GerenciaCentro] (
    [idContratacionCentro]                  INT             IDENTITY (1, 1) NOT NULL,
    [Año]                                   INT             NULL,
    [NombreGerente]                         NVARCHAR (255)  NULL,
    [CodCentro]                             NVARCHAR (255)  NULL,
    [Mercado]                               NVARCHAR (255)  NULL,
    [ImporteContratado]                     DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [Objetivos]                             INT             NULL,
    PRIMARY KEY CLUSTERED ([idContratacionCentro] ASC)
);

