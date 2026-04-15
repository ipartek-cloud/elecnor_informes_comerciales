CREATE TABLE [dbo].[rptContratacion_SG_Mercado] (
    [idContratacionCentro]                  INT             IDENTITY (1, 1) NOT NULL,
    [CodCentro]                             NVARCHAR (255)  NULL,
    [Año]                                   INT             NULL,
    [Pais]                                  NVARCHAR (255)  NULL,
    [ImporteContratado]                     DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_rptContratacion_SG_Mercado] PRIMARY KEY CLUSTERED ([idContratacionCentro] ASC)
);

