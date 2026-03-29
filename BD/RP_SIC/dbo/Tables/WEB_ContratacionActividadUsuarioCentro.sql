CREATE TABLE [dbo].[WEB_ContratacionActividadUsuarioCentro] (
    [id]                                    INT            IDENTITY (1, 1) NOT NULL,
    [Usuario]                               VARCHAR (50)   NOT NULL,
    [Año]                                   INT            NOT NULL,
    [Mes]                                   INT            NOT NULL,
    [CodDirGeneral]                         VARCHAR (3)    NULL,
    [NombreDirGeneral]                      NVARCHAR (100) NULL,
    [CodSubDirGeneral]                      VARCHAR (3)    NULL,
    [NombreSubDirGeneral]                   NVARCHAR (100) NULL,
    [CodDDirNegocio]                        VARCHAR (3)    NULL,
    [NombreDirNegocio]                      NVARCHAR (30)  NULL,
    [CodSubDirNegocioArea]                  VARCHAR (3)    NULL,
    [NombreSubDirNegocioArea]               NVARCHAR (100) NULL,
    [CodDelegacion]                         VARCHAR (3)    NULL,
    [NombreDelegacion]                      NVARCHAR (30)  NULL,
    [CodCentro]                             VARCHAR (3)    NULL,
    [NombreCentro]                          NVARCHAR (30)  NULL,
    [CDAC1]                                 VARCHAR (2)    NOT NULL,
    [CDAC2]                                 VARCHAR (2)    NOT NULL,
    [DSACT]                                 AS             ([dbo].[fnActividadDescripcion]([CDAC1],[CDAC2])),
    [Agrupacion]                            AS             ([dbo].[fnActividadAgrupacion]([CDAC1],[CDAC2])),
    [ImporteContratado]                     FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionActividadUsuarioCentro_ImporteContratado] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumulado]            FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionActividadUsuarioCentro_ImporteContratadoAcumulado] DEFAULT ((0)) NULL,
    [ImporteContratadoMesAnterior]          FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionActividadUsuarioCentro_ImporteContratadoMesAnterior] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoMesAnterior] FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionActividadUsuarioCentro_ImporteContratadoAcumuladoMesAnterior] DEFAULT ((0)) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] FLOAT (53)     CONSTRAINT [DF_WEB_ContratacionActividadUsuarioCentro_ImporteContratadoAcumuladoAñoAnterior] DEFAULT ((0)) NULL,
    [VariacionContratacion]                 AS             ([dbo].[fnImporteVariacion]([ImporteContratadoAcumulado],[ImporteContratadoAcumuladoAñoAnterior])),
    [Objetivos]                             AS             ([dbo].[fnObjetivos_CT]([año],[Codcentro])),
    CONSTRAINT [PK_WEB_ContratacionActividadUsuarioCentro_1] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_ContratacionActividadUsuarioCentro_Usuario]
    ON [dbo].[WEB_ContratacionActividadUsuarioCentro]([Usuario] ASC);

