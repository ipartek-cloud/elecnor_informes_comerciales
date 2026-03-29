CREATE TABLE [dbo].[ContratacionesReguladasSQL] (
    [idContratacionesReguladasSQL] INT          IDENTITY (1, 1) NOT NULL,
    [Año]                          INT          NOT NULL,
    [CodCentro]                    VARCHAR (3)  NULL,
    [CodOferta]                    VARCHAR (10) NULL,
    [PorcetajePaso]                FLOAT (53)   CONSTRAINT [DF_ContratacionesReguladasSQL_PorcetajePaso] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ContratacionesReguladasSQL_1] PRIMARY KEY CLUSTERED ([idContratacionesReguladasSQL] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ContratacionesReguladasSQL]
    ON [dbo].[ContratacionesReguladasSQL]([Año] ASC, [CodCentro] ASC, [CodOferta] ASC);

