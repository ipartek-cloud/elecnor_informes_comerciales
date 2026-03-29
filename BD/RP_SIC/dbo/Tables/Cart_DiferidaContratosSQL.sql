CREATE TABLE [dbo].[Cart_DiferidaContratosSQL] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [Contrato]             VARCHAR (255) NOT NULL,
    [Cliente]              VARCHAR (255) NOT NULL,
    [CodigoContratoClient] VARCHAR (255) NULL,
    [Gerencia]             VARCHAR (100) NULL,
    [Prorrogable]          VARCHAR (50)  NULL,
    [Tipo]                 VARCHAR (1)   NULL,
    [Mercado]              VARCHAR (1)   NULL,
    [FInicio]              DATETIME      NULL,
    [FFinal]               DATETIME      NULL,
    [FFinalEfectiva]       DATETIME      NULL,
    [Vigente]              BIT           CONSTRAINT [DF_Cart_DiferidaContratosSQL_Vigentes] DEFAULT ((1)) NULL,
    [Zona]                 VARCHAR (250) NULL,
    CONSTRAINT [PK_Cart_DiferidaContratosSQL] PRIMARY KEY CLUSTERED ([ID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_Gerencia]
    ON [dbo].[Cart_DiferidaContratosSQL]([Gerencia] ASC);


GO
GRANT SELECT
    ON OBJECT::[dbo].[Cart_DiferidaContratosSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Cart_DiferidaContratosSQL] TO [USRGPROD]
    AS [dbo];

