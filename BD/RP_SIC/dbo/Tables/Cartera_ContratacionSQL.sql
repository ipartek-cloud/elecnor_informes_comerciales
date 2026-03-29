CREATE TABLE [dbo].[Cartera_ContratacionSQL] (
    [idCarteraContratacion] NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Dir_Negocio]           NVARCHAR (255) NULL,
    [Cliente]               NVARCHAR (255) NULL,
    [Descrip_Oferta]        NVARCHAR (255) NOT NULL,
    [Pais]                  NVARCHAR (255) NULL,
    [Importe]               MONEY          NULL,
    [Cod_Oferta]            NVARCHAR (255) NULL,
    [Estado]                NVARCHAR (255) NULL,
    [Fecha]                 DATETIME       NULL,
    CONSTRAINT [PK_Cartera_Contratacion] PRIMARY KEY CLUSTERED ([idCarteraContratacion] ASC)
);

