CREATE TABLE [dbo].[rptPrincipalesObrasAI] (
    [idObrs]               INT            IDENTITY (1, 1) NOT NULL,
    [NombreDirNegocio]     VARCHAR (100)  NULL,
    [NombreDirNegocio_OK]  VARCHAR (100)  NULL,
    [Pais]                 VARCHAR (100)  NOT NULL,
    [Año]                  INT            NOT NULL,
    [Mes]                  INT            NOT NULL,
    [CodOferta]            VARCHAR (10)   NULL,
    [DescripcionOferta]    NVARCHAR (100) NOT NULL,
    [DescripcionOferta_OK] NVARCHAR (100) NOT NULL,
    [NombreCliente]        VARCHAR (100)  NOT NULL,
    [NombreCliente_OK]     VARCHAR (100)  NOT NULL,
    [ImporteContratado]    FLOAT (53)     NOT NULL,
    [ImporteContratado_OK] FLOAT (53)     CONSTRAINT [DF_rptPrincipalesObrasAI_ImporteContratado_OK] DEFAULT ((0)) NOT NULL,
    [Ocultar]              BIT            CONSTRAINT [DF_rptPrincipalesObrasAI_Ocultar] DEFAULT ((0)) NOT NULL,
    [wTipo]                INT            NULL,
    CONSTRAINT [PK_rptPrincipalesObrasAI] PRIMARY KEY CLUSTERED ([idObrs] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AñoMes]
    ON [dbo].[rptPrincipalesObrasAI]([Año] ASC, [Mes] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_rptPrincipalesObrasAI_Ano_Mes_wTipo_CodOferta]
    ON [dbo].[rptPrincipalesObrasAI]([Año] ASC, [Mes] ASC, [wTipo] ASC, [CodOferta] ASC) WITH (FILLFACTOR = 90, PAD_INDEX = ON);


GO
CREATE NONCLUSTERED INDEX [IX_rptPrincipalesObrasAI_wTipo]
    ON [dbo].[rptPrincipalesObrasAI]([wTipo] ASC)
    INCLUDE([Año], [Mes], [CodOferta], [DescripcionOferta], [ImporteContratado]) WITH (FILLFACTOR = 90);

