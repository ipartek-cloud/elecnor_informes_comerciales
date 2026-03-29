CREATE TABLE [dbo].[ObjetivosCompararSDG] (
    [Año]        INT         NOT NULL,
    [Mercado]    NCHAR (50)  NOT NULL,
    [CodSubG]    VARCHAR (3) NOT NULL,
    [RealAñoAnt] FLOAT (53)  NULL,
    CONSTRAINT [PK_ObjCompararSDG] PRIMARY KEY CLUSTERED ([Año] ASC, [Mercado] ASC, [CodSubG] ASC)
);

