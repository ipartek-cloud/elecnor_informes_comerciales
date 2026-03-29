CREATE TABLE [dbo].[CO005BPH ] (
    [id]            INT          IDENTITY (1, 1) NOT NULL,
    [Usuario]       VARCHAR (50) NOT NULL,
    [CTRO]          CHAR (3)     NOT NULL,
    [OBRA]          CHAR (3)     NOT NULL,
    [OBRAL]         CHAR (2)     NOT NULL,
    [CDOFT]         CHAR (20)    NOT NULL,
    [FechaApertura] NUMERIC (4)  NULL,
    [FechaCierre]   NUMERIC (4)  NULL,
    [AñoCierre]     INT          NULL,
    CONSTRAINT [PK_CO005BPH_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CO005BPH_Usuario]
    ON [dbo].[CO005BPH ]([Usuario] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CO005BPH_CDOFT]
    ON [dbo].[CO005BPH ]([CDOFT] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CO005BPH_Usuario_AñoCierre]
    ON [dbo].[CO005BPH ]([Usuario] ASC, [AñoCierre] ASC)
    INCLUDE([CTRO], [OBRA], [OBRAL], [CDOFT]);


GO
CREATE NONCLUSTERED INDEX [IX_CO005BPH_Usuario_CTRO_OBRA_OBRAL_AñoCierre]
    ON [dbo].[CO005BPH ]([Usuario] ASC, [CTRO] ASC, [OBRA] ASC, [OBRAL] ASC, [AñoCierre] ASC)
    INCLUDE([CDOFT]);

