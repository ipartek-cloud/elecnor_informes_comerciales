CREATE TABLE [dbo].[RPI_Area_Pais] (
    [idArea_Pais] INT           IDENTITY (1, 1) NOT NULL,
    [Area]        VARCHAR (100) NULL,
    [CDPRO]       VARCHAR (2)   NULL,
    [Pais]        VARCHAR (100) NOT NULL,
    [Activo]      BIT           CONSTRAINT [DF_RPI_Area_Pais_Activo] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_idArea_Pais] PRIMARY KEY CLUSTERED ([idArea_Pais] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Area]
    ON [dbo].[RPI_Area_Pais]([Area] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Pais]
    ON [dbo].[RPI_Area_Pais]([Pais] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Activo]
    ON [dbo].[RPI_Area_Pais]([Activo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RPI_CDPROD]
    ON [dbo].[RPI_Area_Pais]([CDPRO] ASC);

