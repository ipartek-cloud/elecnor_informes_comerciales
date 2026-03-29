CREATE TABLE [dbo].[Cart_DiferidaOfertasContratosSQL] (
    [Contrato]       VARCHAR (255) NOT NULL,
    [Cliente]        VARCHAR (255) NOT NULL,
    [Zona]           VARCHAR (255) NULL,
    [Año]            INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_Año] DEFAULT ((2015)) NULL,
    [Centro]         NUMERIC (3)   NULL,
    [CodOferta]      VARCHAR (10)  NULL,
    [CartInicio]     INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_CartInicio] DEFAULT ((0)) NULL,
    [MontoAnual]     INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_MontoAnual] DEFAULT ((0)) NULL,
    [NTrimestres]    INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_NTrimestres] DEFAULT ((0)) NULL,
    [MontoTrimestre] INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_MontoTrimestre] DEFAULT ((0)) NULL,
    [Previsto1]      INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_Previsto1] DEFAULT ((0)) NULL,
    [Previsto2]      INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_Previsto2] DEFAULT ((0)) NULL,
    [Previsto3]      INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_Previsto3] DEFAULT ((0)) NULL,
    [Previsto4]      INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_Previsto4] DEFAULT ((0)) NULL,
    [Meses]          INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_Meses] DEFAULT ((0)) NULL,
    [Vigente]        BIT           CONSTRAINT [DF_Cart_DiferidaOfertasContratosSQL_Vigente] DEFAULT ((1)) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Contrato_Cliente]
    ON [dbo].[Cart_DiferidaOfertasContratosSQL]([Contrato] ASC, [Cliente] ASC);

