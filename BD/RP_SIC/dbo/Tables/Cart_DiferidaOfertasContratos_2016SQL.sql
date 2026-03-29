CREATE TABLE [dbo].[Cart_DiferidaOfertasContratos_2016SQL] (
    [ClaveID]        INT           IDENTITY (1, 1) NOT NULL,
    [ID]             INT           NULL,
    [Contrato]       VARCHAR (255) NOT NULL,
    [Cliente]        VARCHAR (255) NOT NULL,
    [Zona]           VARCHAR (255) NULL,
    [Año]            INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_Año] DEFAULT ((2016)) NULL,
    [Centro]         NUMERIC (3)   NULL,
    [CodOferta]      VARCHAR (10)  NULL,
    [CartInicio]     INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_CartInicio] DEFAULT ((0)) NULL,
    [MontoAnual]     INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_MontoAnual] DEFAULT ((0)) NULL,
    [NTrimestres]    INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_NTrimestres] DEFAULT ((0)) NULL,
    [MontoTrimestre] INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_MontoTrimestre] DEFAULT ((0)) NULL,
    [Previsto1]      INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_Previsto1] DEFAULT ((0)) NULL,
    [Previsto2]      INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_Previsto2] DEFAULT ((0)) NULL,
    [Previsto3]      INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_Previsto3] DEFAULT ((0)) NULL,
    [Previsto4]      INT           CONSTRAINT [DF_Cart_DiferidaOfertasContratos_2016SQL_Previsto4] DEFAULT ((0)) NULL,
    [Meses]          INT           NULL,
    [Vigente]        BIT           NULL,
    [CodCliente]     VARCHAR (10)  NULL,
    [NomAgrupado]    VARCHAR (100) NULL,
    CONSTRAINT [PK_Cart_DiferidaOfertasContratos_2016SQL] PRIMARY KEY CLUSTERED ([ClaveID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_ID]
    ON [dbo].[Cart_DiferidaOfertasContratos_2016SQL]([ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Centro]
    ON [dbo].[Cart_DiferidaOfertasContratos_2016SQL]([Centro] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CodOferta]
    ON [dbo].[Cart_DiferidaOfertasContratos_2016SQL]([CodOferta] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Cart_DiferidaOfertasContratos_2016SQL_Año]
    ON [dbo].[Cart_DiferidaOfertasContratos_2016SQL]([Año] ASC)
    INCLUDE([ID], [CodOferta]);


GO
CREATE TRIGGER [dbo].[Cart_DiferidaOfertasContratos_2016SQL_INSERT] ON  dbo.Cart_DiferidaOfertasContratos_2016SQL
FOR INSERT
AS 
BEGIN
		--SQL
		UPDATE Cart_DiferidaOfertasContratos_2016SQL
		SET CodCliente=vwContratacion_SQL.CodCliente, NomAgrupado=vwContratacion_SQL.NomCliente
		FROM vwContratacion_SQL INNER JOIN Inserted ON vwContratacion_SQL.CODOFER=Inserted.CodOferta
		WHERE Cart_DiferidaOfertasContratos_2016SQL.CodOferta=Inserted.CodOferta

		-- AS400
		UPDATE Cart_DiferidaOfertasContratos_2016SQL
		SET CodCliente=vwContratacion_AS400.CODCLIENTE, NomAgrupado=vwContratacion_AS400.NomCliente
		FROM vwContratacion_AS400 INNER JOIN Inserted ON vwContratacion_AS400.CODOFER=Inserted.CodOferta
		WHERE Cart_DiferidaOfertasContratos_2016SQL.CodOferta=Inserted.CodOferta

		-- No Casque la WEB
		UPDATE Cart_DiferidaOfertasContratos_2016SQL
		SET CodCliente='0',NomAgrupado='Sin Cliente Asociado'
		WHERE isnull(CodCliente,'')='' 
END

GO
GRANT SELECT
    ON OBJECT::[dbo].[Cart_DiferidaOfertasContratos_2016SQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[Cart_DiferidaOfertasContratos_2016SQL] TO [USRGPROD]
    AS [dbo];

