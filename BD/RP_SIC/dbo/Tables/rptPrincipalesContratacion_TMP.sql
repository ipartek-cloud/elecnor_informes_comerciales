CREATE TABLE [dbo].[rptPrincipalesContratacion_TMP] (
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
    [ImporteContratado]    FLOAT (53)     CONSTRAINT [DF_rptPrincipalesContratacion_ImporteContratado_TMP] DEFAULT ((0)) NOT NULL,
    [ImporteContratado_OK] FLOAT (53)     CONSTRAINT [DF_rptPrincipalesContratacion_ImporteContratado_OK_TMP] DEFAULT ((0)) NOT NULL,
    [Ocultar]              BIT            CONSTRAINT [DF_rptPrincipalesContratacion_Ocultar_TMP] DEFAULT ((0)) NOT NULL,
    [NombreDirNegocio_OK]  VARCHAR (50)   NULL,
    [wTipo]                INT            NOT NULL,
    CONSTRAINT [PK_rptPrincipalesContratacion_TMP] PRIMARY KEY CLUSTERED ([idObrs] ASC)
);

