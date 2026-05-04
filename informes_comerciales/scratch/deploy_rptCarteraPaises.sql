IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises] (
        [AnioInforme] INT NOT NULL,
        [MesInforme] INT NOT NULL,
        [Pais] NVARCHAR(255) NULL,
        [NomCliente] NVARCHAR(500) NULL,
        [DesOferta] NVARCHAR(MAX) NULL,
        [ImporteCarteraOferta] DECIMAL(18,2) NULL,
        [ImporteContratadoOferta] DECIMAL(18,2) NULL,
        [ImporteCarteraPais] DECIMAL(28,5) NULL
    )
END;

TRUNCATE TABLE [dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises];

INSERT INTO [dbo].[rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises] 
([AnioInforme], [MesInforme], [Pais], [NomCliente], [DesOferta], [ImporteCarteraOferta], [ImporteContratadoOferta], [ImporteCarteraPais])
VALUES 
(2025, 12, 'España', 'GENERACION EOLICA CASTILLA LA MANCHA S.A.', 'FV Hibridación Gecama', 47452, 10890, 860675.33894),
(2025, 12, 'España', 'ADIF ALTA VELOCIDAD', 'Proy. constructivo de las instalaciones de línea aérea de contacto...', 19166, 0, 860675.33894),
(2025, 12, 'Letonia', 'RB Rail AS', 'RAIL BALTICA ENERGY SUBSYSTEM DESIGN AND BUILD', 467186, 7472, 467186.50700),
(2025, 12, 'Estados Unidos', 'PSE&G', 'Obras varias Hawkeye', 166582, 0, 353937.77600),
(2025, 12, 'Brasil', 'ISA CTEEP &#26; COMPANHIA DE', 'Lote 7 del Leilão 01/2023 LT y subestaciones', 87780, 42970, 314422.10700),
(2025, 12, 'Chile', 'ATLAS RENEWABLE ENERGY', 'COPIAPÓ PV + BESS', 59693, 8000, 186234.98400),
(2025, 12, 'Angola', 'VOITH HYDRO', 'Serviços de equipo e gestión do acampamento do AH de Caculo Cabaça', 40000, 0, 107055.23400),
(2025, 12, 'Nueva Zelanda', 'HARMONY ENERGY NEW ZEALAND', 'EW TAHUEI', 48946, 80684, 48946.41800),
(2025, 12, 'Dinamarca', 'FEMERN A/S', 'Femern tunnel (Energy)', 18183, 23560, 18183.44900),
(2025, 12, 'Alemania', 'TENNET TSO GMBH', 'LAT380KV AUDORF - KASSOE. LOS 2 (RENOV) Handewitt - Jardelung', 20987, 10, 40545.36800);
