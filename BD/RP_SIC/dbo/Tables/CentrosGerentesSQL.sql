CREATE TABLE [dbo].[CentrosGerentesSQL] (
    [Año]              INT           NOT NULL,
    [CodCentro]        VARCHAR (3)   NOT NULL,
    [NombreGerente]    VARCHAR (100) NOT NULL,
    [Orden]            NCHAR (10)    NULL,
    [Mercado]          VARCHAR (1)   NULL,
    [Marca]            BIT           CONSTRAINT [DF_CentrosGerentesSQL_Ajuste] DEFAULT ((0)) NULL,
    [SumarizaGerentes] VARCHAR (150) NULL,
    [Agrupacion1]      VARCHAR (100) NULL,
    [Agrupacion2]      VARCHAR (100) NULL,
    CONSTRAINT [PK_CentrosGerentesSQL] PRIMARY KEY CLUSTERED ([Año] ASC, [CodCentro] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_Orden]
    ON [dbo].[CentrosGerentesSQL]([Orden] ASC);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [partnertec]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [LUIS OJEDA]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [LUIS OJEDA]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[CentrosGerentesSQL] TO [LUIS OJEDA]
    AS [dbo];

