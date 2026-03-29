CREATE TABLE [dbo].[ObrasHistoricasSQL_2018] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [CDOFT]     NUMERIC (10)    NOT NULL,
    [CTR]       VARCHAR (3)     NOT NULL,
    [OBRA]      VARCHAR (3)     NOT NULL,
    [OBRAL]     VARCHAR (2)     NOT NULL,
    [DSOBR]     VARCHAR (50)    NULL,
    [FAPERTURA] VARCHAR (5)     NULL,
    [FCIERRE]   VARCHAR (5)     NULL,
    [SOP]       NUMERIC (13, 2) CONSTRAINT [DF_ObrasHistoricasSQL_2018_SOP] DEFAULT ((0)) NULL,
    [SOF]       NUMERIC (13, 2) CONSTRAINT [DF_ObrasHistoricasSQL_2018_SOF] DEFAULT ((0)) NULL,
    [SOL]       NUMERIC (13, 2) CONSTRAINT [DF_ObrasHistoricasSQL_2018_SOL] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ObrasHistoricasSQL_2018] PRIMARY KEY CLUSTERED ([id] ASC)
);

