CREATE TABLE [dbo].[rptContratacion_Internacional] (
    [idContratacionInternacional]           INT             IDENTITY (1, 1) NOT NULL,
    [Ajuste]                                BIT             NOT NULL,
    [Año]                                   INT             NULL,
    [CodProv]                               NVARCHAR (2)    NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [Pais]                                  NVARCHAR (255)  NULL,
    [LoginUsuario]                          NVARCHAR (100)  NULL DEFAULT ('ACCESS'),
    [FechaCreacion]                         DATETIME        NULL DEFAULT (GETDATE()),
    CONSTRAINT [PK_rptContratacion_Internacional] PRIMARY KEY CLUSTERED ([idContratacionInternacional] ASC)
);

CREATE NONCLUSTERED INDEX [IX_rptContrInt_LoginUsuario]
    ON [dbo].[rptContratacion_Internacional]([LoginUsuario] ASC);

