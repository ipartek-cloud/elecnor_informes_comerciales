using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Dapper;
using Elecnor_Informes_Comerciales.Models.Informes.Gerencias_Totales_Cruces;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosAI;
using elecnor_informes_comerciales.Models.Informes.Mercados;
using Elecnor_Informes_Comerciales.Models.Informes.Paises;
using Elecnor_Informes_Comerciales.Models.Informes.Actividades;
using Elecnor_Informes_Comerciales.Models.Informes.Contrataciones;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionesAI;


namespace Elecnor_Informes_Comerciales.Repositories.Informes;

/// <summary>
/// Repositorio central de informes.
/// </summary>
public class InformeRepository
{
    private readonly IDbConnection _connection;
    private readonly string _connectionString;

    public InformeRepository(IDbConnection connection, IConfiguration configuration)
    {
        _connection = connection;
        _connectionString = configuration.GetConnectionString("DefaultConnection") 
            ?? throw new InvalidOperationException("No se encontró la cadena de conexión 'DefaultConnection'.");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Gerencias Totales Cruces
    // └─ Método: ObtenerGerenciasTotalesCrucesAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos planos para el informe Gerencias Totales Cruces.
    /// </summary>
    public async Task<List<GerenciasTotalesCrucesPoco>> ObtenerGerenciasTotalesCrucesAsync(int anio, int mes)
    {
        // ─── PASO 1: Vaciar la tabla de trabajo ───
        const string sqlDelete = "DELETE FROM rptContratacion_GerenciaCentro";

        // ─── PASO 2: Poblar desde el SP (columnas que devuelve el SP, sin Año) ───
        const string sqlInsertExec = @"INSERT INTO rptContratacion_GerenciaCentro (NombreGerente, CodCentro,ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior)
                                       EXEC spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS @Anio, @Mes";

        // ─── PASO 3: Asignar el año a todas las filas recién insertadas ───
        const string sqlUpdateAnio = "UPDATE rptContratacion_GerenciaCentro SET Año = @Anio";

        // ─── PASO 4: SELECT de datos enriquecidos ───
        const string sqlSelect = @"SELECT
                                        rpt.Año,
                                        cg.Orden,
                                        rpt.NombreGerente,
                                        s.CodDDirNegocio,
                                        s.NombreDirNegocio,
                                        rpt.CodCentro,
                                        s.NombreCentro,
                                        CASE
                                            WHEN cg.Mercado = 'I' THEN 'Internacional'
                                            ELSE 'Nacional'
                                        END AS Mercado,
                                        o.Orden_CodDDirNegocio,
                                        SUM(rpt.ImporteContratado)                     AS ImporteContratadoS,
                                        SUM(rpt.ImporteContratadoAcumulado)            AS ImporteContratadoAcumuladoS,
                                        SUM(rpt.ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnteriorS,
                                        SUM(ISNULL(vw.importe,0))                      AS Objetivos,
                                        SUM(ISNULL(act.CarteraPdteAñoActual,0))        AS CarteraPdteAñoActualS,
                                        SUM(ISNULL(ant.CarteraPdteAñoAnterior,0))      AS CarteraPdteAñoAnteriorS
                                    FROM rptContratacion_GerenciaCentro rpt WITH (NOLOCK)
                                    INNER JOIN Sumarigrama s WITH (NOLOCK)
                                        ON rpt.CodCentro = s.CodCentro
                                    LEFT JOIN Orden_CodDDirNegocio o WITH (NOLOCK)
                                        ON s.CodDDirNegocio = o.CodDDirNegocio
                                    LEFT JOIN dbo.fn_veCarteraPdteProducirSQL_AnioActual(@Anio, @Mes) act
                                        ON rpt.CodCentro = act.CodCentro
                                    LEFT JOIN dbo.fn_veCarteraPdteProducirSQL_AnioAnterior(@Anio, @Mes) ant
                                        ON rpt.CodCentro = ant.CodCentro
                                    INNER JOIN CentrosGerentesSQL cg WITH (NOLOCK)
                                        ON rpt.Año = cg.Año
                                       AND rpt.NombreGerente = cg.NombreGerente
                                       AND rpt.CodCentro = cg.CodCentro
                                    LEFT JOIN vwObjetivosActividadSQL_Nacional_Internacional vw
                                        ON rpt.Año = vw.Año
                                       AND rpt.CodCentro = vw.CodCentro
                                    WHERE s.CodSubDirGeneral = '221'
                                    GROUP BY
                                        rpt.Año, cg.Orden, rpt.NombreGerente,
                                        s.CodDDirNegocio, s.NombreDirNegocio,
                                        rpt.CodCentro, s.NombreCentro,
                                        CASE WHEN cg.Mercado = 'I' THEN 'Internacional' ELSE 'Nacional' END,
                                        o.Orden_CodDDirNegocio";

        var parametros = new { Anio = anio, Mes = mes };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            await _connection.ExecuteAsync(sqlDelete,     transaction: transaction);
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction);
            await _connection.ExecuteAsync(sqlUpdateAnio, parametros, transaction);
            var resultado = (await _connection.QueryAsync<GerenciasTotalesCrucesPoco>(sqlSelect, parametros, transaction)).ToList();

            transaction.Commit();
            return resultado;
        }
        catch
        {
            transaction.Rollback();
            throw;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Contratación Mercados AI (Cartera Diferida)
    // └─ Método: ObtenerContratacionMercadosAIAsync()
    // └─ Subinformes: SubMercadoAI, CarteraProduccion
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos para el informe Contratación Mercados (Consejo Administración), 
    /// su subinforme de inversión y el de cartera.
    /// </summary>
    public async Task<(List<ContratacionMercadosAIPoco> Principal, List<MercadoAIPoco> mercadoAI, List<CarteraProducirPoco> Cartera, List<CarteraDiferidaPoco> CarteraDiferida, List<VentasPoco> Ventas)> ObtenerContratacionMercadosAIAsync(int anio, int mes)
    {
        // ─────────────────────────────────────────────────────────────────────
        // SECCIÓN A: INFORME PRINCIPAL (Mercados por País)
        // ─────────────────────────────────────────────────────────────────────

        // ─── A.1: Vaciar tabla de trabajo ───
        const string sqlDeletePrincipal = "DELETE FROM rptContratacion_DG_SDG_DN_SDNA";

        // ─── A.2: Ejecutar SP y obtener resultados en memoria ───
        const string sqlExecPrincipal = "EXEC spContratacion_DG_SDG_DN_SDNA @Anio, @Mes";

        // ─── A.3: Insertar manualmente en tabla de trabajo ───
        const string sqlInsertManualPrincipal = @"INSERT INTO rptContratacion_DG_SDG_DN_SDNA (Año, CodSubDirGeneral, NombreSubDirGeneral, NombreDirNegocio, NombreSubDirNegocioArea, Pais, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteObjetivo)
                                                VALUES (@Anio, @CodSubDirGeneral, @NombreSubDirGeneral, @NombreDirNegocio, @NombreSubDirNegocioArea, @Pais, @ImporteContratado, @ImporteContratadoAcumulado, @ImporteContratadoAcumuladoAñoAnterior, @ImporteObjetivo)";

        // ─── A.4: SELECT enriquecido ───
        const string sqlSelectPrincipal = @"SELECT
                                                c.Año,
                                                c.Pais,
                                                SUM(c.ImporteContratado)                        AS Importe_Contratado,
                                                SUM(c.ImporteContratadoAcumulado)               AS Importe_ContratadoAcumulado,
                                                SUM(c.ImporteContratadoAcumuladoAñoAnterior)    AS ImporteContratadoAcumuladoAñoAnterior,
                                                o.Importe                                       AS Objetivos,
                                                dbo.fgRedondear(o.Importe / 12, 0)              AS ObjetivosMensual  
                                            FROM
                                                vwObjetivosSQL_Mercado AS o
                                            INNER JOIN 
                                                rptContratacion_DG_SDG_DN_SDNA AS c  
                                            ON  
                                                    o.Mercado = c.Pais
                                                AND o.Año = c.Año
                                            GROUP BY c.Año, c.Pais, o.Importe;";

        // ─────────────────────────────────────────────────────────────────────
        // SECCIÓN B: SUBINFORME MercadoAI (Asociado Inversión)
        // ─────────────────────────────────────────────────────────────────────

        // ─── B.1: Vaciar tabla de trabajo ───
        const string sqlDeleteSub = "DELETE FROM rptContratacionAsociadoInversion";

        // ─── B.2: Poblar desde SP ───
        const string sqlInsertExecSub = "EXEC spWEB_ContratacionAsociadoInversion @Anio, @Mes";

        // ─── B.3: Asignar año ───
        const string sqlUpdateAnioSub = "UPDATE rptContratacionAsociadoInversion SET Año = @Anio";

        // ─── B.4: SELECT enriquecido ───
        const string sqlSelectMercadoAI = @" SELECT
                                                r.Año,
                                                r.Mensual_Contratacion,
                                                r.Mercado,
                                                r.Acumulado_Contratacion,
                                                r.Acumulado_ContratacionAñoAnterior,
                                                CASE
                                                    WHEN ISNULL(v.ImporteContratadoAcumuladoSUMA, 0) = 0 THEN 0
                                                    ELSE r.Acumulado_Contratacion / v.ImporteContratadoAcumuladoSUMA
                                                END AS Mer
                                            FROM 
                                                rptContratacionAsociadoInversion r
                                            INNER JOIN 
                                                vwMercadoImporteContratacionAcumulado v 
                                            ON 
                                                r.Mercado = v.Mercado";

        // ─────────────────────────────────────────────────────────────────────
        // SECCIÓN C: SUBINFORME CarteraProduccion (Cartera Pendiente Producir)
        // ─────────────────────────────────────────────────────────────────────

        // ─── C.1: SELECT directo (sin tabla de trabajo) ───
        const string sqlSelectCartera = @"  SELECT Año, Mes, Concepto, ImporteInicial, ImporteActual, PorcentajeIncrementoAñoAnterior, SumarCartera, CarteraAñoAnterior
                                            FROM CarteraActual_CJO
                                            WHERE Año = @Anio AND Mes = @Mes";

        // ─────────────────────────────────────────────────────────────────────
        // SECCIÓN D: SUBINFORME CarteraDiferida (Cartera Diferida - Consejo)
        // ─────────────────────────────────────────────────────────────────────

        // El usuario requiere años FIJOS en el layout (1.1.25, 2025, 2026, 2027) independientemente del año de reporte
        const string sqlSelectDiferida = @"SELECT Año, Mes, Mercado, [Cartera Diferida] AS CarteraDiferida, [01#01#25] AS Cart1_1, Nuevos, Total, Contr, [2025] AS Anio1, [2026] AS Anio2, [2027] AS Anio3, Orden
                                           FROM CarteraDiferida_CJO
                                           WHERE Mercado = 'Mercado' AND Año = @Anio AND Mes = @Mes";

        // ─────────────────────────────────────────────────────────────────────────────────
        // SECCIÓN E: SUBINFORME Ventas (lectura directa de VentasRPT, sin tabla de trabajo)
        // ─────────────────────────────────────────────────────────────────────────────────

        // Los alias mapean las columnas numéricas [XXXX] a las propiedades del POCO (sin caracteres reservados)
        const string sqlSelectVentas = @"SELECT
                                            Mercado,
                                            [2017] AS Anio2017,
                                            [2018] AS Anio2018,
                                            [2019] AS Anio2019,
                                            [2020] AS Anio2020,
                                            [2021] AS Anio2021,
                                            [2022] AS Anio2022,
                                            [2023] AS Anio2023,
                                            [2024] AS Anio2024,
                                            [2025] AS Anio2025
                                         FROM VentasRPT
                                         ORDER BY Mercado";

        // ─────────────────────────────────────────────────────────────────────────────────
        // ─────────────────────────────────────────────────────────────────────────────────

        var parametros = new { Anio = anio, Mes = mes };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            // ── Ejecución Sección A: Informe Principal ──
            var datosSp = (await _connection.QueryAsync<dynamic>(sqlExecPrincipal, parametros, transaction: transaction)).ToList();
            await _connection.ExecuteAsync(sqlDeletePrincipal, transaction: transaction);
            
            foreach (var fila in datosSp)
            {
                await _connection.ExecuteAsync(sqlInsertManualPrincipal, new {
                    Anio = anio,
                    CodSubDirGeneral = fila.CodSubDirGeneral,
                    NombreSubDirGeneral = fila.NombreSubDirGeneral,
                    NombreDirNegocio = fila.NombreDirNegocio,
                    NombreSubDirNegocioArea = fila.NombreSubDirNegocioArea,
                    Pais = fila.Pais,
                    ImporteContratado = fila.ImporteContratado,
                    ImporteContratadoAcumulado = fila.ImporteContratadoAcumulado,
                    ImporteContratadoAcumuladoAñoAnterior = fila.ImporteContratadoAcumuladoAñoAnterior,
                    ImporteObjetivo = fila.ImporteObjetivo
                }, transaction: transaction);
            }

            var principal = (await _connection.QueryAsync<ContratacionMercadosAIPoco>(sqlSelectPrincipal, parametros, transaction)).ToList();

            // ── Ejecución Sección B: MercadoAI ──
            await _connection.ExecuteAsync(sqlDeleteSub, transaction: transaction);
            await _connection.ExecuteAsync(sqlInsertExecSub, parametros, transaction: transaction);
            await _connection.ExecuteAsync(sqlUpdateAnioSub, parametros, transaction: transaction);
            var mercadoAI = (await _connection.QueryAsync<MercadoAIPoco>(sqlSelectMercadoAI, parametros, transaction)).ToList();

            // ── Ejecución Sección C: CarteraProduccion ──
            var cartera = (await _connection.QueryAsync<CarteraProducirPoco>(sqlSelectCartera, parametros, transaction)).ToList();

            // ── Ejecución Sección D: CarteraDiferida ──
            var carteraDiferida = (await _connection.QueryAsync<CarteraDiferidaPoco>(sqlSelectDiferida, parametros, transaction)).ToList();

            // ── Ejecución Sección E: Ventas (lectura directa) ──
            var ventas = (await _connection.QueryAsync<VentasPoco>(sqlSelectVentas, transaction: transaction)).ToList();

            transaction.Commit();

            return (principal, mercadoAI, cartera, carteraDiferida, ventas);
        }
        catch
        {
            transaction.Rollback();
            throw;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Mercados
    // └─ Método: ObtenerMercadosAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    public async Task<List<MercadosPoco>> ObtenerMercadosAsync(int anio, int mes)
    {
        // ─── PASO 1: Vaciar la tabla de trabajo ───
        const string sqlDelete = "DELETE FROM rptContratacion_DG_SDG_DN_SDNA";

        // ─── PASO 2: Ejecutar Procedimiento Almacenado en Memoria ───
        const string sqlExec = "EXEC spContratacion_DG_SDG_DN_SDNA @Anio, @Mes";

        // ─── PASO 3: Insertar manualmente en tabla de trabajo ───
        const string sqlInsertManual = @"INSERT INTO rptContratacion_DG_SDG_DN_SDNA (Año, CodSubDirGeneral, NombreSubDirGeneral, NombreDirNegocio, NombreSubDirNegocioArea, Pais, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteObjetivo)
                                         VALUES (@Anio, @CodSubDirGeneral, @NombreSubDirGeneral, @NombreDirNegocio, @NombreSubDirNegocioArea, @Pais, @ImporteContratado, @ImporteContratadoAcumulado, @ImporteContratadoAcumuladoAñoAnterior, @ImporteObjetivo)";

        // ─── PASO 4: SELECT final con JOIN a objetivos
        const string sqlSelect = @" SELECT
                                        rpt.Año,
                                        MAX(sg.Orden) AS Orden,
                                        rpt.Pais,
                                        rpt.NombreSubDirGeneral,
                                        rpt.NombreDirNegocio,
                                        SUM(rpt.ImporteContratado) AS ImporteContratado,
                                        SUM(rpt.ImporteContratadoAcumulado) AS ImporteContratadoAcumulado,
                                        SUM(rpt.ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnterior,
                                        MAX(ISNULL(rpt.ImporteObjetivo, 0)) AS ImporteObjetivo,
                                        MAX(ISNULL(obj.Importe, 0)) AS ObjetivoSDGPais,
                                        MAX(ISNULL(vw_m.Importe, 0)) AS ObjetivoPais
                                    FROM rptContratacion_DG_SDG_DN_SDNA rpt WITH (NOLOCK)
                                    LEFT JOIN ObjetivosSQL obj WITH (NOLOCK)
                                        ON obj.Año = rpt.Año
                                       AND obj.CodSubDirGeneral = rpt.CodSubDirGeneral
                                       AND obj.Mercado = rpt.Pais
                                    LEFT JOIN vwObjetivosMercadoSQL vw_m
                                        ON vw_m.Año = rpt.Año
                                       AND vw_m.Mercado = rpt.Pais
                                    LEFT JOIN SubDirGeneral sg WITH (NOLOCK)
                                        ON rpt.CodSubDirGeneral = sg.CodSubDirGeneral
                                    GROUP BY
                                        rpt.Año,
                                        rpt.Pais,
                                        rpt.NombreSubDirGeneral,
                                        rpt.NombreDirNegocio";

        var parametros = new { Anio = anio, Mes = mes };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            // Ejecutar SP para conseguir los datos
            var datosSp = (await _connection.QueryAsync<dynamic>(sqlExec, parametros, transaction: transaction)).ToList();
            
            // Vaciar la tabla para la sesión principal
            await _connection.ExecuteAsync(sqlDelete, transaction: transaction);
            
            // Insertar fila a fila inyectando el periodo actual
            foreach (var fila in datosSp)
            {
                await _connection.ExecuteAsync(sqlInsertManual, new {
                    Anio = anio,
                    CodSubDirGeneral = fila.CodSubDirGeneral,
                    NombreSubDirGeneral = fila.NombreSubDirGeneral,
                    NombreDirNegocio = fila.NombreDirNegocio,
                    NombreSubDirNegocioArea = fila.NombreSubDirNegocioArea,
                    Pais = fila.Pais,
                    ImporteContratado = fila.ImporteContratado,
                    ImporteContratadoAcumulado = fila.ImporteContratadoAcumulado,
                    ImporteContratadoAcumuladoAñoAnterior = fila.ImporteContratadoAcumuladoAñoAnterior,
                    ImporteObjetivo = fila.ImporteObjetivo
                }, transaction: transaction);
            }

            // Consultar datos agrupados de la tabla temporal
            var resultado = (await _connection.QueryAsync<MercadosPoco>(sqlSelect, parametros, transaction)).ToList();

            transaction.Commit();
            return resultado;
        }
        catch
        {
            transaction.Rollback();
            throw;
        }
    }
    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Países (Mercado Internacional)
    // └─ Método: ObtenerPaisesAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos para el informe de Países (Internacional).
    /// </summary>
    public async Task<List<PaisesPoco>> ObtenerPaisesAsync(int anio, int mes)
    {
        // ─── PASO 1: Vaciar la tabla de trabajo ───
        const string sqlDelete = "DELETE FROM rptContratacion_Internacional";

        // ─── PASO 2: Poblado automático vía SP (el SP original de Access) ───
        // Sincronizado con las 5 columnas que devuelve el SP (según inspección)
        const string sqlInsertExec = @" 
            INSERT INTO rptContratacion_Internacional (codProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)
            EXEC spContratacion_Internacional @Anio, @Mes";

        // Asignamos el Año (campo extra) para que el SELECT lo encuentre
        const string sqlUpdateAnio = "UPDATE rptContratacion_Internacional SET Año = @Anio WHERE Año IS NULL";

        // ─── PASO 3: Selección optimizada (Año Actual vs Histórico Año Anterior) ───
        const string sqlSelect = @" SELECT
                                        @Anio AS Año,
                                        t.Pais,
                                        SUM(t.ImpActual) AS ImporteContratadoAcumulado,
                                        SUM(t.ImpAnterior) AS ImporteContratadoAcumuladoAñoAnterior,
                                        MAX(t.Ajuste) AS Ajuste,
                                        CASE WHEN SUM(t.ImpAnterior) = 0 THEN '*' ELSE '' END AS SinContratacionAñoAnterior,
                                        MAX(t.Orden) AS OrdenAñoAnterior
                                    FROM (

                                            SELECT
                                                Pais,
                                                dbo.fgRedondear(ISNULL(ImporteContratadoAcumulado, 0), 2) AS ImpActual,
                                                0 AS ImpAnterior,
                                                Ajuste,
                                                0 AS Orden
                                            FROM rptContratacion_Internacional WITH (NOLOCK)
                                            WHERE Año = @Anio

                                        UNION ALL

                                            SELECT
                                                ISNULL(p.NMPRO, 'OTROS') AS Pais,
                                                0 AS ImpActual,
                                                ISNULL(h.Importe, 0) AS ImpAnterior,
                                                0 AS Ajuste,
                                                ISNULL(h.Orden, 0) AS Orden
                                            FROM HistoricoContratacionSQL h WITH (NOLOCK)
                                            LEFT JOIN ProvinciasInternacional p WITH (NOLOCK) ON h.CodProv = p.CDPRO
                                            WHERE h.Año = @Anio - 1
                                    ) AS t
                                    GROUP BY t.Pais
                                    ORDER BY ImporteContratadoAcumulado DESC";

        var parametros = new { Anio = anio, Mes = mes };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            await _connection.ExecuteAsync(sqlDelete, transaction: transaction);
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 60);
            await _connection.ExecuteAsync(sqlUpdateAnio, parametros, transaction: transaction);
            
            var resultado = (await _connection.QueryAsync<PaisesPoco>(sqlSelect, parametros, transaction: transaction)).ToList();

            transaction.Commit();
            return resultado;
        }
        catch (Exception)
        {
            transaction.Rollback();
            throw;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Actividades
    // └─ Método: ObtenerActividadesAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos para el informe de Actividades.
    /// </summary>
    public async Task<List<ActividadPoco>> ObtenerActividadesAsync(int anio, int mes)
    {
        const string sqlDelete = "DELETE FROM rptContratacion_Actividad";

        const string sqlInsertExec = @" INSERT INTO rptContratacion_Actividad (NombreDirGeneral, Pais, CodActividad, Actividad, Orden, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteContratadoAcumuladoLastYear)
                                        EXEC spContratacion_Actividades_Ajuste @Anio, @Mes";

        // Inyectamos el Año como campo extra (estándar del proyecto)
        const string sqlUpdateAnio = "UPDATE rptContratacion_Actividad SET Año = @Anio WHERE Año IS NULL";

        const string sqlSelect = @";WITH vwActividades AS (
	                                    SELECT DISTINCT
		                                    p.Pais,
		                                    a.Agrupacion,
		                                    a.Orden
	                                    FROM ActividadesSQL a WITH (NOLOCK)
	                                    CROSS JOIN Pais p WITH (NOLOCK))
                                    SELECT
                                        a.Pais,
                                        a.Agrupacion                                        AS Actividad,
                                        MAX(c.Año)                                          AS Año,
                                        isnull(Sum([ImporteContratadoAcumulado]),           0)  AS ImporteContratadoAcumulados,
                                        isnull(Sum([ImporteContratadoAcumuladoAñoAnterior]),0)  AS ImporteContratadoAcumuladosAñoAnterior,
                                        isnull(Sum([ImporteContratadoAcumuladoLastYear]),   0)  AS ImporteContratadoAcumuladosLY,
                                        a.Orden
                                    FROM
                                        vwActividades a
                                        LEFT JOIN rptContratacion_Actividad c WITH (NOLOCK)
                                            ON  a.Pais      = c.Pais
                                            AND a.Agrupacion = c.Actividad
                                    GROUP BY
                                        a.Pais,
                                        a.Agrupacion,
                                        a.Orden
                                    ORDER BY
                                        ImporteContratadoAcumuladosAñoAnterior DESC";

        var parametros = new { Anio = anio, Mes = mes };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            await _connection.ExecuteAsync(sqlDelete, transaction: transaction);
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 60);
            await _connection.ExecuteAsync(sqlUpdateAnio, parametros, transaction: transaction);
            
            var resultado = (await _connection.QueryAsync<ActividadPoco>(sqlSelect, parametros, transaction: transaction)).ToList();

            transaction.Commit();
            return resultado;
        }
        catch (Exception)
        {
            transaction.Rollback();
            throw;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME PRINCIPAL: Principales Contrataciones del Año
    // └─ Método: ObtenerContratacionesAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos para el informe de Principales Contrataciones del Año.
    /// Datos acumulados desde Enero hasta el mes seleccionado.
    /// </summary>
    public async Task<List<ContratacionesPoco>> ObtenerContratacionesAsync(int anio, int mes, decimal importe, string pais)
    {
        const string sqlSelect = @"SELECT
                                        REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                                        REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                                        SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK
                                    FROM
                                        rptPrincipalesObras rpt WITH (NOLOCK)
                                    WHERE rpt.Año = @Anio
                                      AND rpt.Mes = @Mes
                                      AND rpt.Ocultar = 0
                                      AND rpt.Pais = @Pais
                                    GROUP BY
                                        rpt.NombreCliente_OK,
                                        rpt.DescripcionOferta_OK
                                    HAVING
                                        SUM(rpt.ImporteContratado_OK) >= @Importe
                                        OR SUM(rpt.ImporteContratado_OK) <= -@Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesPoco>(sqlSelect, new { 
            Anio = anio,
            Mes = mes,
            Importe = importe,
            Pais = pais
        }, commandTimeout: 60)).ToList();
    }

    /// <summary>
    /// Ejecuta el procedimiento almacenado spContratacion_Obras para actualizar rptPrincipalesObras.
    /// </summary>
    public async Task EjecutarSPObrasAsync(int anio, int mes)
    {
        const string sqlExec = @"EXEC spContratacion_Obras @Anio, @Mes";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        await conn.ExecuteAsync(sqlExec, new {
            Anio = anio,
            Mes = mes
        }, commandTimeout: 120);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBINFORME: Contrataciones Año Nacional Anterior (Meses Anteriores)
    // └─ Método: ObtenerContratacionesAnnoNacionalAnteriorAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos del subinforme Contrataciones Año Nacional Anterior (solo meses anteriores al seleccionado).
    /// Umbral: 1.500€
    /// </summary>
    public async Task<List<ContratacionesAnnoNacionalAnteriorPoco>> ObtenerContratacionesAnnoNacionalAnteriorAsync(int anio, int mes, decimal importe, string pais)
    {
        const string sqlSelect = @"SELECT
                                        m.Nombre_Mes AS Meses,
                                        REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                                        rpt.NombreDirNegocio_OK,
                                        REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                                        SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK,
                                        CASE WHEN oai.JVAYNB IS NOT NULL THEN 'AI' ELSE '' END AS AI
                                    FROM
                                        rptPrincipalesObras rpt WITH (NOLOCK)
                                    INNER JOIN
                                        Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
                                    LEFT JOIN
                                        OfertaAsociadaInversion oai WITH (NOLOCK) ON rpt.CodOferta = oai.JVAYNB
                                    WHERE
                                        rpt.Año = @Anio
                                        AND rpt.Mes < @Mes
                                        AND rpt.Ocultar = 0
                                        AND rpt.Pais = @Pais
                                    GROUP BY
                                        m.Nombre_Mes,
                                        rpt.NombreCliente_OK,
                                        rpt.NombreDirNegocio_OK,
                                        rpt.DescripcionOferta_OK,
                                        oai.JVAYNB
                                    HAVING
                                        SUM(rpt.ImporteContratado_OK) >= @Importe
                                        OR SUM(rpt.ImporteContratado_OK) <= -@Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesAnnoNacionalAnteriorPoco>(
            sqlSelect,
            new {
                Anio = anio,
                Mes = mes,
                Importe = importe,
                Pais = pais
            },
            commandTimeout: 60
        )).ToList();
    }
    // ═══════════════════════════════════════════════════════════════════════════
    // SUBINFORME: Contrataciones Año Internacional Mes (Subinforme Internacional)
    // └─ Método: ObtenerContratacionesAnnoInternacionalMesAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos del subinforme Contrataciones Año Internacional Mes (solo el mes seleccionado).
    /// </summary>
    public async Task<List<ContratacionesAnnoInternacionalMesPoco>> ObtenerContratacionesAnnoInternacionalMesAsync(int anio, int mes, decimal importe, string pais)
    {
        const string sqlSelect = @"SELECT
                                        m.Nombre_Mes AS Meses,
                                        REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                                        REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                                        rpt.NombreDirNegocio_OK,
                                        SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK,
                                        CASE WHEN oai.JVAYNB IS NOT NULL THEN 'AI' ELSE '' END AS AI
                                    FROM
                                        rptPrincipalesObras rpt WITH (NOLOCK)
                                    INNER JOIN
                                        Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
                                    LEFT JOIN
                                        OfertaAsociadaInversion oai WITH (NOLOCK) ON rpt.CodOferta = oai.JVAYNB
                                    WHERE
                                        rpt.Año = @Anio
                                        AND rpt.Mes = @Mes
                                        AND rpt.Ocultar = 0
                                        AND rpt.Pais = @Pais
                                    GROUP BY
                                        m.Nombre_Mes,
                                        rpt.NombreCliente_OK,
                                        rpt.DescripcionOferta_OK,
                                        rpt.NombreDirNegocio_OK,
                                        oai.JVAYNB
                                    HAVING
                                        SUM(rpt.ImporteContratado_OK) >= @Importe
                                        OR SUM(rpt.ImporteContratado_OK) <= -@Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesAnnoInternacionalMesPoco>(
            sqlSelect,
            new {
                Anio = anio,
                Mes = mes,
                Importe = importe,
                Pais = pais
            },
            commandTimeout: 60
        )).ToList();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBINFORME: Contrataciones Año Internacional Anterior
    // └─ Método: ObtenerContratacionesAnnoInternacionalAnteriorAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// SubInforme 3: Obtiene el acumulado de contrataciones internacionales de meses anteriores.
    /// </summary>
    public async Task<List<ContratacionesAnnoInternacionalAnteriorPoco>> ObtenerContratacionesAnnoInternacionalAnteriorAsync(int anio, int mes, decimal importe, string pais)
    {
        const string sqlSelect = @"
            SELECT
                m.Nombre_Mes AS Meses,
                REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK,
                CASE WHEN oai.JVAYNB IS NOT NULL THEN 'AI' ELSE '' END AS AI,
                rpt.NombreDirNegocio_OK
            FROM
                rptPrincipalesObras rpt WITH (NOLOCK)
            INNER JOIN
                Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
            LEFT JOIN
                OfertaAsociadaInversion oai WITH (NOLOCK) ON rpt.CodOferta = oai.JVAYNB
            WHERE
                rpt.Año = @Anio
                AND rpt.Mes < @Mes
                AND rpt.Ocultar = 0
                AND rpt.Pais = @Pais
            GROUP BY
                m.Nombre_Mes,
                rpt.NombreCliente_OK,
                rpt.DescripcionOferta_OK,
                oai.JVAYNB,
                rpt.NombreDirNegocio_OK
            HAVING
                SUM(rpt.ImporteContratado_OK) >= @Importe
                OR SUM(rpt.ImporteContratado_OK) <= -@Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesAnnoInternacionalAnteriorPoco>(
            sqlSelect,
            new {
                Anio = anio,
                Mes = mes,
                Importe = importe,
                Pais = pais
            },
            commandTimeout: 60
        )).ToList();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SECCIÓN: Contrataciones AI (Asociadas a Inversión)
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos del informe ContratacionesAI (mes seleccionado).
    /// </summary>
    public async Task<List<ContratacionesAIPoco>> ObtenerContratacionesAIAsync(int anio, int mes, decimal importe)
    {
        const string sqlSelect = @"SELECT
                                        rpt.Año,
                                        CASE WHEN rpt.Pais = 'InterNacional' THEN 'I' ELSE '' END AS Paises,
                                        m.Nombre_Mes AS Meses,
                                        REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                                        REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                                        SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK
                                    FROM
                                        rptPrincipalesObrasAI rpt WITH (NOLOCK)
                                    INNER JOIN
                                        Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
                                    WHERE
                                        rpt.Año = @Anio
                                        AND rpt.Mes = @Mes
                                        AND rpt.Ocultar = 0
                                    GROUP BY
                                        rpt.Año,
                                        rpt.Pais,
                                        m.Nombre_Mes,
                                        rpt.DescripcionOferta_OK,
                                        rpt.NombreCliente_OK
                                    HAVING
                                        SUM(rpt.ImporteContratado_OK) > @Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesAIPoco>(
            sqlSelect,
            new { Anio = anio, Mes = mes, Importe = importe },
            commandTimeout: 60
        )).ToList();
    }


    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Contrataciones AI (Generación de Datos)
    // └─ Método: EjecutarSPObrasAIAsync()
    // ═══════════════════════════════════════════════════════════════════════════
    /// <summary>
    /// Ejecuta el PA para generar los datos de Contrataciones AI.
    /// </summary>
    public async Task EjecutarSPObrasAIAsync(int anio, int mes)
    {
        const string sqlExec = @"EXEC spContratacion_Obras_Asociadas_Inversion @Anio, @Mes";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        await conn.ExecuteAsync(sqlExec, new {
            Anio = anio,
            Mes = mes
        }, commandTimeout: 120);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBINFORME: Contrataciones Año AI Anterior
    // └─ Método: ObtenerContratacionesAnnoAIAnteriorAsync()
    // ═══════════════════════════════════════════════════════════════════════════
    /// <summary>
    /// Obtiene los datos para el subinforme de Contrataciones AI (Meses Anteriores).
    /// </summary>
    public async Task<List<ContratacionesAIPoco>> ObtenerContratacionesAnnoAIAnteriorAsync(int anio, int mes, decimal importe)
    {
        const string sqlSelect = @"SELECT
                                        rpt.Año,
                                        CASE
                                            WHEN rpt.Pais = 'InterNacional' THEN 'I'
                                            ELSE ''
                                        END AS Paises,
                                        'Anterior' AS Meses, 
                                        REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                                        REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                                        SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK
                                    FROM
                                        rptPrincipalesObrasAI rpt WITH (NOLOCK)
                                    INNER JOIN
                                        Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
                                    WHERE
                                        rpt.Año = @Anio
                                        AND rpt.Mes < @Mes
                                        AND rpt.Ocultar = 0
                                    GROUP BY
                                        rpt.Año,
                                        rpt.Pais,
                                        rpt.DescripcionOferta_OK,
                                        rpt.NombreCliente_OK
                                    HAVING
                                        SUM(rpt.ImporteContratado_OK) > @Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesAIPoco>(
            sqlSelect,
            new { Anio = anio, Mes = mes, Importe = importe },
            commandTimeout: 60
        )).ToList();
    }


    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Ranking de Contratación por Clientes
    // └─ Métodos: ObtenerRankingContratacionClientesAsync(), EjecutarSPObrasRankingClientesAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    private class RankingClientesSpResult
    {
        public int Row { get; set; }
        public string? Mercado { get; set; }
        public string? Pais { get; set; }
        public string? AI { get; set; }
        public string? Cliente { get; set; }
        public decimal? ImporteContratadoAcumulado { get; set; }
        public decimal? ImporteContratadoAcumuladoAñoAnterior { get; set; }
        public decimal? ImporteContratadoAcumulado_Ajuste { get; set; }
    }

    /// <summary>
    /// Ejecuta el PA para generar los datos de Ranking de Clientes.
    /// </summary>
    public async Task EjecutarSPObrasRankingClientesAsync(string mercado, int anio, int mes)
    {
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();
        using var transaction = await conn.BeginTransactionAsync();

        try
        {
            // 1. Limpiar tabla de trabajo
            await conn.ExecuteAsync("DELETE FROM rptContratacion_Clientes", transaction: transaction);

            // 2. Ejecutar SP (3 parámetros: Mercado, Año, Mes) y obtener resultados en memoria
            // El SP devuelve ImporteContratadoAcumuladoAñoAnterior en Real Euros.
            var resultadosSp = (await conn.QueryAsync<RankingClientesSpResult>(
                "EXEC spContratacion_Clientes @Mercado, @Anio, @Mes",
                new { Mercado = mercado, Anio = anio, Mes = mes },
                transaction: transaction,
                commandTimeout: 300
            )).ToList();

            // 3. Volcar a tabla aplicando el patrón Access: Redondeo -> /1000m (k€)
            const string sqlInsert = @"INSERT INTO [dbo].[rptContratacion_Clientes] 
                                        (idContratacionActividad, Año, Row, Mercado, Pais, AI, Cliente, ImporteContratadoAcumulado, ImporteContratadoAcumulado_AñoAnterior, ImporteContratadoAcumulado_Ajuste) 
                                        VALUES (@Id, @Anio, @Row, @Mercado, @Pais, @AI, @Cliente, @Importe, @Anterior, @Ajuste)";

            int currentId = 1;
            foreach (var fila in resultadosSp)
            {
                await conn.ExecuteAsync(sqlInsert, new {
                    Id = currentId++,
                    Anio = anio,
                    Row = fila.Row,
                    Mercado = mercado,
                    Pais = fila.Pais,
                    AI = fila.AI,
                    Cliente = fila.Cliente?.Trim(),
                    // El SP ya devuelve el año actual escalado, no dividir. (según imagen 783)
                    Importe = fila.ImporteContratadoAcumulado ?? 0,
                    // El histórico viene en Euros Reales en el SP, escalar a k€ (según patrón Access)
                    Anterior = Math.Round(fila.ImporteContratadoAcumuladoAñoAnterior ?? 0, 0) / 1000m,
                    Ajuste = Math.Round(fila.ImporteContratadoAcumulado_Ajuste ?? 0, 0) / 1000m
                }, transaction: transaction);
            }

            await transaction.CommitAsync();
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    /// <summary>
    /// Obtiene los 30 primeros clientes del ranking filtrando por el importe mínimo.
    /// </summary>
    public async Task<List<Elecnor_Informes_Comerciales.Models.Informes.RankingContratacionClientes.RankingContratacionClientesPoco>> ObtenerRankingContratacionClientesAsync(int anio, int mes, decimal importe)
    {
        const string sqlSelect = @"SELECT TOP 30
                                        rpt.[Año],
                                        rpt.[Row],
                                        rpt.[Mercado],
                                        rpt.[Pais],
                                        rpt.[AI],
                                        rpt.[Cliente],
                                        rpt.[ImporteContratadoAcumulado],
                                        rpt.[ImporteContratadoAcumulado_AñoAnterior],
                                        MAX(CASE 
                                            WHEN ant.[NomAgrupado] IS NOT NULL THEN 1 
                                            ELSE 0 
                                        END) AS [VerAñoAnterior]
                                    FROM [dbo].[rptContratacion_Clientes] rpt WITH (NOLOCK)
                                    INNER JOIN [dbo].[ClientesSQL] csql WITH (NOLOCK)
                                        ON rpt.[Cliente] = csql.[NomAgrupado]
                                    LEFT JOIN [dbo].[ClientesSQL_MostrarContratacion_AñoAnterior] ant WITH (NOLOCK)
                                        ON rpt.[Cliente] = ant.[NomAgrupado]
                                        AND rpt.[Año] = ant.[Año]
                                    WHERE csql.[Visible] = 1
                                      AND rpt.[Cliente] <> ''
                                      AND rpt.[ImporteContratadoAcumulado] > @Importe
                                    GROUP BY
                                        rpt.[Año], rpt.[Row], rpt.[Mercado], rpt.[Pais], rpt.[AI], rpt.[Cliente],
                                        rpt.[ImporteContratadoAcumulado], rpt.[ImporteContratadoAcumulado_AñoAnterior]
                                    ORDER BY rpt.[Row] ASC";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<Elecnor_Informes_Comerciales.Models.Informes.RankingContratacionClientes.RankingContratacionClientesPoco>(
            sqlSelect,
            new { Anio = anio, Mes = mes, Importe = importe },
            commandTimeout: 60
        )).ToList();
    }

    /// <summary>
    /// Obtiene la suma total de todo el mercado para el informe de Ranking de Clientes.
    /// </summary>
    public async Task<decimal> ObtenerSumaTotalMercadoClientesAsync()
    {
        const string sqlSum = "SELECT ISNULL(Sum(ImporteContratadoAcumulado), 0) FROM rptContratacion_Clientes";
        
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();
        
        return await conn.ExecuteScalarAsync<decimal>(sqlSum, commandTimeout: 30);
    }
}

