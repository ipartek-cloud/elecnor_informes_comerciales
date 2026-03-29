CREATE TABLE [dbo].[ActividadesSQL_OLD] (
    [CDAC1]      VARCHAR (2)   NOT NULL,
    [CDAC2]      VARCHAR (2)   NOT NULL,
    [DSACT]      VARCHAR (100) NOT NULL,
    [Orden]      INT           NOT NULL,
    [Agrupacion] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Actividades_OLD] PRIMARY KEY CLUSTERED ([CDAC1] ASC, [CDAC2] ASC)
);

