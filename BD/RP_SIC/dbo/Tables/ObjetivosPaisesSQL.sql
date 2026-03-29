CREATE TABLE [dbo].[ObjetivosPaisesSQL] (
    [CodZona]    VARCHAR (3) NOT NULL,
    [CodSubZona] VARCHAR (3) NOT NULL,
    [CDPRO]      NCHAR (2)   NOT NULL,
    [Obj_R]      FLOAT (53)  CONSTRAINT [DF_ObjetivosPaisesSQL_Obj_R] DEFAULT ((0)) NULL,
    [Obj_NR]     FLOAT (53)  CONSTRAINT [DF_ObjetivosPaisesSQL_Obj_NR] DEFAULT ((0)) NULL,
    [Obj_FI]     FLOAT (53)  CONSTRAINT [DF_ObjetivosPaisesSQL_Obj_FI] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ObjetivosPaisesSQL] PRIMARY KEY CLUSTERED ([CodZona] ASC, [CodSubZona] ASC, [CDPRO] ASC)
);

