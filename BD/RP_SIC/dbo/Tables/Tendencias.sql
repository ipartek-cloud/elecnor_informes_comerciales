CREATE TABLE [dbo].[Tendencias] (
    [idTendencias]            INT         IDENTITY (1, 1) NOT NULL,
    [CodCentro]               VARCHAR (3) NULL,
    [Año]                     INT         NOT NULL,
    [Mes]                     INT         NOT NULL,
    [TendenciaCierre]         FLOAT (53)  CONSTRAINT [DF_Tendencias_Importe] DEFAULT ((0)) NULL,
    [ContratacionPdteImputar] FLOAT (53)  CONSTRAINT [DF_Tendencias_TendenciaCierre1] DEFAULT ((0)) NULL,
    [AsuntosPdtes]            FLOAT (53)  CONSTRAINT [DF_Tendencias_ContratacionPdteImputar1] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_idTendencias] PRIMARY KEY CLUSTERED ([idTendencias] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CodCentro_Año_Mes]
    ON [dbo].[Tendencias]([CodCentro] ASC, [Año] ASC, [Mes] ASC);

