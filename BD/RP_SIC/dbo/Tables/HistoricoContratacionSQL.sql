CREATE TABLE [dbo].[HistoricoContratacionSQL] (
    [Año]     INT         NOT NULL,
    [CodProv] VARCHAR (2) NOT NULL,
    [Importe] NUMERIC (9) CONSTRAINT [DF_HistoricoContratacionSQL_Importe] DEFAULT ((0)) NOT NULL,
    [Orden]   INT         NULL,
    CONSTRAINT [PK_HistoricoContratacionSQL] PRIMARY KEY CLUSTERED ([Año] ASC, [CodProv] ASC)
);

