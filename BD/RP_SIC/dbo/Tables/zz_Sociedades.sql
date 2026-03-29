CREATE TABLE [dbo].[zz_Sociedades] (
    [IdSociedad] VARCHAR (10)  NOT NULL,
    [Sociedad]   VARCHAR (100) NULL,
    [Origen]     VARCHAR (20)  NULL,
    CONSTRAINT [PK_zz_Sociedades] PRIMARY KEY CLUSTERED ([IdSociedad] ASC)
);

