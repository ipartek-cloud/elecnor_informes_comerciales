CREATE PROCEDURE [dbo].[spContratacion_Internacional]
    @pAño INT,
    @pMes INT
AS
BEGIN
    SET NOCOUNT ON;
    
    CREATE TABLE #ContratacionInternacional
    (
        CodProv                               VARCHAR(2),
        Pais                                  VARCHAR(50),
        ImporteContratadoAcumulado            DECIMAL(18, 4), 
        ImporteContratadoAcumuladoAñoAnterior DECIMAL(18, 4),
        Ajuste                                BIT
    );	
    CREATE CLUSTERED INDEX CIX_ContInt ON #ContratacionInternacional (CodProv, Pais, Ajuste);
  
    INSERT INTO #ContratacionInternacional(CodProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)

    -- 1) OFERTAS
    SELECT
        v.CodProv,
        v.Pais,
        SUM(v.ImporteContratado),
        0,
        0
    FROM dbo.vwOfertasInternacional AS v
    INNER JOIN dbo.Sumarigrama      AS s ON s.CodCentro = v.CodCentro
    WHERE 
			  v.AñoAdjudicacion = @pAño
		  AND v.MesAdjudicacion  <= @pMes
		  AND v.Adjudicada        = 'S'
    GROUP BY v.CodProv, v.Pais

    UNION ALL

    -- 2) REGULARIZACIONES
    SELECT
        r.CodProv,
        r.Pais,
        SUM(r.ImporteContratado),
        0,
        0
    FROM dbo.vwRegularizacionesInternacional AS r
    INNER JOIN dbo.Sumarigrama               AS s ON s.CodCentro = r.CodCentro
    WHERE 
			r.AñoAdjudicacion = @pAño
		AND r.MesAdjudicacion  <= @pMes
    GROUP BY r.CodProv, r.Pais

    UNION ALL

    -- 3) OFERTASSQL
    SELECT
        o.CodProv,
        pi.NMPRO,
        SUM(o.ImporteContratado),
        0,
        0
    FROM dbo.OfertasSQL               AS o
    INNER JOIN dbo.ProvinciasInternacional AS pi ON pi.CDPRO   = o.CodProv
    INNER JOIN dbo.Sumarigrama            AS s  ON s.CodCentro = o.CodCentro
    WHERE 
			o.AñoAdjudicacion = @pAño
		AND o.FAdjudicacion < DATEADD(MONTH, @pMes, DATEFROMPARTS(@pAño, 1, 1))
    GROUP BY o.CodProv, pi.NMPRO

    UNION ALL

    -- 4) OFERTASSQL_AJUSTES
    SELECT
        a.CodProv,
        pi.NMPRO,
        SUM(a.Importe),
        0,
        1                            -- Ajuste = 1
    FROM dbo.OfertasSQL_Ajustes       AS a
    INNER JOIN dbo.ProvinciasInternacional AS pi ON pi.CDPRO = a.CodProv
    WHERE 
			a.AñoAdjudicacion = @pAño
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