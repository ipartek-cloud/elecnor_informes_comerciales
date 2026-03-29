CREATE TABLE [dbo].[WEB_OfertacionUsuarioCentro_TMP] (
    [id]                      INT          IDENTITY (1, 1) NOT NULL,
    [Usuario]                 VARCHAR (50) NOT NULL,
    [CodCentro]               VARCHAR (3)  NULL,
    [Cantidad_Abiertas]       INT          CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_ImporteContratado] DEFAULT ((0)) NOT NULL,
    [Monto_Abiertas]          NUMERIC (18) CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Monto] DEFAULT ((0)) NOT NULL,
    [Cantidad_PdtesPresentar] INT          CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Cantidad_Abiertas1] DEFAULT ((0)) NOT NULL,
    [Monto_PdtesPresentar]    NUMERIC (18) CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Monto_Abiertas1] DEFAULT ((0)) NOT NULL,
    [Cantidad_PdtesDecidir]   INT          CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Cantidad_PdtesPresentar1] DEFAULT ((0)) NOT NULL,
    [Monto_PdtesDecidir]      NUMERIC (18) CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Monto_PdtesPresentar1] DEFAULT ((0)) NOT NULL,
    [Cantidad_Denegadas]      INT          CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Cantidad_PdtesDecidir1] DEFAULT ((0)) NOT NULL,
    [Monto_Denegadas]         NUMERIC (18) CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Monto_PdtesDecidir1] DEFAULT ((0)) NOT NULL,
    [Cantidad_Adjudicadas]    INT          CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Cantidad_Denegadas1] DEFAULT ((0)) NOT NULL,
    [Monto_Adjudicadas]       NUMERIC (18) CONSTRAINT [DF_WEB_OfertacionUsuarioCentro_TMP_Monto_Denegadas1] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_WEB_OfertacionUsuarioCentro_TMP] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro_TMP_Usuario]
    ON [dbo].[WEB_OfertacionUsuarioCentro_TMP]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_OfertacionUsuarioCentro_TMP_CodCentro]
    ON [dbo].[WEB_OfertacionUsuarioCentro_TMP]([CodCentro] ASC);

