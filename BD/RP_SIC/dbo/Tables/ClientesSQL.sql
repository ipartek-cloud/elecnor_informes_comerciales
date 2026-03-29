CREATE TABLE [dbo].[ClientesSQL] (
    [CodCliente]          NVARCHAR (255) NOT NULL,
    [NombreCliente]       NVARCHAR (255) NULL,
    [NomAgrupado]         NVARCHAR (255) NULL,
    [Pais]                NVARCHAR (255) NULL,
    [Visible]             BIT            CONSTRAINT [DF_ClientesSQL_Visible] DEFAULT ((1)) NULL,
    [NomAgrupadoDesglose] NVARCHAR (255) NULL,
    [VisibleDesglose]     BIT            CONSTRAINT [DF_ClientesSQL_Visible1] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ClientesSQL] PRIMARY KEY CLUSTERED ([CodCliente] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_NomAgrupado]
    ON [dbo].[ClientesSQL]([NomAgrupado] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Pais]
    ON [dbo].[ClientesSQL]([Pais] ASC);


GO

--SELECT * FROM [dbo].[ClientesSQL]

CREATE TRIGGER [dbo].[ClientesSQL_INSERT] ON  [dbo].[ClientesSQL]
FOR INSERT,UPDATE
AS 
BEGIN			
		UPDATE Cart_DiferidaOfertasContratos_2016SQL
		SET NomAgrupado=Inserted.NomAgrupado
		FROM Cart_DiferidaOfertasContratos_2016SQL INNER JOIN
		Inserted ON Cart_DiferidaOfertasContratos_2016SQL.CodCliente=Inserted.CodCliente
END


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ClientesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ClientesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ClientesSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ClientesSQL] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ClientesSQL] TO [USRGPROD]
    AS [dbo];

