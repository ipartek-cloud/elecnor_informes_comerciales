CREATE TABLE [dbo].[WEB_CarteraUsuarioCentro_TMP] (
    [id]              INT          IDENTITY (1, 1) NOT NULL,
    [Usuario]         VARCHAR (50) NOT NULL,
    [CodCentro]       VARCHAR (3)  NULL,
    [ImporteElecnor]  FLOAT (53)   CONSTRAINT [DF_WEB_CarteraUsuarioCentro_TMP_ImporteContratado] DEFAULT ((0)) NULL,
    [ImporteFilial]   FLOAT (53)   CONSTRAINT [DF_WEB_CarteraUsuarioCentro_TMP_ImporteContratadoAcumulado] DEFAULT ((0)) NULL,
    [ImporteUTE]      FLOAT (53)   CONSTRAINT [DF_Table_1_ImporteContratado11] DEFAULT ((0)) NULL,
    [ImporteSucursal] FLOAT (53)   CONSTRAINT [DF_Table_1_ImporteContratadoAcumulado11] DEFAULT ((0)) NULL,
    [Tipo]            INT          NULL,
    CONSTRAINT [PK_WEB_CarteraUsuarioCentro_TMP] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CodCentro]
    ON [dbo].[WEB_CarteraUsuarioCentro_TMP]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraUsuarioCentro_TMP_Usuario]
    ON [dbo].[WEB_CarteraUsuarioCentro_TMP]([Usuario] ASC)
    INCLUDE([CodCentro], [ImporteElecnor], [ImporteFilial], [ImporteUTE], [ImporteSucursal]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraUsuarioCentro_TMP_Usuario_Tipo]
    ON [dbo].[WEB_CarteraUsuarioCentro_TMP]([Usuario] ASC, [Tipo] ASC)
    INCLUDE([CodCentro]);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CarteraUsuarioCentro_TMP_Usuario_CodCentro]
    ON [dbo].[WEB_CarteraUsuarioCentro_TMP]([Usuario] ASC, [CodCentro] ASC)
    INCLUDE([ImporteElecnor], [ImporteFilial], [ImporteUTE], [ImporteSucursal]);

