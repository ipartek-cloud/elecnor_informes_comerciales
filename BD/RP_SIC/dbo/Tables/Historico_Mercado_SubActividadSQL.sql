CREATE TABLE [dbo].[Historico_Mercado_SubActividadSQL] (
    [Año]        INT           NOT NULL,
    [Mercado]    VARCHAR (100) NOT NULL,
    [Agrupacion] VARCHAR (100) NOT NULL,
    [CodAct2]    VARCHAR (2)   NOT NULL,
    [Importe]    FLOAT (53)    CONSTRAINT [DF_Historico_Mercado_SubActividadSQL_Importe] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Historico_Mercado_SubActividadSQL_1] PRIMARY KEY CLUSTERED ([Año] ASC, [Mercado] ASC, [Agrupacion] ASC, [CodAct2] ASC)
);

