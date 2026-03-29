CREATE TABLE [dbo].[CentroCarteraAjustadaSQL] (
    [CodCentro]   VARCHAR (3) NULL,
    [FechaAjuste] DATETIME    NULL,
    [Ajustado]    BIT         CONSTRAINT [DF_CentroCarteraAjustadoSQL_Ajustado] DEFAULT ((0)) NULL
);

