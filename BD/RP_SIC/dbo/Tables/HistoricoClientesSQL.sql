CREATE TABLE [dbo].[HistoricoClientesSQL] (
    [idRanking]    INT          IDENTITY (1, 1) NOT NULL,
    [Mercado]      VARCHAR (50) NOT NULL,
    [Año]          INT          NOT NULL,
    [Mes]          INT          NOT NULL,
    [Cliente]      VARCHAR (75) NULL,
    [ClientePadre] VARCHAR (75) CONSTRAINT [DF_rptRankingContratacion_Agrupado] DEFAULT ((0)) NULL,
    [Contratacion] FLOAT (53)   CONSTRAINT [DF_rptRankingContratacion_Contratacion] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_rptRankingContratacionHistoricoSQL] PRIMARY KEY CLUSTERED ([idRanking] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_rptRankingContratacionHistoricoSQL]
    ON [dbo].[HistoricoClientesSQL]([Mercado] ASC, [Año] ASC, [Mes] ASC);

