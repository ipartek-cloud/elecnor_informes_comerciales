CREATE TABLE [dbo].[Cart_DiferidaContratosSQL_2019_Inicio] (
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
    [Vigente]              BIT           NULL,
    [Zona]                 VARCHAR (250) NULL
);

