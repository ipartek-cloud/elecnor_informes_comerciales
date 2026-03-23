using System.Data;
using Dapper;
using Elecnor_Informes_Comerciales.Models.Informes.Gerencias_Totales_Cruces;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosAI;
using elecnor_informes_comerciales.Models.Informes.Mercados;

namespace Elecnor_Informes_Comerciales.Repositories.Informes;

/// <summary>
/// Repositorio central de informes.
/// </summary>
public class InformeRepository
{
    private readonly IDbConnection _connection;

    public InformeRepository(IDbConnection connection)
    {
        _connection = connection;
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
                                    FROM rptContratacion_GerenciaCentro rpt
                                    INNER JOIN Sumarigrama s
                                        ON rpt.CodCentro = s.CodCentro
                                    LEFT JOIN Orden_CodDDirNegocio o
                                        ON s.CodDDirNegocio = o.CodDDirNegocio
                                    LEFT JOIN dbo.fn_veCarteraPdteProducirSQL_AnioActual(@Anio, @Mes) act
                                        ON rpt.CodCentro = act.CodCentro
                                    LEFT JOIN dbo.fn_veCarteraPdteProducirSQL_AnioAnterior(@Anio, @Mes) ant
                                        ON rpt.CodCentro = ant.CodCentro
                                    INNER JOIN CentrosGerentesSQL cg
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
                                    FROM rptContratacion_DG_SDG_DN_SDNA rpt
                                    LEFT JOIN ObjetivosSQL obj
                                        ON obj.Año = rpt.Año
                                       AND obj.CodSubDirGeneral = rpt.CodSubDirGeneral
                                       AND obj.Mercado = rpt.Pais
                                    LEFT JOIN vwObjetivosMercadoSQL vw_m
                                        ON vw_m.Año = rpt.Año
                                       AND vw_m.Mercado = rpt.Pais
                                    LEFT JOIN SubDirGeneral sg
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
}
