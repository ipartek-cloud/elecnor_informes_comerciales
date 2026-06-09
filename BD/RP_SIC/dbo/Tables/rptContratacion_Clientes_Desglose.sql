CREATE TABLE [dbo].[rptContratacion_Clientes_Desglose] (
    [idContratacionActividad]               INT             IDENTITY (1, 1) NOT NULL,
    [AI]                                    NVARCHAR (2)    NULL,
    [Año]                                   INT             NULL,
    [Cliente]                               NVARCHAR (100)  NULL,
    [ClienteDesglose]                       NVARCHAR (100)  NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [Mercado]                               NVARCHAR (50)   NULL,
    [Pais]                                  NVARCHAR (50)   NULL,
    [LoginUsuario]                          NVARCHAR (100)  NULL DEFAULT ('ACCESS'),
    [FechaCreacion]                         DATETIME        NULL DEFAULT (GETDATE()),
    CONSTRAINT [PK_rptContratacion_Clientes_Desglose] PRIMARY KEY CLUSTERED ([idContratacionActividad] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_rptContrCliDesg_LoginUsuario]
    ON [dbo].[rptContratacion_Clientes_Desglose]([LoginUsuario] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_rptDesglose_FiltroContexto]
    ON [dbo].[rptContratacion_Clientes_Desglose]([Mercado] ASC, [Año] ASC, [ClienteDesglose] ASC)
    INCLUDE([Cliente], [ImporteContratadoAcumulado], [ImporteContratadoAcumuladoAñoAnterior]) WITH (FILLFACTOR = 90);
