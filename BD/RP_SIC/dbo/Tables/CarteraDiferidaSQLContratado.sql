CREATE TABLE [dbo].[CarteraDiferidaSQLContratado] (
    [CodOferta]    VARCHAR (10) NULL,
    [Año]          INT          NOT NULL,
    [TMarzo]       FLOAT (53)   CONSTRAINT [DF_CarteraDiferidaSQLContratado_TMarzo] DEFAULT ((0)) NULL,
    [TJunio]       FLOAT (53)   CONSTRAINT [DF_CarteraDiferidaSQLContratado_TJunio] DEFAULT ((0)) NULL,
    [TSept]        FLOAT (53)   CONSTRAINT [DF_CarteraDiferidaSQLContratado_TSept] DEFAULT ((0)) NULL,
    [TDic]         FLOAT (53)   CONSTRAINT [DF_CarteraDiferidaSQLContratado_TDic] DEFAULT ((0)) NULL,
    [TotAnual]     FLOAT (53)   CONSTRAINT [DF_CarteraDiferidaSQLContratado_TotAnual] DEFAULT ((0)) NULL,
    [NombreOferta] VARCHAR (50) NULL,
    [MontoT]       AS           ((([Tmarzo]+[tJunio])+[tsept])+[tdic])
);

