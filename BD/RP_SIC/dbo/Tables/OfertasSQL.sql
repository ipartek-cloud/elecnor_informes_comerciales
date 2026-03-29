CREATE TABLE [dbo].[OfertasSQL] (
    [idOfertasSQL]      INT          IDENTITY (1, 1) NOT NULL,
    [CodCentro_Origen]  VARCHAR (3)  NULL,
    [CodCentro]         VARCHAR (3)  NULL,
    [CodOferta]         VARCHAR (10) NULL,
    [NumRegularizacion] INT          NULL,
    [FAlta]             DATETIME     NULL,
    [DescripcionOferta] VARCHAR (50) NULL,
    [CodCliente]        VARCHAR (8)  NULL,
    [Localidad]         VARCHAR (30) NULL,
    [CodProv]           VARCHAR (2)  NULL,
    [ImporteAprox]      FLOAT (53)   NULL,
    [CodAct1]           VARCHAR (2)  NULL,
    [CodAct2]           VARCHAR (2)  NULL,
    [CodResponsable]    VARCHAR (3)  NULL,
    [FPresentacion]     DATETIME     NULL,
    [PresupuestoVenta]  FLOAT (53)   NULL,
    [FAdjudicacion]     DATETIME     NULL,
    [AñoAdjudicacion]   INT          NULL,
    [Adjudicada]        VARCHAR (1)  NULL,
    [ImporteContratado] FLOAT (53)   NULL,
    [Reparto]           BIT          CONSTRAINT [DF_OfertasSQL_Regularizaciones] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_OfertasSQL] PRIMARY KEY CLUSTERED ([idOfertasSQL] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_CodCentro]
    ON [dbo].[OfertasSQL]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AñoAdjudicacion]
    ON [dbo].[OfertasSQL]([AñoAdjudicacion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodAct]
    ON [dbo].[OfertasSQL]([CodAct1] ASC, [CodAct2] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FAdjudicacion]
    ON [dbo].[OfertasSQL]([FAdjudicacion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OfertasSQL_Reparto]
    ON [dbo].[OfertasSQL]([Reparto] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Adjudicada]
    ON [dbo].[OfertasSQL]([Adjudicada] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodOferta]
    ON [dbo].[OfertasSQL]([CodOferta] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodOferta_ImporteContratado]
    ON [dbo].[OfertasSQL]([ImporteContratado] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OfertasSQL_Reparto_2]
    ON [dbo].[OfertasSQL]([Reparto] ASC)
    INCLUDE([CodCentro], [CodOferta], [DescripcionOferta], [CodCliente], [FAdjudicacion], [ImporteContratado]);


GO
CREATE NONCLUSTERED INDEX [IX_OfertasSQL_SP_Contratacion]
    ON [dbo].[OfertasSQL]([AñoAdjudicacion] ASC, [FAdjudicacion] ASC, [Reparto] ASC)
    INCLUDE([CodCentro], [CodProv], [CodCliente], [CodOferta], [ImporteContratado]);


GO
CREATE NONCLUSTERED INDEX [IX_OfertasSQL_CodProv]
    ON [dbo].[OfertasSQL]([CodProv] ASC)
    INCLUDE([CodCentro], [CodOferta], [CodCliente], [FAdjudicacion], [AñoAdjudicacion], [ImporteContratado], [Reparto]);


GO
CREATE NONCLUSTERED INDEX [IX_OfertasSQL_Universal_Reporting_v3]
    ON [dbo].[OfertasSQL]([AñoAdjudicacion] ASC, [Reparto] ASC, [CodCentro] ASC)
    INCLUDE([CodProv], [CodCliente], [CodOferta], [ImporteContratado], [FAdjudicacion]) WITH (FILLFACTOR = 90);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[OfertasSQL] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[OfertasSQL] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[OfertasSQL] TO [partnertec]
    AS [dbo];

