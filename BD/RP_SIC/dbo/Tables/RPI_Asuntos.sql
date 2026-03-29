CREATE TABLE [dbo].[RPI_Asuntos] (
    [idAsunto]                         INT            IDENTITY (1, 1) NOT NULL,
    [FechaAsunto]                      VARCHAR (10)   NOT NULL,
    [MontoAsunto]                      FLOAT (53)     CONSTRAINT [DF_RPI_Asuntos_MontoPresentado1] DEFAULT ((0)) NULL,
    [FechaPresentado]                  VARCHAR (10)   NULL,
    [MontoPresentado]                  FLOAT (53)     CONSTRAINT [DF_RPI_Asuntos_MontoPresentado] DEFAULT ((0)) NULL,
    [FechaPreAdjudicado]               VARCHAR (10)   NULL,
    [MontoPreAdjudicado]               FLOAT (53)     CONSTRAINT [DF_RPI_Asuntos_MontoAdjudicado1] DEFAULT ((0)) NULL,
    [FechaAdjudicado]                  VARCHAR (10)   NULL,
    [MontoAdjudicado]                  FLOAT (53)     CONSTRAINT [DF_RPI_Asuntos_MontoAdjudicado] DEFAULT ((0)) NULL,
    [FechaEnVigor]                     VARCHAR (10)   NULL,
    [MontoEnVigor]                     FLOAT (53)     CONSTRAINT [DF_RPI_Asuntos_MontoPresentado1_1] DEFAULT ((0)) NULL,
    [FechaDenegado]                    VARCHAR (50)   NULL,
    [MontoDenegado]                    FLOAT (53)     CONSTRAINT [DF_RPI_Asuntos_MontoEnValor1] DEFAULT ((0)) NULL,
    [Estado]                           AS             ([dbo].[fnEstadoAsunto]([FechaPresentado],[FechaPreAdjudicado],[FechaAdjudicado],[FechaEnVigor],[FechaDenegado])),
    [idArea_Pais]                      INT            NOT NULL,
    [idProbabilidad]                   INT            NOT NULL,
    [IdActividad_1]                    INT            NOT NULL,
    [IdActividad_2]                    INT            NULL,
    [CodCliente]                       VARCHAR (8)    NOT NULL,
    [Singular]                         BIT            CONSTRAINT [DF_RPI_Asuntos_Financiacion1] DEFAULT ((0)) NOT NULL,
    [Financiacion]                     BIT            CONSTRAINT [DF_RPI_Asuntos_Financiacion] DEFAULT ((0)) NOT NULL,
    [Precalificacion]                  BIT            CONSTRAINT [DF_RPI_Asuntos_Precalificacion] DEFAULT ((0)) NOT NULL,
    [CodMoneda]                        VARCHAR (5)    NOT NULL,
    [UsuarioPropietario]               VARCHAR (50)   NOT NULL,
    [Proyecto]                         VARCHAR (5000) NOT NULL,
    [EstructuraContraactual]           VARCHAR (5000) NULL,
    [MemoriaProyecto]                  VARCHAR (5000) NOT NULL,
    [Instalaciones_Redes_Centro]       BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Centro] DEFAULT ((0)) NOT NULL,
    [Instalaciones_Redes_Sur]          BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Centro1] DEFAULT ((0)) NOT NULL,
    [Instalaciones_Redes_Este]         BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Centro1_1] DEFAULT ((0)) NOT NULL,
    [Instalaciones_Redes_Nordeste]     BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Centro1_2] DEFAULT ((0)) NOT NULL,
    [Instalaciones_Redes_Norteamerica] BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Nordeste1] DEFAULT ((0)) NOT NULL,
    [GrandesRedes_Gas]                 BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Nordeste1_1] DEFAULT ((0)) NOT NULL,
    [GrandesRedes_LineasUE]            BIT            CONSTRAINT [DF_RPI_Asuntos_GrandesRedes_Area21_1] DEFAULT ((0)) NOT NULL,
    [GrandesRedes_Area1]               BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Centro1_3] DEFAULT ((0)) NOT NULL,
    [GrandesRedes_Area2]               BIT            CONSTRAINT [DF_RPI_Asuntos_GrandesRedes_Area11] DEFAULT ((0)) NOT NULL,
    [GrandesRedes_Area3]               BIT            CONSTRAINT [DF_RPI_Asuntos_GrandesRedes_Area21] DEFAULT ((0)) NOT NULL,
    [Energia_Audeca]                   BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Nordeste1_2] DEFAULT ((0)) NOT NULL,
    [Energia_Area1]                    BIT            CONSTRAINT [DF_RPI_Asuntos_GrandesRedes_Area21_2] DEFAULT ((0)) NOT NULL,
    [Energia_Area2]                    BIT            CONSTRAINT [DF_RPI_Asuntos_Energia_Area11] DEFAULT ((0)) NOT NULL,
    [Energia_Area3]                    BIT            CONSTRAINT [DF_RPI_Asuntos_Energia_Area21] DEFAULT ((0)) NOT NULL,
    [Energia_Area4_FFCC]               BIT            CONSTRAINT [DF_RPI_Asuntos_Energia_Area31] DEFAULT ((0)) NOT NULL,
    [Ingenieria]                       BIT            CONSTRAINT [DF_RPI_Asuntos_Instalaciones_Redes_Nordeste1_3] DEFAULT ((0)) NOT NULL,
    [Anexo1]                           BIT            CONSTRAINT [DF_RPI_Asuntos_Anexo1] DEFAULT ((0)) NOT NULL,
    [Anexo2]                           BIT            CONSTRAINT [DF_RPI_Asuntos_Anexo2] DEFAULT ((0)) NOT NULL,
    [Anexo3]                           BIT            CONSTRAINT [DF_RPI_Asuntos_Anexo3] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RPI_Asuntos] PRIMARY KEY CLUSTERED ([idAsunto] ASC),
    CONSTRAINT [FK_RPI_Asuntos_RPI_Actividades] FOREIGN KEY ([IdActividad_1]) REFERENCES [dbo].[RPI_Actividades] ([idActividad]) ON UPDATE CASCADE,
    CONSTRAINT [FK_RPI_Asuntos_RPI_Area_Pais] FOREIGN KEY ([idArea_Pais]) REFERENCES [dbo].[RPI_Area_Pais] ([idArea_Pais]) ON UPDATE CASCADE,
    CONSTRAINT [FK_RPI_Asuntos_RPI_Clientes] FOREIGN KEY ([CodCliente]) REFERENCES [dbo].[RPI_Clientes] ([CodCliente]) ON UPDATE CASCADE,
    CONSTRAINT [FK_RPI_Asuntos_RPI_Monedas] FOREIGN KEY ([CodMoneda]) REFERENCES [dbo].[RPI_Monedas] ([CodMoneda]) ON UPDATE CASCADE,
    CONSTRAINT [FK_RPI_Asuntos_RPI_Probabilidades] FOREIGN KEY ([idProbabilidad]) REFERENCES [dbo].[RPI_Probabilidades] ([idProbabilidad]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_RPI_Asuntos_idArea_Pais]
    ON [dbo].[RPI_Asuntos]([idArea_Pais] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RPI_Asuntos_idProbabilidad]
    ON [dbo].[RPI_Asuntos]([idProbabilidad] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RPI_Asuntos_IdActividad_1]
    ON [dbo].[RPI_Asuntos]([IdActividad_1] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RPI_Asuntos_IdActividad_2]
    ON [dbo].[RPI_Asuntos]([IdActividad_2] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RPI_Asuntos_CodCliente]
    ON [dbo].[RPI_Asuntos]([CodCliente] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RPI_Asuntos_CodMoneda]
    ON [dbo].[RPI_Asuntos]([CodMoneda] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RPI_Asuntos_UsuarioPropietario]
    ON [dbo].[RPI_Asuntos]([UsuarioPropietario] ASC);

