CREATE TABLE [dbo].[rptCartera_Contratacion_Resumen_SDG] (
    [Año]                SMALLINT        NOT NULL,
    [Mes]                 SMALLINT        NOT NULL,
    [CodSubDirGeneral]    NVARCHAR (3)    NOT NULL,
    [CodDDirNegocio]      NVARCHAR (3)    NOT NULL,
    [NombreSubDirGeneral] NVARCHAR (255)  NULL,
    [DN]                  NVARCHAR (255)  NOT NULL,
    [TotAño]             DECIMAL (18, 2) NULL,
    [TotAñoAnterior]     DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_rptCartera_Contratacion_Resumen_SDG] PRIMARY KEY CLUSTERED ([Año] ASC, [Mes] ASC, [CodSubDirGeneral] ASC, [CodDDirNegocio] ASC)
);

