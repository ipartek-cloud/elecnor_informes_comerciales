CREATE TABLE [dbo].[OfertasSQL_Ajustes] (
    [idOfertasSQL]      INT          IDENTITY (1, 1) NOT NULL,
    [CodCentro]         VARCHAR (3)  NULL,
    [CodOferta]         VARCHAR (10) NULL,
    [NumRegularizacion] INT          NULL,
    [FAlta]             DATETIME     NULL,
    [DescripcionOferta] VARCHAR (50) NULL,
    [CodCliente]        VARCHAR (8)  NULL,
    [CodProv]           VARCHAR (2)  NULL,
    [CodAct1]           VARCHAR (2)  NULL,
    [CodAct2]           VARCHAR (2)  NULL,
    [FAdjudicacion]     DATETIME     NULL,
    [AñoAdjudicacion]   INT          NULL,
    [Importe]           FLOAT (53)   NULL,
    CONSTRAINT [PK_OfertasSQL_Ajustes] PRIMARY KEY CLUSTERED ([idOfertasSQL] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_OfertasSQL_Ajustes_SP_Contratacion]
    ON [dbo].[OfertasSQL_Ajustes]([AñoAdjudicacion] ASC, [FAdjudicacion] ASC)
    INCLUDE([CodProv], [CodCliente], [CodOferta], [Importe]);

