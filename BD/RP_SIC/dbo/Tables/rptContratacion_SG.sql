CREATE TABLE [dbo].[rptContratacion_SG] (
    [idContratacionCentro]                  INT             IDENTITY (1, 1) NOT NULL,
    [Año]                                   INT             NULL,
    [CodCentro]                             NVARCHAR (255)  NULL,
    [ImporteContratado]                     DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [LoginUsuario]                          NVARCHAR (100)  CONSTRAINT [DF_rptContrSG_Login] DEFAULT ('ACCESS') NULL,
    [FechaCreacion]                         DATETIME        CONSTRAINT [DF_rptContrSG_Fecha] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_rptContratacion_SG] PRIMARY KEY CLUSTERED ([idContratacionCentro] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IX_rptContrSG_LoginUsuario]
    ON [dbo].[rptContratacion_SG]([LoginUsuario] ASC);

