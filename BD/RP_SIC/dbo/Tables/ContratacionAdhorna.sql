CREATE TABLE [dbo].[ContratacionAdhorna] (
    [Año]                 INT          NOT NULL,
    [Mes]                 INT          NOT NULL,
    [Mercado]             VARCHAR (50) NOT NULL,
    [ObjetivoAnual]       INT          NOT NULL,
    [ContratacionMensual] MONEY        CONSTRAINT [DF_ContratacionAdhorna_ContratacionMensual] DEFAULT ((0)) NOT NULL,
    [Nombre]              VARCHAR (50) CONSTRAINT [DF_ContratacionAdhorna_Nombre] DEFAULT ('Adhorna') NOT NULL,
    CONSTRAINT [PK_ContratacionAdhorna] PRIMARY KEY CLUSTERED ([Año] ASC, [Mes] ASC, [Mercado] ASC)
);

