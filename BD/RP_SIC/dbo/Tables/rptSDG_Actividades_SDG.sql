CREATE TABLE [dbo].[rptSDG_Actividades_SDG] (
    [idSDG_Actividades_SDG] INT             IDENTITY (1, 1) NOT NULL,
    [Año]                   INT             NOT NULL,
    [Agrupacion]            NVARCHAR (255)  NULL,
    [Mercado]               NVARCHAR (255)  NULL,
    [CodDirNegocio]         NVARCHAR (255)  NULL,
    [NombreDirNegocio]      NVARCHAR (255)  NULL,
    [Orden]                 INT             NULL,
    [Contrat]               DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [ACT1]                  NVARCHAR (255)  NULL,
    [Contrat_1]             DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [Objetivos]             DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [LoginUsuario]          NVARCHAR (100)  CONSTRAINT [DF_rptSDG_Actividades_SDG_Login] DEFAULT ('ACCESS') NULL,
    [FechaCreacion]         DATETIME        CONSTRAINT [DF_rptSDG_Actividades_SDG_Fecha] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_rptSDG_Actividades_SDG] PRIMARY KEY CLUSTERED ([idSDG_Actividades_SDG] ASC)
);

CREATE NONCLUSTERED INDEX [IX_rptSDG_Actividades_SDG_LoginUsuario]
    ON [dbo].[rptSDG_Actividades_SDG]([LoginUsuario] ASC, [Año] ASC);


