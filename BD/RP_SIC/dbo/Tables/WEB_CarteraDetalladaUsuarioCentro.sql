CREATE TABLE [dbo].[WEB_CarteraDetalladaUsuarioCentro] (
    [id]                           INT           IDENTITY (1, 1) NOT NULL,
    [Usuario]                      VARCHAR (50)  NOT NULL,
    [Tipo]                         VARCHAR (1)   NOT NULL,
    [TipoNombre]                   AS            ([dbo].[fnCarteraTipoDescripcion]([Tipo])),
    [CodOferta]                    VARCHAR (10)  NULL,
    [ContratoMarco]                VARCHAR (1)   NULL,
    [DescripcionOferta]            VARCHAR (100) NULL,
    [FAdjudicacion]                VARCHAR (10)  NULL,
    [ImporteContratado]            FLOAT (53)    CONSTRAINT [DF_WEB_CarteraDetalladaUsuarioCentro_ImporteContratado] DEFAULT ((0)) NULL,
    [Obra]                         VARCHAR (3)   NULL,
    [ObraL]                        VARCHAR (2)   NULL,
    [NombreObra]                   VARCHAR (100) NULL,
    [FApertura]                    VARCHAR (5)   NULL,
    [FCierre]                      VARCHAR (5)   NULL,
    [ImporteProduccion]            FLOAT (53)    CONSTRAINT [DF_Table_1_ImporteContratado1_2] DEFAULT ((0)) NULL,
    [ImporteFactura]               FLOAT (53)    CONSTRAINT [DF_Table_1_ImporteContratado1_3] DEFAULT ((0)) NULL,
    [ImporteFot]                   FLOAT (53)    CONSTRAINT [DF_Table_1_ImporteContratado1_4] DEFAULT ((0)) NULL,
    [Est]                          VARCHAR (1)   NULL,
    [ImporteCarteraAgrupacion]     FLOAT (53)    CONSTRAINT [DF_WEB_CarteraDetalladaUsuarioCentro_ImporteCarteraAgrupacionNEW] DEFAULT ((0)) NULL,
    [ImporteCarteraAgrupacion_OLD] AS            ([dbo].[fnImporteCartera_CarteraDetallada]([Usuario],[Tipo])),
    [TotalObrasOferta]             INT           CONSTRAINT [DF_WEB_CarteraDetalladaUsuarioCentro_TotalObrasOferta] DEFAULT ((0)) NULL,
    [CodCliente]                   VARCHAR (10)  NULL,
    [NombreCliente]                VARCHAR (100) NULL,
    CONSTRAINT [PK_WEB_CarteraDetalladaUsuarioCentro] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_Usuario]
    ON [dbo].[WEB_CarteraDetalladaUsuarioCentro]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CodOferta]
    ON [dbo].[WEB_CarteraDetalladaUsuarioCentro]([CodOferta] ASC, [Obra] ASC, [ObraL] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CodCliente]
    ON [dbo].[WEB_CarteraDetalladaUsuarioCentro]([CodCliente] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_Usuario_CodOferta]
    ON [dbo].[WEB_CarteraDetalladaUsuarioCentro]([Usuario] ASC, [CodOferta] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDetalladaUsuarioCentro_id_CodOferta_Obra_Obral]
    ON [dbo].[WEB_CarteraDetalladaUsuarioCentro]([Usuario] ASC)
    INCLUDE([id], [CodOferta], [Obra], [ObraL]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDetalladaUsuarioCentro_Usuario]
    ON [dbo].[WEB_CarteraDetalladaUsuarioCentro]([Usuario] ASC)
    INCLUDE([CodOferta], [ImporteContratado]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDetalladaUsuarioCentro_Usuario2]
    ON [dbo].[WEB_CarteraDetalladaUsuarioCentro]([Usuario] ASC)
    INCLUDE([Tipo], [CodOferta], [ImporteContratado], [ImporteProduccion], [TotalObrasOferta]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraDetalladaUsuarioCentro_Usuario3]
    ON [dbo].[WEB_CarteraDetalladaUsuarioCentro]([Usuario] ASC)
    INCLUDE([id], [CodOferta], [Obra], [ObraL], [ImporteProduccion]);

