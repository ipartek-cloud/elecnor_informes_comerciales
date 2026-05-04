IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Org_Pais]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Org_Pais] (
        [AnioInforme] INT NOT NULL,
        [MesInforme] INT NOT NULL,
        [Pais] NVARCHAR(255) NULL,
        [CodSubDirGeneral] NVARCHAR(255) NULL,
        [CodDDirNegocio] NVARCHAR(255) NULL,
        [NombreDirNegocio] NVARCHAR(255) NULL,
        [NomCliente] NVARCHAR(500) NULL,
        [DesOferta] NVARCHAR(MAX) NULL,
        [ImporteCarteraOferta] DECIMAL(18,2) NULL,
        [ImporteContratadoOferta] DECIMAL(18,2) NULL,
        [ImporteCarteraDN] DECIMAL(18,2) NULL,
        [ImporteCarteraPais] DECIMAL(28,5) NULL
    )
END;

TRUNCATE TABLE [dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Org_Pais];

INSERT INTO [dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Org_Pais] 
([AnioInforme], [MesInforme], [Pais], [CodSubDirGeneral], [CodDDirNegocio], [NombreDirNegocio], [NomCliente], [DesOferta], [ImporteCarteraOferta], [ImporteContratadoOferta], [ImporteCarteraDN], [ImporteCarteraPais])
VALUES 
(2025, 11, 'Portugal', '', '', '', '', '', 0, 0, 0, 12955.08900),
(2025, 11, 'Australia', '', '', '', '', '', 0, 0, 0, 4538.39500),
(2025, 11, 'Reino Unido', '', '', '', '', '', 0, 0, 0, 4388.54100),
(2025, 11, 'Omán', '', '', '', '', '', 0, 0, 0, 2093.89600),
(2025, 11, 'Zambia', '', '', '', '', '', 0, 0, 0, 1657.06300),
(2025, 11, 'Estados Unidos', '221', '290', 'Norteamérica', 'PSE&G', 'Obras varias Hawkeye', 171778, 0, 364709, 364709.96400),
(2025, 11, 'Estados Unidos', '221', '290', 'Norteamérica', 'CON EDISON', '* Cartera diferida CM 2026. CONED WESTCHERTER GAS 2018', 19500, 303731, 364709, 364709.96400),
(2025, 11, 'Italia', '221', '934', 'Este', 'ENEL DISTRIBUZIONE SPA', '* Cartera diferida CM 2026. JA10164065 - MULTISERVIZIO PROV. AL-AT-BI-VC', 22293, 22293, 160504, 160044.28500),
(2025, 11, 'Brasil', '286', '090', 'Grandes Redes', 'ISA CTEEP &#26; COMPANHIA DE', 'Lote 7 del Leilão 01/2023 LT y subestaciones', 64244, 42970, 551006, 199228.95900),
(2025, 11, 'Chile', '286', '090', 'Grandes Redes', 'CHARRUA TRANSM. ENERGIA', 'TENDIDO SEGUNDO CIRCUITO 500KV CHARRUA - ANCOA', 40749, 0, 551006, 76206.89100);
