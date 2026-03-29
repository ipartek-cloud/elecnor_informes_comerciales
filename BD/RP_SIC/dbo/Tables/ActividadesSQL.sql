CREATE TABLE [dbo].[ActividadesSQL] (
    [CDAC1]      VARCHAR (2)   NOT NULL,
    [CDAC2]      VARCHAR (2)   NOT NULL,
    [DSACT]      VARCHAR (100) NOT NULL,
    [Orden]      INT           NOT NULL,
    [Agrupacion] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Actividades] PRIMARY KEY CLUSTERED ([CDAC1] ASC, [CDAC2] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_Orden]
    ON [dbo].[ActividadesSQL]([Orden] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Agrupacion]
    ON [dbo].[ActividadesSQL]([Agrupacion] ASC);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ActividadesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ActividadesSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT VIEW CHANGE TRACKING
    ON OBJECT::[dbo].[ActividadesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ActividadesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ActividadesSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ActividadesSQL] TO [USRGPROD]
    AS [dbo];

