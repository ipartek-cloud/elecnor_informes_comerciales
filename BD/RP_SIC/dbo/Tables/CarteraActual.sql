CREATE TABLE [dbo].[CarteraActual] (
    [idCarteraActual]                 INT           IDENTITY (1, 1) NOT NULL,
    [Año]                             INT           NOT NULL,
    [Concepto]                        VARCHAR (100) NOT NULL,
    [ImporteInicial]                  FLOAT (53)    CONSTRAINT [DF_Table_1_ImporteCarteraInicioAño] DEFAULT ((0)) NOT NULL,
    [Mes]                             VARCHAR (50)  NOT NULL,
    [ImporteActual]                   FLOAT (53)    CONSTRAINT [DF_Table_1_ImporteActual] DEFAULT ((0)) NOT NULL,
    [PorcentajeIncrementoAñoAnterior] FLOAT (53)    CONSTRAINT [DF_CarteraActual_PorcentajeIncrementoAñoAnterior] DEFAULT ((0)) NOT NULL,
    [SumarCartera]                    BIT           CONSTRAINT [DF_CarteraActual_SumarCartera] DEFAULT ((1)) NULL,
    [CarteraAñoAnterior]              FLOAT (53)    CONSTRAINT [DF_CarteraActual_ImporteActual1] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CarteraActual] PRIMARY KEY CLUSTERED ([idCarteraActual] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Año]
    ON [dbo].[CarteraActual]([Año] ASC);

