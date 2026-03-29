CREATE TABLE [dbo].[rptPrincipalesObras] (
    [idObrs]               INT            IDENTITY (1, 1) NOT NULL,
    [CodCentro]            VARCHAR (3)    NULL,
    [Pais]                 VARCHAR (100)  NOT NULL,
    [Año]                  INT            NOT NULL,
    [Mes]                  INT            NOT NULL,
    [CodOferta]            VARCHAR (10)   NULL,
    [DescripcionOferta]    NVARCHAR (100) NOT NULL,
    [DescripcionOferta_OK] NVARCHAR (100) NOT NULL,
    [NombreCliente]        VARCHAR (100)  NOT NULL,
    [NombreCliente_OK]     VARCHAR (100)  NOT NULL,
    [ImporteContratado]    FLOAT (53)     CONSTRAINT [DF_rptPrincipalesObras_ImporteContratado] DEFAULT ((0)) NOT NULL,
    [ImporteContratado_OK] FLOAT (53)     CONSTRAINT [DF_rptPrincipalesObras_ImporteContratado1] DEFAULT ((0)) NOT NULL,
    [Ocultar]              BIT            CONSTRAINT [DF_rptPrincipalesObras_Ocultar] DEFAULT ((0)) NOT NULL,
    [NombreDirNegocio_OK]  VARCHAR (50)   NULL,
    [wTipo]                INT            NOT NULL,
    CONSTRAINT [PK_rptPrincipalesObras_1] PRIMARY KEY CLUSTERED ([idObrs] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Año_Mes]
    ON [dbo].[rptPrincipalesObras]([Año] ASC, [Mes] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodCentro]
    ON [dbo].[rptPrincipalesObras]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_rptPrincipalesObras_Ano_Mes_wTipo_CodOferta]
    ON [dbo].[rptPrincipalesObras]([Año] ASC, [Mes] ASC, [wTipo] ASC, [CodOferta] ASC)
    INCLUDE([DescripcionOferta], [ImporteContratado], [CodCentro], [NombreCliente]) WITH (FILLFACTOR = 90, PAD_INDEX = ON);


GO
CREATE NONCLUSTERED INDEX [IX_rptPrincipalesObras_Ocultar_Ano_Mes_wTipo]
    ON [dbo].[rptPrincipalesObras]([Ocultar] ASC, [Año] ASC, [Mes] ASC, [wTipo] ASC)
    INCLUDE([CodOferta], [DescripcionOferta], [ImporteContratado], [NombreCliente]) WITH (FILLFACTOR = 90);

