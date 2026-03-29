CREATE TABLE [dbo].[Historico_Mercado_ActividadSQL] (
    [Año]        INT           NOT NULL,
    [Mercado]    VARCHAR (100) NOT NULL,
    [Agrupacion] VARCHAR (100) NOT NULL,
    [Importe]    FLOAT (53)    CONSTRAINT [DF_Historico_ImporteContratado_Mercado_Actividad_Importe] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Historico_Mercado_ActividadSQL] PRIMARY KEY CLUSTERED ([Año] ASC, [Mercado] ASC, [Agrupacion] ASC)
);

