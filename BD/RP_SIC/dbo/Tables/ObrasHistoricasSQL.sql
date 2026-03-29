CREATE TABLE [dbo].[ObrasHistoricasSQL] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [CDOFT]     VARCHAR (20)    NOT NULL,
    [CTR]       VARCHAR (3)     NOT NULL,
    [OBRA]      VARCHAR (3)     NOT NULL,
    [OBRAL]     VARCHAR (2)     NOT NULL,
    [DSOBR]     VARCHAR (50)    NULL,
    [FAPERTURA] VARCHAR (5)     NULL,
    [FCIERRE]   VARCHAR (5)     NULL,
    [SOP]       NUMERIC (13, 2) CONSTRAINT [DF_ObrasHistoricasSQL_SOP] DEFAULT ((0)) NULL,
    [SOF]       NUMERIC (13, 2) CONSTRAINT [DF_ObrasHistoricasSQL_ObraFacturadaOrigen] DEFAULT ((0)) NULL,
    [SOL]       NUMERIC (13, 2) CONSTRAINT [DF_ObrasHistoricasSQL_ObraLiquidadaOrigen] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ObrasHistoricasSQL] PRIMARY KEY CLUSTERED ([id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_CodigoOferta]
    ON [dbo].[ObrasHistoricasSQL]([CDOFT] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodigoObra]
    ON [dbo].[ObrasHistoricasSQL]([OBRA] ASC, [OBRAL] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodigoCentro]
    ON [dbo].[ObrasHistoricasSQL]([CTR] ASC);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ObrasHistoricasSQL] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ObrasHistoricasSQL] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ObrasHistoricasSQL] TO [partnertec]
    AS [dbo];

