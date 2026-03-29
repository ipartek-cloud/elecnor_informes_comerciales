CREATE TABLE [dbo].[WEB_ContratacionUsuarioCentro_TMP] (
    [id]                                    INT          IDENTITY (1, 1) NOT NULL,
    [Usuario]                               VARCHAR (50) NOT NULL,
    [CodCentro]                             VARCHAR (3)  NULL,
    [ImporteContratado]                     FLOAT (53)   CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_TMP_ImporteContratado] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumulado]            FLOAT (53)   CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_TMP_ImporteContratadoAcumulado] DEFAULT ((0)) NULL,
    [ImporteContratadoMesAnterior]          FLOAT (53)   CONSTRAINT [DF_Table_1_ImporteContratado1] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoMesAnterior] FLOAT (53)   CONSTRAINT [DF_Table_1_ImporteContratadoAcumulado1] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] FLOAT (53)   CONSTRAINT [DF_WEB_ContratacionUsuarioCentro_TMP_ImporteContratadoAcumuladoAñoAnterior] DEFAULT ((0)) NULL,
    [Tipo]                                  INT          NULL,
    CONSTRAINT [PK_WEB_ContratacionUsuarioCentro_TMP] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_ContratacionUsuarioCentro_TMP_CodCentro]
    ON [dbo].[WEB_ContratacionUsuarioCentro_TMP]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_ContratacionUsuarioCentro_TMP_Usuario]
    ON [dbo].[WEB_ContratacionUsuarioCentro_TMP]([Usuario] ASC);

