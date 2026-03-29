CREATE TABLE [dbo].[WEB_ContratacionActividadesUsuarioCentro_TMP] (
    [id]                                    INT          IDENTITY (1, 1) NOT NULL,
    [Usuario]                               VARCHAR (50) NOT NULL,
    [CodCentro]                             VARCHAR (3)  NULL,
    [CDAC1]                                 VARCHAR (2)  NOT NULL,
    [CDAC2]                                 VARCHAR (2)  NOT NULL,
    [ImporteContratado]                     FLOAT (53)   CONSTRAINT [DF_WEB_ContratacionActividadesUsuarioCentro_TMP_ImporteContratado] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumulado]            FLOAT (53)   CONSTRAINT [DF_WEB_ContratacionActividadesUsuarioCentro_TMP_ImporteContratadoAcumulado] DEFAULT ((0)) NULL,
    [ImporteContratadoMesAnterior]          FLOAT (53)   CONSTRAINT [DF_WEB_ContratacionActividadesUsuarioCentro_TMP_ImporteContratadoMesAnterior] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoMesAnterior] FLOAT (53)   CONSTRAINT [DF_WEB_ContratacionActividadesUsuarioCentro_TMP_ImporteContratadoAcumuladoMesAnterior] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] FLOAT (53)   CONSTRAINT [DF_WEB_ContratacionActividadesUsuarioCentro_TMP_ImporteContratadoAcumuladoAñoAnterior] DEFAULT ((0)) NULL,
    [Tipo]                                  INT          NULL,
    CONSTRAINT [PK_WEB_ContratacionActividadesUsuarioCentro_TMP] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_ContratacionActividadesUsuarioCentro_TMP_Usuario]
    ON [dbo].[WEB_ContratacionActividadesUsuarioCentro_TMP]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_ContratacionActividadesUsuarioCentro_TMP_CodCentro]
    ON [dbo].[WEB_ContratacionActividadesUsuarioCentro_TMP]([CodCentro] ASC);

