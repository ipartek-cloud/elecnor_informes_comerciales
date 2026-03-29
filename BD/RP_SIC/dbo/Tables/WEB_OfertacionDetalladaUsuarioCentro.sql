CREATE TABLE [dbo].[WEB_OfertacionDetalladaUsuarioCentro] (
    [id]                  INT           IDENTITY (1, 1) NOT NULL,
    [Usuario]             VARCHAR (50)  NOT NULL,
    [CodCentro]           VARCHAR (3)   NULL,
    [CodOferta]           VARCHAR (10)  NULL,
    [FAlta]               DATETIME      NULL,
    [ImporteAlta]         FLOAT (53)    NULL,
    [FPresentacion]       DATETIME      NULL,
    [ImportePresentacion] FLOAT (53)    NULL,
    [FAdjudicacion]       DATETIME      NULL,
    [ImporteContratado]   FLOAT (53)    NULL,
    [Adjudicada]          VARCHAR (1)   NOT NULL,
    [CodResponsable]      VARCHAR (5)   NULL,
    [DescripcionOferta]   VARCHAR (100) NOT NULL,
    [Regularizacion]      INT           CONSTRAINT [DF_WEB_OfertacionDetalladaUsuarioCentro_Regularizacion] DEFAULT ((0)) NOT NULL,
    [CausaRegularizacion] VARCHAR (100) CONSTRAINT [DF_WEB_OfertacionDetalladaUsuarioCentro_CausaRegularizacion] DEFAULT ('') NOT NULL,
    [Localidad]           VARCHAR (50)  NOT NULL,
    [CodProv]             VARCHAR (2)   NOT NULL,
    [CodCliente]          VARCHAR (8)   NOT NULL,
    [CodAct1]             VARCHAR (2)   NOT NULL,
    [CodAct2]             VARCHAR (2)   NOT NULL,
    [Tipo]                INT           NOT NULL,
    CONSTRAINT [PK_WEB_OfertacionDetalladaUsuarioCentro] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionDetalladaUsuarioCentro]
    ON [dbo].[WEB_OfertacionDetalladaUsuarioCentro]([CodOferta] ASC, [Regularizacion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionDetalladaUsuarioCentro_1]
    ON [dbo].[WEB_OfertacionDetalladaUsuarioCentro]([Usuario] ASC);

