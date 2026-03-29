CREATE TABLE [dbo].[SubDirGeneral] (
    [CodDirGeneral]       VARCHAR (3)   NOT NULL,
    [CodSubDirGeneral]    VARCHAR (3)   NOT NULL,
    [NombreSubDirGeneral] VARCHAR (100) NULL,
    [Orden]               INT           NULL,
    CONSTRAINT [PK_SubDirGeneral] PRIMARY KEY CLUSTERED ([CodDirGeneral] ASC, [CodSubDirGeneral] ASC),
    CONSTRAINT [FK_SubDirGeneral_DirGeneral] FOREIGN KEY ([CodDirGeneral]) REFERENCES [dbo].[DirGeneral] ([CodDirGeneral])
);

