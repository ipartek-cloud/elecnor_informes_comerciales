CREATE TABLE [dbo].[rptContratacion_Clientes] (
    [idContratacionActividad]                INT             IDENTITY (1, 1) NOT NULL,
    [Año]                                    INT             NOT NULL,
    [Mercado]                                NVARCHAR (255)  NULL,
    [Pais]                                   NVARCHAR (255)  NULL,
    [Cliente]                                NVARCHAR (255)  NULL,
    [ImporteContratadoAcumulado]             DECIMAL (18, 4) DEFAULT ((0)) NULL,
    [ImporteContratadoAcumulado_AñoAnterior] DECIMAL (18, 4) DEFAULT ((0)) NULL,
    [ImporteContratadoAcumulado_Ajuste]      DECIMAL (18, 4) DEFAULT ((0)) NULL,
    [AI]                                     NVARCHAR (50)   NULL,
    [Row]                                    INT             NULL,
    CONSTRAINT [PK_rptContratacion_Clientes] PRIMARY KEY CLUSTERED ([idContratacionActividad] ASC)
);

