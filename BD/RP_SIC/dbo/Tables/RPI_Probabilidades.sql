CREATE TABLE [dbo].[RPI_Probabilidades] (
    [idProbabilidad]     INT          IDENTITY (1, 1) NOT NULL,
    [NombreProbabilidad] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_RPI_Probabilidades] PRIMARY KEY CLUSTERED ([idProbabilidad] ASC)
);

