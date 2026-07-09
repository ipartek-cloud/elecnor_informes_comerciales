CREATE TABLE [dbo].[rptContratacion_GerenciaCentro] (
    [idContratacionCentro]                  INT             IDENTITY (1, 1) NOT NULL,
    [Año]                                   INT             NULL,
    [NombreGerente]                         NVARCHAR (255)  NULL,
    [CodCentro]                             NVARCHAR (255)  NULL,
    [ImporteContratado]                     DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [LoginUsuario]                          NVARCHAR (100)  CONSTRAINT [DF_rptContrGer_Login] DEFAULT ('ACCESS') NULL,
    [FechaCreacion]                         DATETIME        CONSTRAINT [DF_rptContrGer_Fecha] DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idContratacionCentro] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_rptContrGer_LoginUsuario]
    ON [dbo].[rptContratacion_GerenciaCentro]([LoginUsuario] ASC);

