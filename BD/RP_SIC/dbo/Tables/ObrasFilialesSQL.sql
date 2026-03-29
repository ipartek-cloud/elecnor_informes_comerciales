CREATE TABLE [dbo].[ObrasFilialesSQL] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [Año]               INT           NULL,
    [Mes]               INT           NULL,
    [CentroCRM]         VARCHAR (3)   NULL,
    [IdCentro]          VARCHAR (3)   NULL,
    [Centro]            VARCHAR (100) NULL,
    [IdObra]            VARCHAR (4)   NULL,
    [Obra]              VARCHAR (100) NULL,
    [FechaApertura]     DATE          NULL,
    [FechaCierre]       DATE          NULL,
    [IdOferta]          VARCHAR (10)  NULL,
    [Porcentaje]        FLOAT (53)    NULL,
    [ProduccionOrigen]  FLOAT (53)    NULL,
    [FacturacionOrigen] FLOAT (53)    NULL,
    [FOTOrigen]         FLOAT (53)    NULL,
    [Tipo]              VARCHAR (1)   CONSTRAINT [DF__ObrasFilia__Tipo__128A6714] DEFAULT ('F') NULL,
    [IdEmpresa]         VARCHAR (7)   NULL,
    [FechaCreacion]     DATETIME      NULL,
    CONSTRAINT [PK_ObrasFilialesSQL] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ObrasFilialesSQL_Año_Mes]
    ON [dbo].[ObrasFilialesSQL]([Año] ASC, [Mes] ASC)
    INCLUDE([CentroCRM], [IdCentro], [IdObra], [Obra], [FechaApertura], [FechaCierre], [IdOferta], [ProduccionOrigen], [FacturacionOrigen], [FOTOrigen], [Tipo]);

