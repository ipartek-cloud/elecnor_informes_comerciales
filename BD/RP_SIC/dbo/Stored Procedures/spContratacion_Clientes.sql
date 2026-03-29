
CREATE PROCEDURE [dbo].[spContratacion_Clientes] 		
    @pMercado varchar(50),
    @pAño     int,
    @pMes     int
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla acumuladora de contratación por cliente (*)
    DECLARE @vContratacionClientes TABLE (
        Mercado                               varchar(50),
        Pais                                  varchar(50),
        AsociadaInversion                     numeric(10,0),
        Cliente                               varchar(100),
        ImporteContratadoAcumulado            float,
        ImporteContratadoAcumuladoAñoanterior float,
        ImporteContratadoAcumulado_Ajuste     float
    )

    -- =====================================================
    --  OFERTAS
    --  Lectura única de la vista para año actual y anterior
    -- =====================================================
    IF OBJECT_ID('tempdb..#tmpOfertas') IS NOT NULL
        DROP TABLE #tmpOfertas

    SELECT  Mercado,
            Pais,
            AsociadaInversion,
            NomAgrupado,
            ImporteContratado,
            CodCentro,
            AñoAdjudicacion
    INTO    #tmpOfertas
    FROM    dbo.vwOfertas_AsociadasInversion_Pais_Cliente
    WHERE   AñoAdjudicacion IN (@pAño, @pAño - 1)
      AND   MesAdjudicacion <= @pMes

    CREATE NONCLUSTERED INDEX IX_tmpOfertas_Año_Centro
        ON #tmpOfertas (AñoAdjudicacion, CodCentro)
        INCLUDE (Mercado, Pais, AsociadaInversion, NomAgrupado, ImporteContratado)

    -- Ofertas año actual (con filtro por centro via Sumarigrama)
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  o.Mercado, o.Pais, o.AsociadaInversion, o.NomAgrupado,
            sum(o.ImporteContratado), 0, 0
    FROM    #tmpOfertas            AS o
            INNER JOIN dbo.Sumarigrama AS s ON o.CodCentro = s.CodCentro
    WHERE   o.AñoAdjudicacion = @pAño
    GROUP BY o.Mercado, o.Pais, o.AsociadaInversion, o.NomAgrupado

    -- Ofertas año anterior
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  o.Mercado, o.Pais, o.AsociadaInversion, o.NomAgrupado,
            0, sum(o.ImporteContratado), 0
    FROM    #tmpOfertas AS o
    WHERE   o.AñoAdjudicacion = @pAño - 1
    GROUP BY o.Mercado, o.Pais, o.AsociadaInversion, o.NomAgrupado

    DROP TABLE #tmpOfertas

    -- =====================================================
    --  REGULARIZACIONES
    --  Lectura única de la vista para año actual y anterior
    -- =====================================================
    IF OBJECT_ID('tempdb..#tmpRegularizaciones') IS NOT NULL
        DROP TABLE #tmpRegularizaciones

    SELECT  Mercado,
            Pais,
            AsociadaInversion,
            NomAgrupado,
            ImporteContratado,
            CodCentro,
            AñoAdjudicacion
    INTO    #tmpRegularizaciones
    FROM    dbo.vwRegularizaciones_AsociadasInversion_Pais_Cliente
    WHERE   AñoAdjudicacion IN (@pAño, @pAño - 1)
      AND   MesAdjudicacion <= @pMes

    CREATE NONCLUSTERED INDEX IX_tmpReg_Año_Centro
        ON #tmpRegularizaciones (AñoAdjudicacion, CodCentro)
        INCLUDE (Mercado, Pais, AsociadaInversion, NomAgrupado, ImporteContratado)

    -- Regularizaciones año actual (con filtro por centro via Sumarigrama)
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  r.Mercado, r.Pais, r.AsociadaInversion, r.NomAgrupado,
            sum(r.ImporteContratado), 0, 0
    FROM    #tmpRegularizaciones       AS r
            INNER JOIN dbo.Sumarigrama AS s ON r.CodCentro = s.CodCentro
    WHERE   r.AñoAdjudicacion = @pAño
    GROUP BY r.Mercado, r.Pais, r.AsociadaInversion, r.NomAgrupado

    -- Regularizaciones año anterior
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  r.Mercado, r.Pais, r.AsociadaInversion, r.NomAgrupado,
            0, sum(r.ImporteContratado), 0
    FROM    #tmpRegularizaciones AS r
    WHERE   r.AñoAdjudicacion = @pAño - 1
    GROUP BY r.Mercado, r.Pais, r.AsociadaInversion, r.NomAgrupado

    DROP TABLE #tmpRegularizaciones

    -- =====================================================
    --  OFERTAS SQL - año actual y anterior
    -- =====================================================

    -- Año actual (con filtro por centro via Sumarigrama)
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  dbo.Provincias.Pais, dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado,
            sum(ImporteContratado), 0, 0
    FROM    dbo.OfertasSQL
            INNER JOIN dbo.Provincias              ON dbo.OfertasSQL.CodProv    = dbo.Provincias.CDPRO
            INNER JOIN dbo.Sumarigrama             ON dbo.OfertasSQL.CodCentro  = dbo.Sumarigrama.CodCentro
            LEFT  JOIN dbo.ClientesSQL             ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
            LEFT  JOIN dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta  = dbo.OfertaAsociadaInversion.JVAYNB
    WHERE   AñoAdjudicacion      = @pAño
      AND   month(FAdjudicacion) <= @pMes
    GROUP BY dbo.Provincias.Pais, dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado

    -- Año anterior
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  dbo.Provincias.Pais, dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado,
            0, sum(ImporteContratado), 0
    FROM    dbo.OfertasSQL
            INNER JOIN dbo.Provincias              ON dbo.OfertasSQL.CodProv    = dbo.Provincias.CDPRO
            LEFT  JOIN dbo.ClientesSQL             ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
            LEFT  JOIN dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta  = dbo.OfertaAsociadaInversion.JVAYNB
    WHERE   AñoAdjudicacion      = @pAño - 1
      AND   month(FAdjudicacion) <= @pMes
      AND   reparto               = 0
    GROUP BY dbo.Provincias.Pais, dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado

    -- =====================================================
    --  OFERTAS SQL AJUSTES - año actual y anterior
    -- =====================================================

    -- Año actual
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  dbo.Provincias.Pais, dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado,
            sum(Importe), 0, sum(Importe)
    FROM    dbo.OfertasSQL_Ajustes
            INNER JOIN dbo.Provincias              ON dbo.OfertasSQL_Ajustes.CodProv    = dbo.Provincias.CDPRO
            LEFT  JOIN dbo.ClientesSQL             ON dbo.OfertasSQL_Ajustes.CodCliente = dbo.ClientesSQL.CodCliente
            LEFT  JOIN dbo.OfertaAsociadaInversion ON dbo.OfertasSQL_Ajustes.CodOferta  = dbo.OfertaAsociadaInversion.JVAYNB
    WHERE   AñoAdjudicacion      = @pAño
      AND   month(FAdjudicacion) <= @pMes
    GROUP BY dbo.Provincias.Pais, dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado

    -- Año anterior
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  dbo.Provincias.Pais, dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado,
            0, sum(Importe), sum(Importe)
    FROM    dbo.OfertasSQL_Ajustes
            INNER JOIN dbo.Provincias              ON dbo.OfertasSQL_Ajustes.CodProv    = dbo.Provincias.CDPRO
            LEFT  JOIN dbo.ClientesSQL             ON dbo.OfertasSQL_Ajustes.CodCliente = dbo.ClientesSQL.CodCliente
            LEFT  JOIN dbo.OfertaAsociadaInversion ON dbo.OfertasSQL_Ajustes.CodOferta  = dbo.OfertaAsociadaInversion.JVAYNB
    WHERE   AñoAdjudicacion      = @pAño - 1
      AND   month(FAdjudicacion) <= @pMes
    GROUP BY dbo.Provincias.Pais, dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado

    -- =====================================================
    --  Agrupación final por mercado, país y cliente
    -- =====================================================
    DECLARE @vContratacionClientes_Agrupado TABLE (
        Mercado                               varchar(50),
        Pais                                  varchar(50),
        AsociadaInversion                     float,
        Cliente                               varchar(100),
        ImporteContratadoAcumulado            float,
        ImporteContratadoAcumuladoAñoanterior float,
        ImporteContratadoAcumulado_Ajuste     float
    )

    INSERT INTO @vContratacionClientes_Agrupado
        (Mercado, Pais, AsociadaInversion, Cliente,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior, ImporteContratadoAcumulado_Ajuste)
    SELECT  Mercado,
            dbo.fnPaises(Mercado, Pais)      AS Pais,
            avg(isnull(AsociadaInversion, 0)),
            Cliente,
            sum(ImporteContratadoAcumulado),
            sum(ImporteContratadoAcumuladoAñoanterior),
            sum(ImporteContratadoAcumulado_Ajuste)
    FROM    @vContratacionClientes
    WHERE   Mercado = @pMercado
    GROUP BY Mercado, dbo.fnPaises(Mercado, Pais), Cliente

    -- Resultado final ordenado por visibilidad de cliente e importe
    SELECT  row_number() OVER (
                ORDER BY [dbo].[fnClienteVisible](Cliente) DESC,
                         Sum(ImporteContratadoAcumulado) DESC
            )                                                 AS Row,
            Mercado,
            Pais,
            dbo.fnAI(AsociadaInversion)                       AS AI,
            Cliente,
            Sum(ImporteContratadoAcumulado)                   AS ImporteContratadoAcumulado,
            sum(ImporteContratadoAcumuladoAñoAnterior)        AS ImporteContratadoAcumuladoAñoAnterior,
            sum(ImporteContratadoAcumulado_Ajuste)            AS ImporteContratadoAcumulado_Ajuste
    FROM    @vContratacionClientes_Agrupado
    WHERE   Mercado = @pMercado
    GROUP BY Mercado, Pais, dbo.fnAI(AsociadaInversion), Cliente
    ORDER BY ImporteContratadoAcumulado DESC

END