CREATE TABLE [dbo].[ObrasOtrasSQL_Importacion] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [CDOFT]      VARCHAR (10)    NULL,
    [CTR]        VARCHAR (3)     NOT NULL,
    [OBRA]       VARCHAR (3)     NOT NULL,
    [OBRAL]      VARCHAR (2)     NOT NULL,
    [DSOBR]      VARCHAR (50)    NULL,
    [FAPERTURA]  VARCHAR (5)     NULL,
    [FCIERRE]    VARCHAR (5)     NULL,
    [SOP]        NUMERIC (13, 2) CONSTRAINT [DF_ObrasOtrasSQL_SOP2] DEFAULT ((0)) NULL,
    [SOF]        NUMERIC (13, 2) CONSTRAINT [DF_ObrasOtrasSQL_ObraFacturadaOrigen2] DEFAULT ((0)) NULL,
    [SOL]        NUMERIC (13, 2) CONSTRAINT [DF_ObrasOtrasSQL_ObraLiquidadaOrigen2] DEFAULT ((0)) NULL,
    [TipoOferta] VARCHAR (1)     NULL,
    [Acumular]   INT             CONSTRAINT [DF_ObrasOtrasSQL_Importacion_Acumular] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ObrasOtrasSQL_Importacion] PRIMARY KEY CLUSTERED ([id] ASC)
);

