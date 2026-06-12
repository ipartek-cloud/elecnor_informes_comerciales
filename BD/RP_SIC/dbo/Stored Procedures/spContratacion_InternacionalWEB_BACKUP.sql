CREATE PROCEDURE [dbo].[spContratacion_InternacionalWEB_BACKUP]
    @pAño INT,
    @pMes INT
AS
BEGIN
    -- Informe de Contratación Internacional (uso exclusivo aplicación web).
    -- Fuentes: AS/400 via OPENQUERY (Ofertas + Regularizaciones), OfertasSQL, OfertasSQL_Ajustes.
    -- El filtro FECHAD/FECHAR se envía como literal al AS/400 (formato NUMERIC 1YYMMDD)
    -- para que el motor remoto filtre en origen antes de transferir datos.
    SET NOCOUNT ON;

    -- Rango numérico para filtro en AS/400: 1YYMMDD (ej: 2025/mes3 → 1250101..1250331)
    DECLARE @YY       VARCHAR(2) = RIGHT('0' + CAST(@pAño % 100 AS VARCHAR(2)), 2);
    DECLARE @MM       VARCHAR(2) = RIGHT('0' + CAST(@pMes  AS VARCHAR(2)), 2);
    DECLARE @fechaMin VARCHAR(7) = '1' + @YY + '0101';
    DECLARE @fechaMax VARCHAR(7) = '1' + @YY + @MM + '31';

    CREATE TABLE #ContratacionInternacional
    (
        CodProv                               VARCHAR(2),
        Pais                                  VARCHAR(50),
        ImporteContratadoAcumulado            DECIMAL(18, 4),
        ImporteContratadoAcumuladoAñoAnterior DECIMAL(18, 4),
        Ajuste                                BIT
    );
    CREATE CLUSTERED INDEX CIX_ContInt ON #ContratacionInternacional (CodProv, Pais, Ajuste);

    DECLARE @sql NVARCHAR(MAX);

    -- Ofertas AS/400 (IC09AP): filtro FECHAD + ADELE ejecutado en AS/400
    SET @sql = N'
        INSERT INTO #ContratacionInternacional
               (CodProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)
        SELECT
            pi.CDPRO,
            pi.NMPRO,
            SUM(ISNULL(CAST(of400.PREAD AS DECIMAL(18,4)), 0)),
            0,
            0
        FROM OPENQUERY(SIC, ''
            SELECT CDCEN, PROOF, PREAD
            FROM S44DD901.ICOMERF.IC09AP
            WHERE FECHAD BETWEEN ' + @fechaMin + ' AND ' + @fechaMax + '
              AND ADELE = ''''S''''
        '') AS of400
        INNER JOIN dbo.ProvinciasInternacional pi ON pi.CDPRO    = of400.PROOF
        INNER JOIN dbo.Sumarigrama             s  ON s.CodCentro = of400.CDCEN
        GROUP BY pi.CDPRO, pi.NMPRO';

    EXEC sp_executesql @sql;

    -- Regularizaciones AS/400 (IC10AP + IC09AP): join y filtro FECHAR ejecutados en AS/400
    SET @sql = N'
        INSERT INTO #ContratacionInternacional
               (CodProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)
        SELECT
            pi.CDPRO,
            pi.NMPRO,
            SUM(ISNULL(CAST(reg400.IMPRE AS DECIMAL(18,4)), 0)),
            0,
            0
        FROM OPENQUERY(SIC, ''
            SELECT r.CDCEN, r.IMPRE, o.PROOF
            FROM S44DD901.ICOMERF.IC10AP r
            JOIN S44DD901.ICOMERF.IC09AP o ON r.CDOFT = o.CDOFT
            WHERE r.FECHAR BETWEEN ' + @fechaMin + ' AND ' + @fechaMax + '
        '') AS reg400
        INNER JOIN dbo.ProvinciasInternacional pi ON pi.CDPRO    = reg400.PROOF
        INNER JOIN dbo.Sumarigrama             s  ON s.CodCentro = reg400.CDCEN
        GROUP BY pi.CDPRO, pi.NMPRO';

    EXEC sp_executesql @sql;

    -- Ofertas sistema SQL (OfertasSQL)
    INSERT INTO #ContratacionInternacional
           (CodProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)
    SELECT
        o.CodProv,
        pi.NMPRO,
        SUM(o.ImporteContratado),
        0,
        0
    FROM dbo.OfertasSQL                   AS o
    INNER JOIN dbo.ProvinciasInternacional AS pi ON pi.CDPRO    = o.CodProv
    INNER JOIN dbo.Sumarigrama            AS s  ON s.CodCentro = o.CodCentro
    WHERE o.AñoAdjudicacion = @pAño
      AND o.FAdjudicacion < DATEADD(MONTH, @pMes, DATEFROMPARTS(@pAño, 1, 1))
    GROUP BY o.CodProv, pi.NMPRO;

    -- Ajustes sistema SQL (OfertasSQL_Ajustes)
    INSERT INTO #ContratacionInternacional
           (CodProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)
    SELECT
        a.CodProv,
        pi.NMPRO,
        SUM(a.Importe),
        0,
        1
    FROM dbo.OfertasSQL_Ajustes            AS a
    INNER JOIN dbo.ProvinciasInternacional AS pi ON pi.CDPRO = a.CodProv
    WHERE a.AñoAdjudicacion = @pAño
      AND a.FAdjudicacion < DATEADD(MONTH, @pMes, DATEFROMPARTS(@pAño, 1, 1))
    GROUP BY a.CodProv, pi.NMPRO;

    SELECT
        CodProv,
        Pais,
        ISNULL(SUM(ImporteContratadoAcumulado),            0) AS ImporteContratadoAcumulado,
        ISNULL(SUM(ImporteContratadoAcumuladoAñoAnterior), 0) AS ImporteContratadoAcumuladoAñoAnterior,
        Ajuste
    FROM #ContratacionInternacional
    GROUP BY CodProv, Pais, Ajuste;

    DROP TABLE #ContratacionInternacional;
END
