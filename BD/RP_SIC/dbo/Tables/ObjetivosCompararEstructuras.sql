CREATE TABLE [dbo].[ObjetivosCompararEstructuras] (
    [Año]             FLOAT (53) NOT NULL,
    [CodEstrucutura]  INT        NOT NULL,
    [RealAñoAnterior] FLOAT (53) NULL,
    CONSTRAINT [PK_ObjetivosComparativaEstrucuturas] PRIMARY KEY CLUSTERED ([Año] ASC, [CodEstrucutura] ASC)
);

