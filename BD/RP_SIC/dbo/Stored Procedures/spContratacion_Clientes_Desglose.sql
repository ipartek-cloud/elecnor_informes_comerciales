CREATE PROCEDURE [dbo].[spContratacion_Clientes_Desglose] 		
    @pMercado varchar(50),
    @pAño     int,
    @pMes     int
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla acumuladora de contratación por cliente y desglose
    DECLARE @vContratacionClientes TABLE (
        Mercado                               varchar(50),
        Pais                                  varchar(50),
        AsociadaInversion                     numeric(10,0),
        Cliente                               varchar(100),
        ClienteDesglose                       varchar(100),
        ImporteContratadoAcumulado            float,
        ImporteContratadoAcumuladoAñoanterior float
    )

    -- =====================================================
    --  OFERTAS
    --  Lectura única de la vista para año actual y anterior
    -- =====================================================
    IF OBJECT_ID('tempdb..#tmpOfertas_Desglose') IS NOT NULL
        DROP TABLE #tmpOfertas_Desglose

    SELECT  Mercado,
            Pais,
            AsociadaInversion,
            NomAgrupado,
            NomAgrupadoDesglose,
            ImporteContratado,
            CodCentro,
            AñoAdjudicacion
    INTO    #tmpOfertas_Desglose
    FROM    dbo.vwOfertas_AsociadasInversion_Pais_Cliente_Desglose
    WHERE   AñoAdjudicacion IN (@pAño, @pAño - 1)
      AND   MesAdjudicacion <= @pMes

    CREATE NONCLUSTERED INDEX IX_tmpOfertas_Desglose_Año_Centro
        ON #tmpOfertas_Desglose (AñoAdjudicacion, CodCentro)
        INCLUDE (Mercado, Pais, AsociadaInversion, NomAgrupado, NomAgrupadoDesglose, ImporteContratado)

    -- Ofertas año actual (con filtro por centro via Sumarigrama)
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente, ClienteDesglose,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior)
    SELECT  o.Mercado, o.Pais, o.AsociadaInversion, o.NomAgrupado, o.NomAgrupadoDesglose,
            sum(o.ImporteContratado), 0
    FROM    #tmpOfertas_Desglose AS o
            INNER JOIN dbo.Sumarigrama AS s ON o.CodCentro = s.CodCentro
    WHERE   o.AñoAdjudicacion = @pAño
    GROUP BY o.Mercado, o.Pais, o.AsociadaInversion, o.NomAgrupado, o.NomAgrupadoDesglose

    -- Ofertas año anterior (con filtro por centro via Sumarigrama)
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente, ClienteDesglose,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior)
    SELECT  o.Mercado, o.Pais, o.AsociadaInversion, o.NomAgrupado, o.NomAgrupadoDesglose,
            0, sum(o.ImporteContratado)
    FROM    #tmpOfertas_Desglose AS o
            INNER JOIN dbo.Sumarigrama AS s ON o.CodCentro = s.CodCentro
    WHERE   o.AñoAdjudicacion = @pAño - 1
    GROUP BY o.Mercado, o.Pais, o.AsociadaInversion, o.NomAgrupado, o.NomAgrupadoDesglose

    DROP TABLE #tmpOfertas_Desglose

    -- =====================================================
    --  REGULARIZACIONES
    --  Lectura única de la vista para año actual y anterior
    -- =====================================================
    IF OBJECT_ID('tempdb..#tmpRegularizaciones_Desglose') IS NOT NULL
        DROP TABLE #tmpRegularizaciones_Desglose

    SELECT  Mercado,
            Pais,
            AsociadaInversion,
            NomAgrupado,
            NomAgrupadoDesglose,
            ImporteContratado,
            CodCentro,
            AñoAdjudicacion
    INTO    #tmpRegularizaciones_Desglose
    FROM    dbo.vwRegularizaciones_AsociadasInversion_Pais_Cliente_Desglose
    WHERE   AñoAdjudicacion IN (@pAño, @pAño - 1)
      AND   MesAdjudicacion <= @pMes

    CREATE NONCLUSTERED INDEX IX_tmpReg_Año_Centro
        ON #tmpRegularizaciones_Desglose (AñoAdjudicacion, CodCentro)
        INCLUDE (Mercado, Pais, AsociadaInversion, NomAgrupado, NomAgrupadoDesglose, ImporteContratado)

    -- Regularizaciones año actual (con filtro por centro via Sumarigrama)
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente, ClienteDesglose,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior)
    SELECT  r.Mercado, r.Pais, r.AsociadaInversion, r.NomAgrupado, r.NomAgrupadoDesglose,
            sum(r.ImporteContratado), 0
    FROM    #tmpRegularizaciones_Desglose AS r
            INNER JOIN dbo.Sumarigrama AS s ON r.CodCentro = s.CodCentro
    WHERE   r.AñoAdjudicacion = @pAño
    GROUP BY r.Mercado, r.Pais, r.AsociadaInversion, r.NomAgrupado, r.NomAgrupadoDesglose

    -- Regularizaciones año anterior (con filtro por centro via Sumarigrama)
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente, ClienteDesglose,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior)
    SELECT  r.Mercado, r.Pais, r.AsociadaInversion, r.NomAgrupado, r.NomAgrupadoDesglose,
            0, sum(r.ImporteContratado)
    FROM    #tmpRegularizaciones_Desglose AS r
            INNER JOIN dbo.Sumarigrama AS s ON r.CodCentro = s.CodCentro
    WHERE   r.AñoAdjudicacion = @pAño - 1
    GROUP BY r.Mercado, r.Pais, r.AsociadaInversion, r.NomAgrupado, r.NomAgrupadoDesglose

    DROP TABLE #tmpRegularizaciones_Desglose

    -- =====================================================
    --  OFERTAS SQL - año actual y anterior
    -- =====================================================

    -- Año actual (con filtro por centro via Sumarigrama)
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente, ClienteDesglose,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior)
    SELECT  dbo.Provincias.Pais, NMPRO, JVAYNB, NomAgrupado, NomAgrupadoDesglose,
            sum(ImporteContratado), 0
    FROM    dbo.OfertasSQL
            INNER JOIN dbo.Provincias              ON dbo.OfertasSQL.CodProv    = dbo.Provincias.CDPRO
            INNER JOIN dbo.Sumarigrama             ON dbo.OfertasSQL.CodCentro  = dbo.Sumarigrama.CodCentro
            LEFT  JOIN dbo.ClientesSQL             ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
            LEFT  JOIN dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta  = dbo.OfertaAsociadaInversion.JVAYNB
    WHERE   AñoAdjudicacion      = @pAño
      AND   month(FAdjudicacion) <= @pMes
      AND   VisibleDesglose       = 1
    GROUP BY dbo.Provincias.Pais, NMPRO, JVAYNB, NomAgrupado, NomAgrupadoDesglose

    -- Año anterior
    INSERT INTO @vContratacionClientes
        (Mercado, Pais, AsociadaInversion, Cliente, ClienteDesglose,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior)
    SELECT  dbo.Provincias.Pais, NMPRO, JVAYNB, NomAgrupado, NomAgrupadoDesglose,
            0, sum(ImporteContratado)
    FROM    dbo.OfertasSQL
            INNER JOIN dbo.Provincias              ON dbo.OfertasSQL.CodProv    = dbo.Provincias.CDPRO
            LEFT  JOIN dbo.ClientesSQL             ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
            LEFT  JOIN dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta  = dbo.OfertaAsociadaInversion.JVAYNB
    WHERE   AñoAdjudicacion      = @pAño - 1
      AND   month(FAdjudicacion) <= @pMes
      AND   VisibleDesglose       = 1
      AND   reparto               = 0
    GROUP BY dbo.Provincias.Pais, NMPRO, JVAYNB, NomAgrupado, NomAgrupadoDesglose

    -- =====================================================
    --  Agrupación final por mercado, país, cliente y desglose
    -- =====================================================
    DECLARE @vContratacionClientes_Agrupado TABLE (
        Mercado                               varchar(50),
        Pais                                  varchar(50),
        AsociadaInversion                     float,
        Cliente                               varchar(100),
        ClienteDesglose                       varchar(100),
        ImporteContratadoAcumulado            float,
        ImporteContratadoAcumuladoAñoanterior float
    )

    INSERT INTO @vContratacionClientes_Agrupado
        (Mercado, Pais, AsociadaInversion, Cliente, ClienteDesglose,
         ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior)
    SELECT  Mercado,
            dbo.fnPaises(Mercado, Pais) AS Pais,
            avg(isnull(AsociadaInversion, 0)),
            Cliente,
            ClienteDesglose,
            sum(ImporteContratadoAcumulado),
            sum(ImporteContratadoAcumuladoAñoanterior)
    FROM    @vContratacionClientes
    WHERE   Mercado = @pMercado
    GROUP BY Mercado, dbo.fnPaises(Mercado, Pais), Cliente, ClienteDesglose

    -- Resultado final
    SELECT  Mercado,
            Pais,
            dbo.fnAI(AsociadaInversion)                AS AI,
            Cliente,
            ClienteDesglose,
            Sum(ImporteContratadoAcumulado)            AS ImporteContratadoAcumulado,
            sum(ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnterior
    FROM    @vContratacionClientes_Agrupado
    WHERE   Mercado = @pMercado
    GROUP BY Mercado, Pais, dbo.fnAI(AsociadaInversion), Cliente, ClienteDesglose

END
