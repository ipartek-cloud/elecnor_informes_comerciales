CREATE TABLE [dbo].[RestoOfertas] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [CodOferta] VARCHAR (10)  NULL,
    [CodCentro] VARCHAR (3)   NULL,
    [Cliente]   VARCHAR (255) NULL,
    [Gerencia]  VARCHAR (255) NULL,
    CONSTRAINT [PK_RestoOfertas_1] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CodOferta]
    ON [dbo].[RestoOfertas]([CodOferta] ASC);

