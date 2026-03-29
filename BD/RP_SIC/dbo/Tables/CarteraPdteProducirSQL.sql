CREATE TABLE [dbo].[CarteraPdteProducirSQL] (
    [idCarteraProduccion] INT         IDENTITY (1, 1) NOT NULL,
    [Año]                 INT         NOT NULL,
    [Mes]                 INT         NOT NULL,
    [CodCentro]           VARCHAR (3) NULL,
    [Importe]             FLOAT (53)  CONSTRAINT [DF_CarteraPdteProducirSQL_Importe] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CarteraPdteProducirSQL] PRIMARY KEY CLUSTERED ([idCarteraProduccion] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_CarteraPdteProducirSQL]
    ON [dbo].[CarteraPdteProducirSQL]([Año] ASC, [Mes] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CarteraPdteProducirSQL_1]
    ON [dbo].[CarteraPdteProducirSQL]([CodCentro] ASC);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[CarteraPdteProducirSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CarteraPdteProducirSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[CarteraPdteProducirSQL] TO [USRGPROD]
    AS [dbo];

