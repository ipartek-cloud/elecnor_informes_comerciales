CREATE TABLE [dbo].[rptPrincipalesContratacion] (
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
    [ImporteContratado]    FLOAT (53)     CONSTRAINT [DF_rptPrincipalesContratacion_ImporteContratado] DEFAULT ((0)) NOT NULL,
    [ImporteContratado_OK] FLOAT (53)     CONSTRAINT [DF_rptPrincipalesContratacion_ImporteContratado_OK] DEFAULT ((0)) NOT NULL,
    [Ocultar]              BIT            CONSTRAINT [DF_rptPrincipalesContratacion_Ocultar] DEFAULT ((0)) NOT NULL,
    [NombreDirNegocio_OK]  VARCHAR (50)   NULL,
    [wTipo]                INT            NOT NULL,
    CONSTRAINT [PK_rptPrincipalesContratacion] PRIMARY KEY CLUSTERED ([idObrs] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_rptPrincipalesContratacion]
    ON [dbo].[rptPrincipalesContratacion]([CodCentro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_rptPrincipalesContratacion_1]
    ON [dbo].[rptPrincipalesContratacion]([Año] ASC, [Mes] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_rptPrincipalesContratacion_2]
    ON [dbo].[rptPrincipalesContratacion]([wTipo] ASC);


GO
CREATE NONCLUSTERED INDEX [rptPrincipalesContratacion_Año_Mes]
    ON [dbo].[rptPrincipalesContratacion]([Año] ASC, [Mes] ASC);


GO
CREATE NONCLUSTERED INDEX [rptPrincipalesContratacion_Año_Mes_CodOferta]
    ON [dbo].[rptPrincipalesContratacion]([Año] ASC, [Mes] ASC, [CodOferta] ASC);

