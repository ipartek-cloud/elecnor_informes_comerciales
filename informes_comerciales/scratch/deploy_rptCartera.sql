IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rptCartera_Contratacion_Resumen_SDG]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[rptCartera_Contratacion_Resumen_SDG] (
        [Año] SMALLINT NOT NULL,
        [Mes] SMALLINT NOT NULL,
        [CodSubDirGeneral] NVARCHAR(3) NOT NULL,
        [CodDDirNegocio] NVARCHAR(3) NOT NULL,
        [NombreSubDirGeneral] NVARCHAR(255) NULL,
        [DN] NVARCHAR(255) NOT NULL,
        [TotAño] DECIMAL(18,2) NULL,
        [TotAñoAnterior] DECIMAL(18,2) NULL,
        CONSTRAINT [PK_rptCartera_Contratacion_Resumen_SDG] PRIMARY KEY CLUSTERED 
        (
            [Año] ASC,
            [Mes] ASC,
            [CodSubDirGeneral] ASC,
            [CodDDirNegocio] ASC
        )
    )
END;

TRUNCATE TABLE [dbo].[rptCartera_Contratacion_Resumen_SDG];

INSERT INTO [dbo].[rptCartera_Contratacion_Resumen_SDG] ([CodSubDirGeneral], [CodDDirNegocio], [Año], [Mes], [NombreSubDirGeneral], [DN], [TotAño], [TotAñoAnterior])
VALUES 
('221', '290', 2026, 12, 'DG. Elecnor Servicios', 'D. Norteamérica', 0, 353938),
('221', '500', 2026, 12, 'DG. Elecnor Servicios', 'D. Centro', 0, 247690),
('221', '700', 2026, 12, 'DG. Elecnor Servicios', 'D. Sur', 0, 196990),
('221', '934', 2026, 12, 'DG. Elecnor Servicios', 'D. Este', 0, 408153),
('286', '090', 2026, 12, 'DG. Elecnor Proyectos', 'D. Grandes Redes', 0, 550856),
('286', '780', 2026, 12, 'DG. Elecnor Proyectos', 'D. Renovables, Gas y Agua', 0, 187411),
('286', '800', 2026, 12, 'DG. Elecnor Proyectos', 'D. Energía', 0, 1136133);
