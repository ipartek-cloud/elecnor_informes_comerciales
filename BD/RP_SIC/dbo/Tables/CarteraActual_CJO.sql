CREATE TABLE [dbo].[CarteraActual_CJO] (
    [idCarteraActual]                 INT           IDENTITY (1, 1) NOT NULL,
    [Año]                             INT           NOT NULL,
    [Mes]                             INT           NOT NULL,
    [Concepto]                        VARCHAR (100) NOT NULL,
    [ImporteInicial]                  FLOAT (53)    CONSTRAINT [DF_CarteraActual_CJO_ImporteInicial] DEFAULT ((0)) NOT NULL,
    [ImporteActual]                   FLOAT (53)    CONSTRAINT [DF_CarteraActual_CJO_ImporteActual] DEFAULT ((0)) NOT NULL,
    [PorcentajeIncrementoAñoAnterior] FLOAT (53)    CONSTRAINT [DF_CarteraActual_CJO_PorcentajeIncrementoAñoAnterior] DEFAULT ((0)) NOT NULL,
    [SumarCartera]                    BIT           CONSTRAINT [DF_CarteraActual_CJO_SumarCartera] DEFAULT ((1)) NULL,
    [CarteraAñoAnterior]              FLOAT (53)    CONSTRAINT [DF_CarteraActual_CJO_CarteraAñoAnterior] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CarteraActual_CJO] PRIMARY KEY CLUSTERED ([idCarteraActual] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Año_Mes]
    ON [dbo].[CarteraActual_CJO]([Año] ASC, [Mes] ASC);

