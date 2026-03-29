CREATE TABLE [dbo].[WEB_Parametros] (
    [id]                      INT            IDENTITY (1, 1) NOT NULL,
    [FechaCierre]             VARCHAR (50)   NULL,
    [Contratacion_Comentario] VARCHAR (1000) NULL,
    [Cod_Nota1]               VARCHAR (5)    NULL,
    [Observacion_Nota1]       VARCHAR (50)   NULL,
    [Cod_Nota2]               VARCHAR (5)    NULL,
    [Observacion_Nota2]       VARCHAR (50)   NULL,
    [Cod_Nota3]               VARCHAR (5)    NULL,
    [Observacion_Nota3]       VARCHAR (50)   NULL,
    [FechaCambioAño]          DATE           NULL,
    CONSTRAINT [PK_WEB_Parametros] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[WEB_Parametros] TO [USRGPROD]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[WEB_Parametros] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[WEB_Parametros] TO [USRGPROD]
    AS [dbo];

