CREATE TABLE [dbo].[ObrasOtrasSQL] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [CDOFT]      VARCHAR (10)    NULL,
    [CTR]        VARCHAR (3)     NOT NULL,
    [OBRA]       VARCHAR (3)     NOT NULL,
    [OBRAL]      VARCHAR (2)     NOT NULL,
    [DSOBR]      VARCHAR (50)    NULL,
    [FAPERTURA]  VARCHAR (5)     NULL,
    [FCIERRE]    VARCHAR (5)     NULL,
    [SOP]        NUMERIC (13, 2) CONSTRAINT [DF_ObrasOtrasSQL_SOP] DEFAULT ((0)) NULL,
    [SOF]        NUMERIC (13, 2) CONSTRAINT [DF_ObrasOtrasSQL_ObraFacturadaOrigen] DEFAULT ((0)) NULL,
    [SOL]        NUMERIC (13, 2) CONSTRAINT [DF_ObrasOtrasSQL_ObraLiquidadaOrigen] DEFAULT ((0)) NULL,
    [TipoOferta] VARCHAR (1)     NULL,
    CONSTRAINT [PK_ObrasOtrasSQL] PRIMARY KEY CLUSTERED ([id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_ObrasOtrasSQL_CodigoCentro]
    ON [dbo].[ObrasOtrasSQL]([CTR] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ObrasOtrasSQL_CodigoObra]
    ON [dbo].[ObrasOtrasSQL]([OBRA] ASC, [OBRAL] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ObrasOtrasSQL_CodigoOferta]
    ON [dbo].[ObrasOtrasSQL]([CDOFT] ASC);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ObrasOtrasSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ObrasOtrasSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ObrasOtrasSQL] TO [USRGPROD]
    AS [dbo];

