CREATE TABLE [dbo].[DirGeneral] (
    [CodDirGeneral]    VARCHAR (3)   NOT NULL,
    [NombreDirGeneral] VARCHAR (100) NOT NULL,
    [Orden]            INT           NULL,
    CONSTRAINT [PK_DirGeneral] PRIMARY KEY CLUSTERED ([CodDirGeneral] ASC)
);

