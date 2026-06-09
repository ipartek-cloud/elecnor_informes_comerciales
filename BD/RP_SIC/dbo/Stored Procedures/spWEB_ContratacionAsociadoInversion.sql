
--EXEC spWEB_ContratacionAsociadoInversion 2026,3

CREATE PROCEDURE [dbo].[spWEB_ContratacionAsociadoInversion]
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

    BEGIN TRY

        -- =====================================================================
        -- CONTRATACION MENSUAL NACIONAL
        -- =====================================================================
        TRUNCATE TABLE #tResultado
        INSERT INTO #tResultado (Valor)
            EXEC dbo.spContratacionMensualAsociadaInversion 'Nacional', @pAño, @pMes

        SELECT @vContratacionMensual_Nacional_AsociadaInversion =
               dbo.fgRedondear(Valor / 1000.0, 0)
        FROM   #tResultado

        -- =====================================================================
        -- CONTRATACION MENSUAL INTERNACIONAL
        -- =====================================================================
        TRUNCATE TABLE #tResultado
        INSERT INTO #tResultado (Valor)
            EXEC dbo.spContratacionMensualAsociadaInversion 'Internacional', @pAño, @pMes

        SELECT @vContratacionMensual_Internacional_AsociadaInversion =
               dbo.fgRedondear(Valor / 1000.0, 0)
        FROM   #tResultado

        -- =====================================================================
        -- CONTRATACION ACUMULADA NACIONAL
        -- =====================================================================
        TRUNCATE TABLE #tResultado
        INSERT INTO #tResultado (Valor)
            EXEC dbo.spContratacionMensualAsociadaInversionAcumulada 'Nacional', @pAño, @pMes

        SELECT @vContratacionAcumulada_Nacional_AsociadaInversion =
               dbo.fgRedondear(Valor / 1000.0, 0)
        FROM   #tResultado

        -- =====================================================================
        -- CONTRATACION ACUMULADA INTERNACIONAL
        -- =====================================================================
        TRUNCATE TABLE #tResultado
        INSERT INTO #tResultado (Valor)
            EXEC dbo.spContratacionMensualAsociadaInversionAcumulada 'Internacional', @pAño, @pMes

        SELECT @vContratacionAcumulada_Internacional_AsociadaInversion =
               dbo.fgRedondear(Valor / 1000.0, 0)
        FROM   #tResultado

        -- =====================================================================
        -- CONTRATACION ACUMULADA AÑO ANTERIOR (directo desde vista)
        -- =====================================================================
        SELECT @vContratacionAcumulada_Nacional_AsociadaInversion_AnoAnterior =
               dbo.fgRedondear(ISNULL(SUM(TotalImporte), 0) / 1000.0, 0)
        FROM   vwHistoricoContratacionGrupoSQL_AsociadaInversion
        WHERE  Año     = @pAño - 1
          AND  Mes    <= @pMes
          AND  Mercado = 'Nacional'

        SELECT @vContratacionAcumulada_Internacional_AsociadaInversion_AnoAnterior =
               dbo.fgRedondear(ISNULL(SUM(TotalImporte), 0) / 1000.0, 0)
        FROM   vwHistoricoContratacionGrupoSQL_AsociadaInversion
        WHERE  Año     = @pAño - 1
          AND  Mes    <= @pMes
          AND  Mercado = 'Internacional'

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

        RAISERROR('Error %d: %s', 16, 1, @ErrNum, @ErrMsg)
        RETURN
    END CATCH

    IF OBJECT_ID('tempdb..#tResultado') IS NOT NULL
        DROP TABLE #tResultado

END
