CREATE TABLE [dbo].[ObjetivosActividadSQL] (
    [idObjetivosActividad] INT          IDENTITY (1, 1) NOT NULL,
    [Año]                  INT          NOT NULL,
    [CodCentro]            VARCHAR (3)  NULL,
    [CDAC1]                VARCHAR (2)  NOT NULL,
    [CDAC2]                VARCHAR (2)  NOT NULL,
    [Importe]              NUMERIC (9)  NOT NULL,
    [Mercado]              NVARCHAR (1) NULL,
    CONSTRAINT [PK_ObjetivosActividadSQL] PRIMARY KEY CLUSTERED ([idObjetivosActividad] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_Año]
    ON [dbo].[ObjetivosActividadSQL]([Año] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodCentro]
    ON [dbo].[ObjetivosActividadSQL]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CDAC1]
    ON [dbo].[ObjetivosActividadSQL]([CDAC1] ASC, [CDAC2] ASC);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ObjetivosActividadSQL] TO [partnertec]
    AS [dbo];

