CREATE TABLE [dbo].[WEB_TMP_ContratacionAS400] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [CodCentro]         VARCHAR (3)   NULL,
    [CodOferta]         VARCHAR (10)  NULL,
    [FAdjudicacion]     DATETIME      NOT NULL,
    [FAdjudicacion_Año] AS            (datepart(year,[FAdjudicacion])),
    [FAdjudicacion_Mes] AS            (datepart(month,[FAdjudicacion])),
    [ImporteTotal]      FLOAT (53)    CONSTRAINT [DF_WEB_TMP_ContratacionAS400_ImporteTotal] DEFAULT ((0)) NULL,
    [Tipo]              NCHAR (1)     NULL,
    [DesOfer]           VARCHAR (500) NULL,
    CONSTRAINT [PK_Table_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Table_CodOferta]
    ON [dbo].[WEB_TMP_ContratacionAS400]([CodOferta] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Table_CodCentro_CodOferta]
    ON [dbo].[WEB_TMP_ContratacionAS400]([CodCentro] ASC, [CodOferta] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Table_FAdjudicacion]
    ON [dbo].[WEB_TMP_ContratacionAS400]([FAdjudicacion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Table_FAdjudicacion_Año_FAdjudicacion_Mes]
    ON [dbo].[WEB_TMP_ContratacionAS400]([FAdjudicacion_Año] ASC, [FAdjudicacion_Mes] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Table_FAdjudicacion_Año]
    ON [dbo].[WEB_TMP_ContratacionAS400]([FAdjudicacion_Año] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Table_FAdjudicacion_Mes]
    ON [dbo].[WEB_TMP_ContratacionAS400]([FAdjudicacion_Mes] ASC);

