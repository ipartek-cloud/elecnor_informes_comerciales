CREATE TABLE [dbo].[rptContratacion_SG_Mercado] (
    [idContratacionCentro]                  INT             IDENTITY (1, 1) NOT NULL,
    [CodCentro]                             NVARCHAR (255)  NULL,
    [Año]                                   INT             NULL,
    [Pais]                                  NVARCHAR (255)  NULL,
    [ImporteContratado]                     DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [LoginUsuario]                          NVARCHAR (100)  CONSTRAINT [DF_rptContrSGM_Login] DEFAULT ('ACCESS') NULL,
    [FechaCreacion]                         DATETIME        CONSTRAINT [DF_rptContrSGM_Fecha] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_rptContratacion_SG_Mercado] PRIMARY KEY CLUSTERED ([idContratacionCentro] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_rptContrSGM_LoginUsuario]
    ON [dbo].[rptContratacion_SG_Mercado]([LoginUsuario] ASC);

