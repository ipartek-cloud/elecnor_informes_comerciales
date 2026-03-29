CREATE TABLE [dbo].[ClientesSQL_MostrarContratacion_AñoAnterior] (
    [Año]         INT            NOT NULL,
    [NomAgrupado] NVARCHAR (255) NOT NULL,
    CONSTRAINT [PK_ClientesSQL_MostrarContratacion_AñoAnterior_1] PRIMARY KEY CLUSTERED ([Año] ASC, [NomAgrupado] ASC)
);

