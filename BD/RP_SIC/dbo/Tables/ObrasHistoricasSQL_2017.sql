CREATE TABLE [dbo].[ObrasHistoricasSQL_2017] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [CDOFT]     NUMERIC (10)    NOT NULL,
    [CTR]       VARCHAR (3)     NOT NULL,
    [OBRA]      VARCHAR (3)     NOT NULL,
    [OBRAL]     VARCHAR (2)     NOT NULL,
    [DSOBR]     VARCHAR (50)    NULL,
    [FAPERTURA] VARCHAR (5)     NULL,
    [FCIERRE]   VARCHAR (5)     NULL,
    [SOP]       NUMERIC (13, 2) NULL,
    [SOF]       NUMERIC (13, 2) NULL,
    [SOL]       NUMERIC (13, 2) NULL
);

