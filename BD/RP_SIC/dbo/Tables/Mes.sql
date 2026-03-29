CREATE TABLE [dbo].[Mes] (
    [Mes]                  INT           NOT NULL,
    [Nombre_Mes]           NVARCHAR (50) NULL,
    [Nombre_Mes_Abreviado] NVARCHAR (50) NULL,
    [Cod_Trimestre]        INT           NULL,
    CONSTRAINT [PK_Mes] PRIMARY KEY CLUSTERED ([Mes] ASC)
);

