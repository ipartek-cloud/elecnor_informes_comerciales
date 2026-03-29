CREATE TABLE [dbo].[HistoricoContratacionGrupoSQL] (
    [idHistorico]      INT           IDENTITY (1, 1) NOT NULL,
    [Año]              INT           NOT NULL,
    [Mes]              INT           NOT NULL,
    [CodCentro]        VARCHAR (3)   NULL,
    [CodOferta]        VARCHAR (10)  NULL,
    [CodAct1]          VARCHAR (2)   NOT NULL,
    [CodAct2]          VARCHAR (2)   NOT NULL,
    [Importe]          FLOAT (53)    CONSTRAINT [DF_HistoricoContratacionGrupoSQL_Importe] DEFAULT ((0)) NOT NULL,
    [Mercado]          VARCHAR (15)  NOT NULL,
    [Observaciones]    VARCHAR (200) NULL,
    [CodCentro_Origen] VARCHAR (3)   NULL,
    CONSTRAINT [PK_HistoricoContratacionGrupoSQL_1] PRIMARY KEY CLUSTERED ([idHistorico] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_HistoricoContratacionGrupoSQL]
    ON [dbo].[HistoricoContratacionGrupoSQL]([CodAct1] ASC, [CodAct2] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_HistoricoContratacionGrupoSQL_1]
    ON [dbo].[HistoricoContratacionGrupoSQL]([Mercado] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_HistoricoContratacionGrupoSQL_2]
    ON [dbo].[HistoricoContratacionGrupoSQL]([Año] ASC, [Mes] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_HistoricoContratacionGrupoSQL_3]
    ON [dbo].[HistoricoContratacionGrupoSQL]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_HistoricoContratacionGrupoSQL_CodOferta]
    ON [dbo].[HistoricoContratacionGrupoSQL]([CodOferta] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_HistoricoContratacionGrupoSQL_Año_Mes]
    ON [dbo].[HistoricoContratacionGrupoSQL]([Año] ASC, [Mes] ASC)
    INCLUDE([CodCentro], [Importe]);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[HistoricoContratacionGrupoSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[HistoricoContratacionGrupoSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[HistoricoContratacionGrupoSQL] TO [UsuDataLakeCIC]
    AS [dbo];

