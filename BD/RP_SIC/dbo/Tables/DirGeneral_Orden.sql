CREATE TABLE [dbo].[DirGeneral_Orden] (
    [CodDirGeneral]    NVARCHAR (255) NOT NULL,
    [NombreDirGeneral] NVARCHAR (255) NOT NULL,
    [Orden]            INT            NOT NULL,
    CONSTRAINT [PK_DirGeneral_Orden] PRIMARY KEY CLUSTERED ([CodDirGeneral] ASC)
);

