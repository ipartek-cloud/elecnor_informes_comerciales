CREATE TABLE [dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Org_Pais] (
    [AnioInforme]             INT             NOT NULL,
    [MesInforme]              INT             NOT NULL,
    [Pais]                    NVARCHAR (255)  NULL,
    [CodSubDirGeneral]        NVARCHAR (255)  NULL,
    [CodDDirNegocio]          NVARCHAR (255)  NULL,
    [NombreDirNegocio]        NVARCHAR (255)  NULL,
    [NomCliente]              NVARCHAR (500)  NULL,
    [DesOferta]               NVARCHAR (MAX)  NULL,
    [ImporteCarteraOferta]    DECIMAL (18, 2) NULL,
    [ImporteContratadoOferta] DECIMAL (18, 2) NULL,
    [ImporteCarteraDN]        DECIMAL (18, 2) NULL,
    [ImporteCarteraPais]      DECIMAL (28, 5) NULL
);

