CREATE TABLE [dbo].[RPI_Monedas] (
    [CodMoneda]    VARCHAR (5)  NOT NULL,
    [Pais]         VARCHAR (50) NOT NULL,
    [NombreMoneda] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_RPI_Monedas] PRIMARY KEY CLUSTERED ([CodMoneda] ASC)
);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[RPI_Monedas] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT VIEW CHANGE TRACKING
    ON OBJECT::[dbo].[RPI_Monedas] TO [UsuDataLakeCIC]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[RPI_Monedas] TO [UsuDataLakeCIC]
    AS [dbo];

