
--EXEC spWEB_ContratacionAsociadoInversion 2026,3

CREATE OR ALTER PROCEDURE [dbo].[spWEB_ContratacionAsociadoInversion]
    @pAño          INT,
    @pMes          INT,
    @LoginUsuario  NVARCHAR(100) = 'ACCESS'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @vContratacionMensual_Nacional_AsociadaInversion                    FLOAT
    DECLARE @vContratacionMensual_Internacional_AsociadaInversion               FLOAT
    DECLARE @vContratacionAcumulada_Nacional_AsociadaInversion                  FLOAT
    DECLARE @vContratacionAcumulada_Internacional_AsociadaInversion             FLOAT
    DECLARE @vContratacionAcumulada_Nacional_AsociadaInversion_AnoAnterior      FLOAT
    DECLARE @vContratacionAcumulada_Internacional_AsociadaInversion_AnoAnterior FLOAT

    SELECT @vContratacionMensual_Nacional_AsociadaInversion                    = 0
    SELECT @vContratacionMensual_Internacional_AsociadaInversion               = 0
    SELECT @vContratacionAcumulada_Nacional_AsociadaInversion                  = 0
    SELECT @vContratacionAcumulada_Internacional_AsociadaInversion             = 0
    SELECT @vContratacionAcumulada_Nacional_AsociadaInversion_AnoAnterior      = 0
    SELECT @vContratacionAcumulada_Internacional_AsociadaInversion_AnoAnterior = 0

	--DELETE FROM rptContratacionAsociadoInversion

    -- Eliminar si quedó huérfana de una ejecución anterior fallida
    IF OBJECT_ID('tempdb..#tResultado') IS NOT NULL
        DROP TABLE #tResultado

    CREATE TABLE #tResultado (Valor FLOAT)

    ----------------------------------------------------------
    -- BLOQUE RLS: Filtrado de seguridad por centro del usuario
    ----------------------------------------------------------
    CREATE TABLE #Sumarigrama
    (
        Año                     smallint      not null,
        CodDirGeneral           varchar(3),
        NombreDirGeneral        nvarchar(100) not null,
        CodSubDirGeneral        varchar(3),
        NombreSubDirGeneral     nvarchar(100) not null,
        CodDDirNegocio          varchar(3),
        NombreDirNegocio        nvarchar(30)  not null,
        CodSubDirNegocioArea    varchar(3),
        NombreSubDirNegocioArea nvarchar(100) not null,
        CodDelegacion           varchar(3),
        NombreDelegacion        nvarchar(30)  not null,
        CodCentro               varchar(3),
        NombreCentro            nvarchar(30)  not null,
        OrdenSubDirGeneral      int           not null
    )

    INSERT INTO #Sumarigrama
    SELECT * FROM Sumarigrama

    IF @LoginUsuario IS NOT NULL
    BEGIN
        DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20)

        SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad
        FROM dbo.WEB_Usuarios WITH (NOLOCK)
        WHERE Usuario = @LoginUsuario

        IF @vPuesto IS NOT NULL AND @vPuesto <> 'DG'
        BEGIN
            DELETE FROM #Sumarigrama
            WHERE NOT (
                (@vPuesto = 'SDG'  AND CodSubDirGeneral = @vCodEntidad) OR
                (@vPuesto = 'DN'   AND CodDDirNegocio = @vCodEntidad) OR
                (@vPuesto = 'AREA' AND CodSubDirNegocioArea = @vCodEntidad) OR
                (@vPuesto = 'DEL'  AND CodDelegacion = @vCodEntidad) OR
                (@vPuesto = 'CT'   AND CodCentro = @vCodEntidad)
            )
        END
    END
    -- ═══════════════════════════════════════════════════════════════

    BEGIN TRY

        -- =====================================================================
        -- CONTRATACION MENSUAL NACIONAL
        -- =====================================================================
        TRUNCATE TABLE #tResultado
        INSERT INTO #tResultado (Valor)
            EXEC dbo.spContratacionMensualAsociadaInversion 'Nacional', @pAño, @pMes, @LoginUsuario

        SELECT @vContratacionMensual_Nacional_AsociadaInversion =
               dbo.fgRedondear(Valor / 1000.0, 0)
        FROM   #tResultado

        -- =====================================================================
        -- CONTRATACION MENSUAL INTERNACIONAL
        -- =====================================================================
        TRUNCATE TABLE #tResultado
        INSERT INTO #tResultado (Valor)
            EXEC dbo.spContratacionMensualAsociadaInversion 'Internacional', @pAño, @pMes, @LoginUsuario

        SELECT @vContratacionMensual_Internacional_AsociadaInversion =
               dbo.fgRedondear(Valor / 1000.0, 0)
        FROM   #tResultado

        -- =====================================================================
        -- CONTRATACION ACUMULADA NACIONAL
        -- =====================================================================
        TRUNCATE TABLE #tResultado
        INSERT INTO #tResultado (Valor)
            EXEC dbo.spContratacionMensualAsociadaInversionAcumulada 'Nacional', @pAño, @pMes, @LoginUsuario

        SELECT @vContratacionAcumulada_Nacional_AsociadaInversion =
               dbo.fgRedondear(Valor / 1000.0, 0)
        FROM   #tResultado

        -- =====================================================================
        -- CONTRATACION ACUMULADA INTERNACIONAL
        -- =====================================================================
        TRUNCATE TABLE #tResultado
        INSERT INTO #tResultado (Valor)
            EXEC dbo.spContratacionMensualAsociadaInversionAcumulada 'Internacional', @pAño, @pMes, @LoginUsuario

        SELECT @vContratacionAcumulada_Internacional_AsociadaInversion =
               dbo.fgRedondear(Valor / 1000.0, 0)
        FROM   #tResultado

        -- =====================================================================
        -- CONTRATACION ACUMULADA AÑO ANTERIOR (con RLS por centro)
        -- =====================================================================
        SELECT @vContratacionAcumulada_Nacional_AsociadaInversion_AnoAnterior =
               dbo.fgRedondear(ISNULL(SUM(hc.Importe), 0) / 1000.0, 0)
        FROM   dbo.HistoricoContratacionGrupoSQL hc
               INNER JOIN #Sumarigrama s ON hc.CodCentro = s.CodCentro
               INNER JOIN dbo.OfertaAsociadaInversion oa ON hc.CodOferta = oa.JVAYNB
        WHERE  hc.Año = @pAño - 1
          AND  hc.Mes <= @pMes
          AND  hc.Mercado = 'Nacional'

        SELECT @vContratacionAcumulada_Internacional_AsociadaInversion_AnoAnterior =
               dbo.fgRedondear(ISNULL(SUM(hc.Importe), 0) / 1000.0, 0)
        FROM   dbo.HistoricoContratacionGrupoSQL hc
               INNER JOIN #Sumarigrama s ON hc.CodCentro = s.CodCentro
               INNER JOIN dbo.OfertaAsociadaInversion oa ON hc.CodOferta = oa.JVAYNB
        WHERE  hc.Año = @pAño - 1
          AND  hc.Mes <= @pMes
          AND  hc.Mercado = 'Internacional'

        -- =====================================================================
        -- INSERTS FINALES
        -- =====================================================================

        -- Contratacion NACIONAL
        INSERT INTO rptContratacionAsociadoInversion
            (Año, Mensual_Contratacion, Mercado, Acumulado_Contratacion, Acumulado_ContratacionAñoAnterior, LoginUsuario)
        VALUES
            (YEAR(GETDATE()),
             @vContratacionMensual_Nacional_AsociadaInversion,
             'Nacional',
             @vContratacionAcumulada_Nacional_AsociadaInversion,
             @vContratacionAcumulada_Nacional_AsociadaInversion_AnoAnterior,
             @LoginUsuario)

        -- Contratacion INTERNACIONAL
        INSERT INTO rptContratacionAsociadoInversion
            (Año, Mensual_Contratacion, Mercado, Acumulado_Contratacion, Acumulado_ContratacionAñoAnterior, LoginUsuario)
        VALUES
            (YEAR(GETDATE()),
             @vContratacionMensual_Internacional_AsociadaInversion,
             'Internacional',
             @vContratacionAcumulada_Internacional_AsociadaInversion,
             @vContratacionAcumulada_Internacional_AsociadaInversion_AnoAnterior,
             @LoginUsuario)

    END TRY
    BEGIN CATCH
        DECLARE @ErrNum  INT            = ERROR_NUMBER()
        DECLARE @ErrMsg  NVARCHAR(4000) = ERROR_MESSAGE()

    IF OBJECT_ID('tempdb..#tResultado') IS NOT NULL
        DROP TABLE #tResultado
    IF OBJECT_ID('tempdb..#Sumarigrama') IS NOT NULL
        DROP TABLE #Sumarigrama

    RAISERROR('Error %d: %s', 16, 1, @ErrNum, @ErrMsg)
    RETURN
END CATCH

IF OBJECT_ID('tempdb..#tResultado') IS NOT NULL
    DROP TABLE #tResultado
IF OBJECT_ID('tempdb..#Sumarigrama') IS NOT NULL
    DROP TABLE #Sumarigrama

END
