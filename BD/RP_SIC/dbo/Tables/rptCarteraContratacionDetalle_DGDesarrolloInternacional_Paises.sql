CREATE TABLE [dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises] (
    [AnioInforme]             INT             NOT NULL,
    [MesInforme]              INT             NOT NULL,
    [Pais]                    NVARCHAR (255)  NULL,
    [NomCliente]              NVARCHAR (500)  NULL,
    [DesOferta]               NVARCHAR (MAX)  NULL,
    [ImporteCarteraOferta]    DECIMAL (18, 2) NULL,
    [ImporteContratadoOferta] DECIMAL (18, 2) NULL,
    [ImporteCarteraPais]      DECIMAL (28, 5) NULL
);

