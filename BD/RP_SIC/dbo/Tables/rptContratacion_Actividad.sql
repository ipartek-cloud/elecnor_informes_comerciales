CREATE TABLE [dbo].[rptContratacion_Actividad] (
    [idContratacionActividad]               INT             IDENTITY (1, 1) NOT NULL,
    [Actividad]                             NVARCHAR (255)  NULL,
    [Año]                                   INT             NULL,
    [CodActividad]                          NVARCHAR (2)    NULL,
    [ImporteContratadoAcumulado]            DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoAñoAnterior] DECIMAL (18, 2) NULL,
    [ImporteContratadoAcumuladoLastYear]    DECIMAL (18, 2) NULL,
    [Orden]                                 INT             NULL,
    [Pais]                                  NVARCHAR (255)  NULL,
    [NombreDirGeneral]                      VARCHAR (255)   NULL,
    CONSTRAINT [PK_rptContratacion_Actividad] PRIMARY KEY CLUSTERED ([idContratacionActividad] ASC)
);

