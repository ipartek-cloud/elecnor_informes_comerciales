CREATE TABLE [dbo].[ObrasActualesSQL] (
    [idObras] INT             IDENTITY (1, 1) NOT NULL,
    [Año]     INT             NOT NULL,
    [Mes]     INT             NOT NULL,
    [CTR]     CHAR (3)        NOT NULL,
    [OBRA]    CHAR (3)        NOT NULL,
    [OBRAL]   CHAR (2)        NOT NULL,
    [DSOBR]   CHAR (24)       NOT NULL,
    [RSOBR]   CHAR (24)       NOT NULL,
    [CDACT]   CHAR (3)        NOT NULL,
    [FCONT]   NUMERIC (6)     NOT NULL,
    [CDCLI]   CHAR (8)        NOT NULL,
    [PPFAC]   NUMERIC (13, 2) NOT NULL,
    [PCOST]   NUMERIC (13, 2) NOT NULL,
    [SRET]    NUMERIC (13, 2) NOT NULL,
    [SANT]    NUMERIC (13, 2) NOT NULL,
    [SCOMP]   NUMERIC (13, 2) NOT NULL,
    [SMP]     NUMERIC (13, 2) NOT NULL,
    [SMF]     NUMERIC (13, 2) NOT NULL,
    [SML]     NUMERIC (13, 2) NOT NULL,
    [SMMO]    NUMERIC (13, 2) NOT NULL,
    [SMMA]    NUMERIC (13, 2) NOT NULL,
    [SME]     NUMERIC (13, 2) NOT NULL,
    [SMT]     NUMERIC (13, 2) NOT NULL,
    [SMS]     NUMERIC (13, 2) NOT NULL,
    [SMV]     NUMERIC (13, 2) NOT NULL,
    [SMI]     NUMERIC (13, 2) NOT NULL,
    [SMCL]    NUMERIC (13, 2) NOT NULL,
    [SMH]     NUMERIC (13, 2) NOT NULL,
    [SMPR]    NUMERIC (13, 2) NOT NULL,
    [SAP]     NUMERIC (13, 2) NOT NULL,
    [SAF]     NUMERIC (13, 2) NOT NULL,
    [SAL]     NUMERIC (13, 2) NOT NULL,
    [SAMO]    NUMERIC (13, 2) NOT NULL,
    [SAMA]    NUMERIC (13, 2) NOT NULL,
    [SAE]     NUMERIC (13, 2) NOT NULL,
    [SAT]     NUMERIC (13, 2) NOT NULL,
    [SAS]     NUMERIC (13, 2) NOT NULL,
    [SAV]     NUMERIC (13, 2) NOT NULL,
    [SAI]     NUMERIC (13, 2) NOT NULL,
    [SACL]    NUMERIC (13, 2) NOT NULL,
    [SAH]     NUMERIC (13, 2) NOT NULL,
    [SAPR]    NUMERIC (13, 2) NOT NULL,
    [SOP]     NUMERIC (13, 2) NOT NULL,
    [SOF]     NUMERIC (13, 2) NOT NULL,
    [SOL]     NUMERIC (13, 2) NOT NULL,
    [SOMO]    NUMERIC (13, 2) NOT NULL,
    [SOMA]    NUMERIC (13, 2) NOT NULL,
    [SOE]     NUMERIC (13, 2) NOT NULL,
    [SOT]     NUMERIC (13, 2) NOT NULL,
    [SOS]     NUMERIC (13, 2) NOT NULL,
    [SOV]     NUMERIC (13, 2) NOT NULL,
    [SOI]     NUMERIC (13, 2) NOT NULL,
    [SOCL]    NUMERIC (13, 2) NOT NULL,
    [SOH]     NUMERIC (13, 2) NOT NULL,
    [SOPR]    NUMERIC (13, 2) NOT NULL,
    [VPC]     NUMERIC (13, 2) NOT NULL,
    [CC]      NUMERIC (13, 2) NOT NULL,
    [STOBR]   CHAR (1)        NOT NULL,
    [CGC]     CHAR (1)        NOT NULL,
    [CDPRO]   CHAR (2)        NOT NULL,
    CONSTRAINT [PK_ObrasActualesSQL] PRIMARY KEY CLUSTERED ([idObras] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_Año_Mes]
    ON [dbo].[ObrasActualesSQL]([Año] ASC, [Mes] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Obras]
    ON [dbo].[ObrasActualesSQL]([OBRA] ASC, [OBRAL] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Centro]
    ON [dbo].[ObrasActualesSQL]([CTR] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CTR_OBRA_OBRAL]
    ON [dbo].[ObrasActualesSQL]([CTR] ASC, [OBRA] ASC, [OBRAL] ASC)
    INCLUDE([Año], [Mes], [DSOBR], [SOP], [SOF], [SOL], [STOBR]);


GO
CREATE NONCLUSTERED INDEX [ObrasActualesSQL_IX_CTR_OBRA]
    ON [dbo].[ObrasActualesSQL]([Año] ASC, [Mes] ASC)
    INCLUDE([CTR], [OBRA], [OBRAL], [CDCLI]);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ObrasActualesSQL] TO [partnertec]
    AS [dbo];


GO
GRANT VIEW CHANGE TRACKING
    ON OBJECT::[dbo].[ObrasActualesSQL] TO [partnertec]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ObrasActualesSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ObrasActualesSQL] TO [partnertec]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ObrasActualesSQL] TO [USRGPROD]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ObrasActualesSQL] TO [partnertec]
    AS [dbo];

