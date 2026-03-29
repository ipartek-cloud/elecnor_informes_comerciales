CREATE TABLE [dbo].[WEB_CertificacionesUsuarioCentro] (
    [id]                      INT            IDENTITY (1, 1) NOT NULL,
    [Usuario]                 VARCHAR (50)   NOT NULL,
    [CodDirGeneral]           VARCHAR (3)    NULL,
    [NombreDirGeneral]        NVARCHAR (100) NULL,
    [CodSubDirGeneral]        VARCHAR (3)    NULL,
    [NombreSubDirGeneral]     NVARCHAR (100) NULL,
    [CodDDirNegocio]          VARCHAR (3)    NULL,
    [NombreDirNegocio]        NVARCHAR (30)  NULL,
    [CodSubDirNegocioArea]    VARCHAR (3)    NULL,
    [NombreSubDirNegocioArea] NVARCHAR (100) NULL,
    [CodDelegacion]           VARCHAR (3)    NULL,
    [NombreDelegacion]        NVARCHAR (30)  NULL,
    [CodCentro]               VARCHAR (3)    NULL,
    [NombreCentro]            NVARCHAR (30)  NULL,
    [NumReferencias_ALL]      INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumReferencias_ALL] DEFAULT ((0)) NULL,
    [NumCBE_ALL]              INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumCBE_ALL] DEFAULT ((0)) NULL,
    [NumOfertas_2016]         INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumOfertas_2016] DEFAULT ((0)) NULL,
    [NumReferencias_2016]     INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumReferencias_2016] DEFAULT ((0)) NULL,
    [NumCBE_2016]             INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumCBE_2016] DEFAULT ((0)) NULL,
    [NumOfertas_2018]         INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumOfertas_2018] DEFAULT ((0)) NULL,
    [NumReferencias_2018]     INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumReferencias_2018] DEFAULT ((0)) NULL,
    [NumCBE_2018]             INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumCBE_2018] DEFAULT ((0)) NULL,
    [NumOfertas_2019]         INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumOfertas_2019] DEFAULT ((0)) NULL,
    [NumReferencias_2019]     INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumReferencias_2019] DEFAULT ((0)) NULL,
    [NumCBE_2019]             INT            CONSTRAINT [DF_WEB_CertificacionesUsuarioCentro_NumCBE_2019] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_WEB_CertificacionesUsuarioCentro_Id] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CertificacionesUsuarioCentro_Usuario]
    ON [dbo].[WEB_CertificacionesUsuarioCentro]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WEB_CertificacionesUsuarioCentro_CodCentro]
    ON [dbo].[WEB_CertificacionesUsuarioCentro]([CodCentro] ASC);

