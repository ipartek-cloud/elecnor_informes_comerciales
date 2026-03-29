CREATE TABLE [dbo].[Enlaces_T] (
    [id]      INT          IDENTITY (1, 1) NOT NULL,
    [Usuario] VARCHAR (50) NOT NULL,
    [CTRO]    CHAR (3)     NOT NULL,
    [OBRA]    CHAR (3)     NOT NULL,
    [OBRAL]   CHAR (2)     NOT NULL,
    [CDOFT]   NUMERIC (10) NOT NULL,
    [AAMMA]   NUMERIC (4)  NULL,
    [AAMMC]   NUMERIC (4)  NULL,
    CONSTRAINT [PK_id] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Usuario]
    ON [dbo].[Enlaces_T]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CTRO_OBRA_OBRAL]
    ON [dbo].[Enlaces_T]([CTRO] ASC, [OBRA] ASC, [OBRAL] ASC);

