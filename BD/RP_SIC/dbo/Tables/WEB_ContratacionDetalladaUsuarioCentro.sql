CREATE TABLE [dbo].[WEB_ContratacionDetalladaUsuarioCentro] (
    [id]                  INT           IDENTITY (1, 1) NOT NULL,
    [Usuario]             VARCHAR (50)  NOT NULL,
    [CodCentro]           VARCHAR (3)   NULL,
    [CodOferta]           VARCHAR (10)  NULL,
    [FAdjudicacion]       DATETIME      NOT NULL,
    [DescripcionOferta]   VARCHAR (100) NOT NULL,
    [Regularizacion]      INT           CONSTRAINT [DF_WEB_ContratacionDetalladaUsuarioCentro_Regularizacion] DEFAULT ((0)) NOT NULL,
    [CausaRegularizacion] VARCHAR (100) CONSTRAINT [DF_WEB_ContratacionDetalladaUsuarioCentro_CausaRegularizacion] DEFAULT ('') NOT NULL,
    [ImporteContratado]   FLOAT (53)    NOT NULL,
    [Localidad]           VARCHAR (50)  NOT NULL,
    [CodProv]             VARCHAR (2)   NOT NULL,
    [CodCliente]          VARCHAR (8)   NOT NULL,
    [CodAct1]             VARCHAR (2)   NOT NULL,
    [CodAct2]             VARCHAR (2)   NOT NULL,
    [Tipo]                INT           NOT NULL,
    CONSTRAINT [PK_WEB_ContratacionDetalladaUsuarioCentro_1] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Usuario]
    ON [dbo].[WEB_ContratacionDetalladaUsuarioCentro]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodOfertaRegularizacion]
    ON [dbo].[WEB_ContratacionDetalladaUsuarioCentro]([CodOferta] ASC, [Regularizacion] ASC);

