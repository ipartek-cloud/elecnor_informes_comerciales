CREATE TABLE [dbo].[ObjetivosDelegacionSQL] (
    [Año]           INT          NOT NULL,
    [Mercado]       VARCHAR (50) NOT NULL,
    [CodDelegacion] VARCHAR (3)  NULL,
    [Importe]       FLOAT (53)   CONSTRAINT [DF_ObjetivosDelegacionSQL_Importe] DEFAULT ((0)) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [PK_ObjetivosDelegacionSQL]
    ON [dbo].[ObjetivosDelegacionSQL]([Año] ASC, [Mercado] ASC, [CodDelegacion] ASC);

