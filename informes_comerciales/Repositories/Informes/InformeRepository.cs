using System.Data;
using Microsoft.Data.SqlClient;
using Dapper;
using Elecnor_Informes_Comerciales.Models.Informes.CarteraDiferidaConsejo;
using Elecnor_Informes_Comerciales.Models.Informes.Mercados;
using Elecnor_Informes_Comerciales.Models.Informes.Paises;
using Elecnor_Informes_Comerciales.Models.Informes.Actividades;
using Elecnor_Informes_Comerciales.Models.Informes.ActividadesObjetivos;
using Elecnor_Informes_Comerciales.Models.Informes.Contrataciones;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionesAI;
using Elecnor_Informes_Comerciales.Models.Informes.RankingContratacionClientes;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionesSignificativas;
using Elecnor_Informes_Comerciales.Models.Informes.MercadosDG;
using Elecnor_Informes_Comerciales.Models.Informes.Gerencias;
using Elecnor_Informes_Comerciales.Models.Informes.MercadosSGDelegaciones;
using Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetalle;
using Elecnor_Informes_Comerciales.DTOs.Informes;

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
    // INFORME: Cartera Diferida Consejo
    // └─ Método: ObtenerCarteraDiferidaConsejoAsync()
    // └─ Incluye: Mercados por País, Asociado Inversión, Cartera Producción/Diferida y Ventas.
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos consolidados para el informe de Cartera Diferida (CONSEJO ELECNOR).
    /// </summary>
    public async Task<(List<CarteraDiferidaConsejoPoco> Principal, List<MercadoAIPoco> mercadoAI, List<CarteraProducirPoco> Cartera, List<CarteraDiferidaPoco> CarteraDiferida, List<VentasPoco> Ventas)> ObtenerCarteraDiferidaConsejoAsync(int anio, int mes)
    {
        // SECCIÓN A: INFORME PRINCIPAL (Mercados por País)
        const string sqlDeletePrincipal = "DELETE FROM rptContratacion_DG_SDG_DN_SDNA";
        const string sqlExecPrincipal = "EXEC spContratacion_DG_SDG_DN_SDNA @Anio, @Mes";
        const string sqlInsertManualPrincipal = @"INSERT INTO rptContratacion_DG_SDG_DN_SDNA (Año, CodSubDirGeneral, NombreSubDirGeneral, NombreDirNegocio, NombreSubDirNegocioArea, Pais, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteObjetivo)
                                                VALUES (@Anio, @CodSubDirGeneral, @NombreSubDirGeneral, @NombreDirNegocio, @NombreSubDirNegocioArea, @Pais, @ImporteContratado, @ImporteContratadoAcumulado, @ImporteContratadoAcumuladoAñoAnterior, @ImporteObjetivo)";

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

        // SECCIÓN B: ASOCIADO INVERSIÓN (MercadoAI)
        const string sqlDeleteSub = "DELETE FROM rptContratacionAsociadoInversion";
        const string sqlInsertExecSub = "EXEC spWEB_ContratacionAsociadoInversion @Anio, @Mes";
        const string sqlUpdateAnioSub = "UPDATE rptContratacionAsociadoInversion SET Año = @Anio";

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

        // SECCIÓN C: CARTERA PRODUCCIÓN (Pendiente Producir)
        const string sqlSelectCartera = @"  SELECT Año, Mes, Concepto, ImporteInicial, ImporteActual, PorcentajeIncrementoAñoAnterior, SumarCartera, CarteraAñoAnterior
                                            FROM CarteraActual_CJO
                                            WHERE Año = @Anio AND Mes = @Mes";

        // SECCIÓN D: CARTERA DIFERIDA (columnas calculadas dinámicamente según @Anio - 1)
        // Para anio=N: ValorCart1_1=[01#01#(N-1)], ValorAnio1=[N-1], ValorAnio2=[N], ValorAnio3=[N+1]
        string colCart1_1 = $"[01#01#{(anio - 1).ToString().Substring(2, 2)}]";
        string colAnio1   = $"[{anio - 1}]";
        string colAnio2   = $"[{anio}]";
        string colAnio3   = $"[{anio + 1}]";

        string sqlSelectDiferida = $@"
            SELECT
                Año,
                Mes,
                Mercado,
                [Cartera Diferida] AS CarteraDiferida,
                {colCart1_1} AS ValorCart1_1,
                Nuevos,
                Total,
                Contr,
                {colAnio1} AS ValorAnio1,
                {colAnio2} AS ValorAnio2,
                {colAnio3} AS ValorAnio3,
                Orden
            FROM CarteraDiferida_CJO WITH (NOLOCK)
            WHERE Mercado = 'Mercado'
              AND Año = @Anio
              AND Mes = @Mes";

        // SECCIÓN E: VENTAS HISTÓRICAS
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

            var principal = (await _connection.QueryAsync<CarteraDiferidaConsejoPoco>(sqlSelectPrincipal, parametros, transaction)).ToList();

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
    // INFORME: Mercados / MercadosDG
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * Obtiene los datos de mercados mediante la población de una tabla de trabajo temporal.
     * Utiliza spContratacion_DG_SDG_DN_SDNA para el cálculo de importes.
     */
    public async Task<List<MercadosPoco>> ObtenerMercadosAsync(int anio, int mes)
    {
        const string sqlDelete = "DELETE FROM rptContratacion_DG_SDG_DN_SDNA";
        const string sqlExec = "EXEC spContratacion_DG_SDG_DN_SDNA @Anio, @Mes";

        const string sqlInsertManual = @"INSERT INTO rptContratacion_DG_SDG_DN_SDNA (Año, CodSubDirGeneral, NombreSubDirGeneral, NombreDirNegocio, NombreSubDirNegocioArea, Pais, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteObjetivo)
                                         VALUES (@Anio, @CodSubDirGeneral, @NombreSubDirGeneral, @NombreDirNegocio, @NombreSubDirNegocioArea, @Pais, @ImporteContratado, @ImporteContratadoAcumulado, @ImporteContratadoAcumuladoAñoAnterior, @ImporteObjetivo)";

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
                                        rpt.Año, rpt.Pais, rpt.NombreSubDirGeneral, rpt.NombreDirNegocio";

        var parametros = new { Anio = anio, Mes = mes };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            // 1. Obtener datos desde el procedimiento almacenado
            var datosSp = (await _connection.QueryAsync<dynamic>(sqlExec, parametros, transaction: transaction)).ToList();
            
            // 2. Limpiar tabla de trabajo para la sesión
            await _connection.ExecuteAsync(sqlDelete, transaction: transaction);
            
            // 3. Poblar tabla de trabajo con el periodo solicitado
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

            // 4. Consulta final con agregación y JOINs de objetivos
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
    // SUBINFORME: Cartera Diferida (para MercadosDG)
    // └─ Método: ObtenerMercadosDGCarteraDiferidaAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos de Cartera Diferida para el subinforme de MercadosDG.
    /// Lectura directa desde CarteraDiferida_CJO. Ejecuta en paralelo con ObtenerMercadosAsync().
    /// Las columnas se calculan dinámicamente según @Anio.
    /// </summary>
    public async Task<List<MercadosDGCarteraDiferidaPoco>> ObtenerMercadosDGCarteraDiferidaAsync(int anio, int mes)
    {
        using var connection = new SqlConnection(_connectionString);

        string colCartPrev = $"[01#01#{(anio - 2).ToString().Substring(2)}]";
        string colCartAct  = $"[01#01#{(anio - 1).ToString().Substring(2)}]";
        string colFuturo1  = $"[{anio}]";
        string colFuturo2  = $"[{anio + 1}]";

        string sql = $@"
            SELECT
                [Cartera Diferida] AS CarteraDiferida,
                {colCartPrev} AS ValorCartPrev,
                {colCartAct}  AS ValorCartAct,
                {colFuturo1}  AS ValorFuturo1,
                {colFuturo2}  AS ValorFuturo2,
                Orden
            FROM CarteraDiferida_CJO WITH (NOLOCK)
            WHERE Mercado = 'Mercado'
              AND Año = @Anio
              AND Mes = @Mes";

        var parametros = new { Anio = anio, Mes = mes };

        return (await connection.QueryAsync<MercadosDGCarteraDiferidaPoco>(sql, parametros)).ToList();
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
        // WEB: Usa spContratacion_InternacionalWEB (versión optimizada con pushdown a AS/400).
        //      El SP original spContratacion_Internacional se mantiene intacto para otras apps.
        const string sqlInsertExec = @"INSERT INTO rptContratacion_Internacional (codProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)
                                       EXEC spContratacion_InternacionalWEB @Anio, @Mes";

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
                                            FROM
                                                rptContratacion_Internacional WITH (NOLOCK)
                                            WHERE Año = @Anio

                                        UNION ALL

                                            SELECT
                                                ISNULL(p.NMPRO, 'OTROS') AS Pais,
                                                0 AS ImpActual,
                                                ISNULL(h.Importe, 0) AS ImpAnterior,
                                                0 AS Ajuste,
                                                ISNULL(h.Orden, 0) AS Orden
                                            FROM 
                                                HistoricoContratacionSQL h WITH (NOLOCK)
                                            LEFT JOIN 
                                                ProvinciasInternacional p WITH (NOLOCK) ON h.CodProv = p.CDPRO
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
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 300);
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
    // INFORME: Países ALL (Nacional + Internacional)
    // └─ Método: ObtenerPaisesAllAsync() REFACTORIZADO AL PATRÓN ESTÁNDAR
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos para el informe de Países (Nacional + Internacional).
    /// </summary>
    public async Task<List<PaisesPoco>> ObtenerPaisesAllAsync(int anio, int mes)
    {
        // ─── PASO 1: Vaciar la tabla de trabajo (misma que el internacional) ───
        const string sqlDelete = "DELETE FROM rptContratacion_Internacional";

        // ─── PASO 2: Poblado vía SP (Paises ALL: Nac + Int) ───
        const string sqlInsertExec = @"INSERT INTO rptContratacion_Internacional (codProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)
                                       EXEC spContratacion_NacIntTODO @Anio, @Mes, ''";

        const string sqlUpdateAnio = "UPDATE rptContratacion_Internacional SET Año = @Anio WHERE Año IS NULL";

        // ─── PASO 3: Selección y Cruce con Histórico (Cruce por PAÍS para asegurar 'España') ───
        const string sqlSelect = @" SELECT 
                                        @Anio AS Año,
                                        t.Pais,
                                        SUM(t.ImpActual) AS ImporteContratadoAcumulado,
                                        SUM(t.ImpAnterior) AS ImporteContratadoAcumuladoAñoAnterior,
                                        MAX(t.Ajuste) AS Ajuste,
                                        CASE WHEN SUM(t.ImpAnterior) = 0 THEN '*' ELSE '' END AS SinContratacionAñoAnterior,
                                        MAX(t.Orden) AS OrdenAñoAnterior
                                    FROM (
                                            -- Datos Actuales (insertados en el paso 2)
                                            SELECT 
                                                Pais,
                                                dbo.fgRedondear(ISNULL(ImporteContratadoAcumulado, 0), 2) AS ImpActual,
                                                0 AS ImpAnterior,
                                                Ajuste,
                                                0 AS Orden
                                            FROM 
                                                rptContratacion_Internacional WITH (NOLOCK)
                                            WHERE Año = @Anio

                                        UNION ALL

                                            -- Datos Históricos (Cruce por nombre de País para Nacional + Int)
                                            SELECT 
                                                CASE 
                                                   WHEN h.CodProv = '00' OR h.CodProv = ' España' THEN 'España' 
                                                   ELSE ISNULL(p.NMPRO, 'OTROS') 
                                                END AS Pais,
                                                0 AS ImpActual,
                                                ISNULL(h.Importe, 0) AS ImpAnterior,
                                                0 AS Ajuste,
                                                ISNULL(h.Orden, 0) AS Orden
                                            FROM 
                                                HistoricoContratacionSQL h WITH (NOLOCK)
                                            LEFT JOIN 
                                                ProvinciasInternacional p WITH (NOLOCK) ON h.CodProv = p.CDPRO
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
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 300);
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
                                    ON  a.Pais = c.Pais AND a.Agrupacion = c.Actividad
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
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 300);
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
    // INFORME: Actividades_Objetivos
    // └─ Método: ObtenerActividadesObjetivosAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene los datos para el informe de Actividades_Objetivos.
    /// Incluye contratación acumulada + objetivos + cálculos de IP.
    /// </summary>
    public async Task<List<ActividadObjetivoPoco>> ObtenerActividadesObjetivosAsync(int anio, int mes)
    {
        const string sqlDelete = "DELETE FROM rptContratacion_Actividad";

        const string sqlInsertExec = @"INSERT INTO rptContratacion_Actividad (NombreDirGeneral, Pais, CodActividad, Actividad, Orden, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteContratadoAcumuladoLastYear)
                                       EXEC spContratacion_Actividades_Ajuste @Anio, @Mes";

        const string sqlUpdateAnio = "UPDATE rptContratacion_Actividad SET Año = @Anio WHERE Año IS NULL";

        const string sqlSelect = @"WITH CTE_BaseActividades AS (
                                        SELECT DISTINCT
                                            p.Pais,
                                            a.Agrupacion AS Actividad
                                        FROM ActividadesSQL a WITH (NOLOCK)
                                        CROSS JOIN Pais p WITH (NOLOCK)
                                    ),
                                    CTE_Objetivos AS (
                                        SELECT
                                            Agrupacion,
                                            Año,
                                            CASE WHEN Mercado = 'N' THEN 'Nacional' ELSE 'Internacional' END AS Mercados,
                                            SUM(Importe) AS ImporteObjetivos
                                        FROM vwObjetivosActividadesAGRUPNacionalInternacional WITH (NOLOCK)
                                        WHERE Año = @Anio
                                        GROUP BY
                                            Agrupacion,
                                            Año,
                                            CASE WHEN Mercado = 'N' THEN 'Nacional' ELSE 'Internacional' END
                                    )
                                    SELECT
                                        base.Pais,
                                        base.Actividad,
                                        ISNULL(SUM(rpt.ImporteContratadoAcumulado), 0)            AS ImporteContratadoAcumulado,
                                        ISNULL(SUM(rpt.ImporteContratadoAcumuladoAñoAnterior), 0) AS ImporteContratadoAcumuladoAñoAnterior,
                                        ISNULL(SUM(rpt.ImporteContratadoAcumuladoLastYear), 0)    AS ImporteContratadoAcumuladoLastYear,
                                        ISNULL(MAX(obj.ImporteObjetivos), 0)                      AS ImporteObjetivos
                                    FROM
                                        CTE_BaseActividades base
                                    LEFT JOIN rptContratacion_Actividad rpt WITH (NOLOCK)
                                        ON  base.Pais      = rpt.Pais
                                        AND base.Actividad = rpt.Actividad
                                        AND rpt.Año        = @Anio
                                    LEFT JOIN CTE_Objetivos obj
                                        ON  rpt.Actividad  = obj.Agrupacion
                                        AND rpt.Pais       = obj.Mercados
                                    GROUP BY
                                        base.Pais,
                                        base.Actividad
                                    HAVING
                                        SUM(rpt.ImporteContratadoAcumulado) <> 0
                                        OR SUM(rpt.ImporteContratadoAcumuladoAñoAnterior) <> 0
                                        OR MAX(obj.ImporteObjetivos) <> 0";

        var parametros = new { Anio = anio, Mes = mes };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            await _connection.ExecuteAsync(sqlDelete, transaction: transaction);
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 300);
            await _connection.ExecuteAsync(sqlUpdateAnio, parametros, transaction: transaction);

            var resultado = (await _connection.QueryAsync<ActividadObjetivoPoco>(sqlSelect, parametros, transaction: transaction)).ToList();

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
    /// Suma total de cartera sobre CarterasContratacionSQL.
    /// Equivalente a txtTotalImporte en Access (PieDelGrupo1_Format).
    /// </summary>
    public async Task<decimal?> ObtenerTotalCarteraGeneralAsync(int anio, int mes)
    {
        const string sql = @"
            SELECT SUM(ISNULL(C.ImporteEUR, 0))
            FROM CarterasContratacionSQL C WITH (NOLOCK)
            LEFT JOIN Sumarigrama S WITH (NOLOCK)
                ON C.CentroChar = S.CodCentro AND C.AnioInforme = S.Año
            WHERE C.AnioInforme = @Anio
              AND C.MesInforme = @Mes";

        using var conn = new SqlConnection(_connectionString);
        return await conn.ExecuteScalarAsync<decimal?>(sql, new { Anio = anio, Mes = mes });
    }

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
        }, commandTimeout: 300)).ToList();
    }

    public async Task EjecutarSPObrasAsync(int anio, int mes)
    {
        const string sqlExec = @"EXEC spContratacion_Obras @Anio, @Mes";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        await conn.ExecuteAsync(sqlExec, new {
            Anio = anio,
            Mes = mes
        }, commandTimeout: 300);
    }

    /// <summary>
    /// Ejecuta el procedimiento almacenado spContratacion_ObrasRPT para actualizar las tablas de contrataciones significativas.
    /// </summary>
    public async Task EjecutarSPObrasRPTAsync(int anio, int mes)
    {
        const string sqlExec = @"EXEC spContratacion_ObrasRPT @Anio, @Mes";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        await conn.ExecuteAsync(sqlExec, new {
            Anio = anio,
            Mes = mes
        }, commandTimeout: 300);
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
            commandTimeout: 300
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
            commandTimeout: 300
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
            commandTimeout: 300
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
            commandTimeout: 300
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
        }, commandTimeout: 300);
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
            commandTimeout: 300
        )).ToList();
    }


    // ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
    // INFORME: Ranking de Contratación por Clientes
    // └─ Métodos: ObtenerRankingContratacionClientesAsync(), EjecutarSPObrasRankingClientesAsync(),
    //             ObtenerRankingContratacionClientesDesgloseAsync(), EjecutarSPObrasRankingClientesDesgloseAsync(),
    //             ObtenerSumaTotalMercadoClientesAsync
    // ═══════════════════════════════════════════════════════════════════════════════════════════════════════════

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

    private class RankingClientesDesgloseSpResult
    {
        public string? Pais { get; set; }
        public string? AI { get; set; }
        public string? Cliente { get; set; }
        public string? ClienteDesglose { get; set; }
        public decimal? ImporteContratadoAcumulado { get; set; }
        public decimal? ImporteContratadoAcumuladoAñoAnterior { get; set; }
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
            var resultadosSp = (await conn.QueryAsync<RankingClientesSpResult>( "EXEC spContratacion_Clientes @Mercado, @Anio, @Mes",
                                                                                    new { Mercado = mercado, Anio = anio, Mes = mes },
                                                                                    transaction: transaction,
                                                                                    commandTimeout: 300
                                                                                )).ToList();

            // 3. Volcar a tabla usando SqlBulkCopy (omitimos la columna IDENTITY idContratacionActividad)
            var table = new DataTable();
            table.Columns.Add("Año", typeof(int));
            table.Columns.Add("Row", typeof(int));
            table.Columns.Add("Mercado", typeof(string));
            table.Columns.Add("Pais", typeof(string));
            table.Columns.Add("AI", typeof(string));
            table.Columns.Add("Cliente", typeof(string));
            table.Columns.Add("ImporteContratadoAcumulado", typeof(decimal));
            table.Columns.Add("ImporteContratadoAcumulado_AñoAnterior", typeof(decimal));
            table.Columns.Add("ImporteContratadoAcumulado_Ajuste", typeof(decimal));

            foreach (var fila in resultadosSp)
            {
                var importe = fila.ImporteContratadoAcumulado ?? 0m;
                var anterior = Math.Round(fila.ImporteContratadoAcumuladoAñoAnterior ?? 0m, 0);
                var ajuste = Math.Round(fila.ImporteContratadoAcumulado_Ajuste ?? 0m, 0);

                table.Rows.Add(
                    anio,
                    fila.Row,
                    mercado,
                    fila.Pais,
                    fila.AI,
                    fila.Cliente?.Trim(),
                    importe,
                    anterior,
                    ajuste
                );
            }

            using var bulk = new SqlBulkCopy(conn, SqlBulkCopyOptions.TableLock, (SqlTransaction)transaction)
            {
                DestinationTableName = "dbo.rptContratacion_Clientes",
                BatchSize = 1000,
                BulkCopyTimeout = 300
            };

            // Mapeo explícito de columnas (DataTable columna -> tabla destino)
            bulk.ColumnMappings.Add("Año", "Año");
            bulk.ColumnMappings.Add("Row", "Row");
            bulk.ColumnMappings.Add("Mercado", "Mercado");
            bulk.ColumnMappings.Add("Pais", "Pais");
            bulk.ColumnMappings.Add("AI", "AI");
            bulk.ColumnMappings.Add("Cliente", "Cliente");
            bulk.ColumnMappings.Add("ImporteContratadoAcumulado", "ImporteContratadoAcumulado");
            bulk.ColumnMappings.Add("ImporteContratadoAcumulado_AñoAnterior", "ImporteContratadoAcumulado_AñoAnterior");
            bulk.ColumnMappings.Add("ImporteContratadoAcumulado_Ajuste", "ImporteContratadoAcumulado_Ajuste");

            await bulk.WriteToServerAsync(table);

            await transaction.CommitAsync();
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    /// <summary>
    /// Ejecuta el PA para generar los datos de Desglose de Clientes.
    /// </summary>
    public async Task EjecutarSPObrasRankingClientesDesgloseAsync(string mercado, int anio, int mes)
    {
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();
        using var transaction = await conn.BeginTransactionAsync();

        try
        {
            // 1. Limpiar tabla de trabajo de desglose
            await conn.ExecuteAsync("DELETE FROM rptContratacion_Clientes_Desglose", transaction: transaction);

            // 2. Ejecutar SP de desglose (3 parámetros: Mercado, Año, Mes)
            var resultadosSp = (await conn.QueryAsync<RankingClientesDesgloseSpResult>( "EXEC spContratacion_Clientes_Desglose @Mercado, @Anio, @Mes",
                                                                                            new { Mercado = mercado, Anio = anio, Mes = mes },
                                                                                            transaction: transaction,
                                                                                            commandTimeout: 300
                                                                                        )).ToList();

            // 3. Volcar a tabla usando SqlBulkCopy (idContratacionActividad es IDENTITY en la tabla destino)
            var table = new DataTable();
            table.Columns.Add("Año", typeof(int));
            table.Columns.Add("Mercado", typeof(string));
            table.Columns.Add("Pais", typeof(string));
            table.Columns.Add("AI", typeof(string));
            table.Columns.Add("Cliente", typeof(string));
            table.Columns.Add("ClienteDesglose", typeof(string));
            table.Columns.Add("ImporteContratadoAcumulado", typeof(decimal));
            table.Columns.Add("ImporteContratadoAcumuladoAñoAnterior", typeof(decimal));

            foreach (var fila in resultadosSp)
            {
                var importe = Math.Round(fila.ImporteContratadoAcumulado ?? 0m, 0);
                var anterior = Math.Round(fila.ImporteContratadoAcumuladoAñoAnterior ?? 0m, 0);

                table.Rows.Add(
                    anio,
                    mercado,
                    fila.Pais,
                    fila.AI,
                    fila.Cliente?.Trim(),
                    fila.ClienteDesglose?.Trim(),
                    importe,
                    anterior
                );
            }

            using var bulk = new SqlBulkCopy(conn, SqlBulkCopyOptions.TableLock, (SqlTransaction)transaction)
            {
                DestinationTableName = "dbo.rptContratacion_Clientes_Desglose",
                BatchSize = 1000,
                BulkCopyTimeout = 300
            };

            bulk.ColumnMappings.Add("Año", "Año");
            bulk.ColumnMappings.Add("Mercado", "Mercado");
            bulk.ColumnMappings.Add("Pais", "Pais");
            bulk.ColumnMappings.Add("AI", "AI");
            bulk.ColumnMappings.Add("Cliente", "Cliente");
            bulk.ColumnMappings.Add("ClienteDesglose", "ClienteDesglose");
            bulk.ColumnMappings.Add("ImporteContratadoAcumulado", "ImporteContratadoAcumulado");
            bulk.ColumnMappings.Add("ImporteContratadoAcumuladoAñoAnterior", "ImporteContratadoAcumuladoAñoAnterior");

            await bulk.WriteToServerAsync(table);

            await transaction.CommitAsync();
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    /// <summary>
    /// Obtiene los 30 primeros clientes del ranking filtrando por mercado, año e importe mínimo.
    /// </summary>
    public async Task<List<RankingContratacionClientesPoco>> ObtenerRankingContratacionClientesAsync(string mercado, int anio, int mes, decimal importe)
    {        
        const string sqlSelect = @"SELECT TOP(30)
                                        Año,
                                        Row,
                                        Mercado,
                                        Pais,
                                        AI,
                                        Cliente,
                                        ImporteContratadoAcumulado,
                                        ImporteContratadoAcumulado_AñoAnterior,
                                        VerAñoAnterior
                                    FROM 
                                        vwRankingContratacionClientes
                                    WHERE 
                                        ImporteContratadoAcumulado > @Importe
                                    ORDER BY Row ASC";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<RankingContratacionClientesPoco>(
            sqlSelect,
            new {Importe = importe },
            commandTimeout: 300
        )).ToList();
    }
    
    /// <summary>
    /// Obtiene el detalle de desglose de clientes desde la tabla de trabajo filtrando por mercado y año.
    /// </summary>
    public async Task<List<RankingContratacionClientesDesglosePoco>> ObtenerRankingContratacionClientesDesgloseAsync(string mercado, int anio, int mes)
    {
        const string sql = @"WITH HistoricoAcumulado AS (
                                SELECT
                                    Mercado,
                                    ClientePadre,
                                    SUM(Contratacion) AS ContratacionAnterior
                                FROM HistoricoClientesSQL
                                WHERE Año = @Año - 1
                                  AND Mes <= @Mes
                                GROUP BY Mercado, ClientePadre
                            )
                            SELECT
                                D.Pais,
                                D.AI,
                                D.Cliente,
                                D.ClienteDesglose,
                                D.ImporteContratadoAcumulado,
                                ISNULL(H.ContratacionAnterior, 0) AS ImporteContratadoAcumuladoAñoAnterior
                            FROM
                                [dbo].[rptContratacion_Clientes_Desglose] D
                            LEFT JOIN 
                                HistoricoAcumulado H 
                            ON
                                    D.ClienteDesglose = H.ClientePadre
                                AND D.Mercado = H.Mercado
                            WHERE
                                NULLIF(D.ClienteDesglose, '') IS NOT NULL
                            ORDER BY
                                D.ImporteContratadoAcumulado";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<RankingContratacionClientesDesglosePoco>(
            sql, 
            new { Mercado = mercado, Año = anio, Mes = mes }, 
            commandTimeout: 300
        )).ToList();
    }

    /// <summary>
    /// Obtiene la suma total de todo el mercado para el informe de Ranking de Clientes.
    /// </summary>
    public async Task<decimal> ObtenerSumaTotalMercadoClientesAsync(string mercado, int anio)
    {
        const string sqlSum = "SELECT ISNULL(Sum(ImporteContratadoAcumulado), 0) FROM rptContratacion_Clientes WHERE Mercado = @Mercado AND Año = @Anio";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return await conn.ExecuteScalarAsync<decimal>(sqlSum, new { Mercado = mercado, Anio = anio }, commandTimeout: 300);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CATÁLOGO: SubDirecciones Generales
    // └─ Método: ObtenerSubDireccionesAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene el listado de SubDirecciones Generales para cargar combos.
    /// </summary>
    public async Task<List<SubDireccionGeneralDto>> ObtenerSubDireccionesAsync()
    {
        const string sql = @"
            SELECT
                Sumarigrama.CodSubDirGeneral,
                Sumarigrama.NombreSubDirGeneral
            FROM
                Sumarigrama
            GROUP BY
                Sumarigrama.CodSubDirGeneral,
                Sumarigrama.NombreSubDirGeneral,
                Sumarigrama.OrdenSubDirGeneral
            ORDER BY
                Sumarigrama.OrdenSubDirGeneral";

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        return (await _connection.QueryAsync<SubDireccionGeneralDto>(sql)).ToList();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Contrataciones Significativas
    // ═══════════════════════════════════════════════════════════════════════════

    public async Task<List<ContratacionesSignificativasPoco>> ObtenerContratacionesSignificativasAsync(
        int anio, int mes, string mercado, string codSubDirGeneral)
    {
        int mesMenos1 = mes - 1;

        const string sqlSelect = @" SELECT
                                        ocdn.Orden_CodDDirNegocio AS Orden,
                                        s.NombreDirNegocio,
                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0) AS ImporteContratado
                                    FROM
                                        rptPrincipalesContratacion   rpc
                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro
                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
                                    WHERE
                                            rpc.Año            = @Anio
                                        AND rpc.Mes            IN (@Mes, @MesMenos1)
                                        AND rpc.Ocultar        = 0
                                        AND rpc.Pais           = @Mercado
                                        AND s.CodSubDirGeneral = @CodSubDirGeneral
                                    GROUP BY
                                        ocdn.Orden_CodDDirNegocio,
                                        s.NombreDirNegocio";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesSignificativasPoco>(    sqlSelect,
                                                                            new {
                                                                                Anio             = anio,
                                                                                Mes              = mes,
                                                                                MesMenos1        = mesMenos1,
                                                                                Mercado          = mercado,
                                                                                CodSubDirGeneral = codSubDirGeneral
                                                                            },
                                                                            commandTimeout: 300
                                                                        )).ToList();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBINFORME: Contrataciones Significativas — Detalle Mes
    // └─ Metodo: ObtenerContratacionesSignificativasMesAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene el detalle mensual de contrataciones individuales (>= @Importe k€).
    /// </summary>
    public async Task<List<ContratacionesSignificativasMesPoco>> ObtenerContratacionesSignificativasMesAsync(
        int anio, int mes, string mercado, string codSubDirGeneral, decimal importe)
    {
        const string sqlSelect = @"SELECT
                                        ocdn.Orden_CodDDirNegocio                   AS Orden,
                                        s.NombreDirNegocio,
                                        REPLACE(rpc.NombreCliente_OK,  '''', '')     AS NombreCliente_OK,
                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')  AS DescripcionOferta_OK,
                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0)    AS ImporteContratado
                                    FROM
                                        rptPrincipalesContratacion   rpc
                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro
                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
                                    WHERE
                                            rpc.Año            = @Anio
                                        AND rpc.Mes            = @Mes
                                        AND rpc.Ocultar        = 0
                                        AND rpc.Pais           = @Mercado
                                        AND s.CodSubDirGeneral = @CodSubDirGeneral
                                        AND rpc.NombreCliente_OK <> 'ZZ_CARTERA DIFERIDA'
                                    GROUP BY
                                        ocdn.Orden_CodDDirNegocio,
                                        s.NombreDirNegocio,
                                        REPLACE(rpc.NombreCliente_OK,  '''', ''),
                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')
                                    HAVING
                                           SUM(rpc.ImporteContratado_OK) >=  @Importe
                                        OR SUM(rpc.ImporteContratado_OK) <= -@Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesSignificativasMesPoco>(
            sqlSelect,
            new {
                Anio             = anio,
                Mes              = mes,
                Mercado          = mercado,
                CodSubDirGeneral = codSubDirGeneral,
                Importe          = importe
            },
            commandTimeout: 300
        )).ToList();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBINFORME: Contrataciones Significativas — Histórico Meses Anteriores
    // └─ Metodo: ObtenerContratacionesSignificativasMesesAnterioresAsync()
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Obtiene el detalle mensual histórico de contrataciones (>= @Importe k€)
    /// de los meses anteriores al consultado dentro del mismo año.
    /// </summary>
    public async Task<List<ContratacionesSignificativasMesPoco>> ObtenerContratacionesSignificativasMesesAnterioresAsync(
        int anio, int mes, string mercado, string codSubDirGeneral, decimal importe)
    {
        const string sqlSelect = @"SELECT
                                        ocdn.Orden_CodDDirNegocio                   AS Orden,
                                        s.NombreDirNegocio,
                                        REPLACE(rpc.NombreCliente_OK,  '''', '')     AS NombreCliente_OK,
                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')  AS DescripcionOferta_OK,
                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0)    AS ImporteContratado
                                    FROM
                                        rptPrincipalesContratacion   rpc
                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro
                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
                                    WHERE
                                            rpc.Año            = @Anio
                                        AND rpc.Mes            < @Mes
                                        AND rpc.Ocultar        = 0
                                        AND rpc.Pais           = @Mercado
                                        AND s.CodSubDirGeneral = @CodSubDirGeneral
                                        AND rpc.NombreCliente_OK <> 'ZZ_CARTERA DIFERIDA'
                                    GROUP BY
                                        ocdn.Orden_CodDDirNegocio,
                                        s.NombreDirNegocio,
                                        REPLACE(rpc.NombreCliente_OK,  '''', ''),
                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')
                                    HAVING
                                           SUM(rpc.ImporteContratado_OK) >=  @Importe
                                        OR SUM(rpc.ImporteContratado_OK) <= -@Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesSignificativasMesPoco>(
            sqlSelect,
            new {
                Anio             = anio,
                Mes              = mes,
                Mercado          = mercado,
                CodSubDirGeneral = codSubDirGeneral,
                Importe          = importe
            },
            commandTimeout: 300
        )).ToList();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Contrataciones Significativas (COMITE)
    // ═══════════════════════════════════════════════════════════════════════════

    public async Task<List<ContratacionesSignificativasPoco>> ObtenerContratacionesSignificativasRiAsync(
        int anio, int mes, string mercado, string codSubDirGeneral)
    {
        const string sqlSelect = @" SELECT
                                        ocdn.Orden_CodDDirNegocio AS Orden,
                                        s.NombreDirNegocio,
                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0) AS ImporteContratado
                                    FROM
                                        rptPrincipalesContratacion   rpc
                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro
                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
                                    WHERE
                                            rpc.Año            = @Anio
                                        AND rpc.Mes            = @Mes
                                        AND rpc.Ocultar        = 0
                                        AND rpc.Pais           = @Mercado
                                        AND s.CodSubDirGeneral = @CodSubDirGeneral
                                    GROUP BY
                                        ocdn.Orden_CodDDirNegocio,
                                        s.NombreDirNegocio";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesSignificativasPoco>(    sqlSelect,
                                                                            new {
                                                                                Anio             = anio,
                                                                                Mes              = mes,
                                                                                Mercado          = mercado,
                                                                                CodSubDirGeneral = codSubDirGeneral
                                                                            },
                                                                            commandTimeout: 300
                                                                        )).ToList();
    }

    public async Task<List<ContratacionesSignificativasMesPoco>> ObtenerContratacionesSignificativasMesRiAsync(
        int anio, int mes, string mercado, string codSubDirGeneral, decimal importe)
    {
        const string sqlSelect = @"SELECT
                                        ocdn.Orden_CodDDirNegocio                   AS Orden,
                                        s.NombreDirNegocio,
                                        REPLACE(rpc.NombreCliente_OK,  '''', '')     AS NombreCliente_OK,
                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')  AS DescripcionOferta_OK,
                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0)    AS ImporteContratado
                                    FROM
                                        rptPrincipalesContratacion   rpc
                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro
                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
                                    WHERE
                                            rpc.Año            = @Anio
                                        AND rpc.Mes            = @Mes
                                        AND rpc.Ocultar        = 0
                                        AND rpc.Pais           = @Mercado
                                        AND s.CodSubDirGeneral = @CodSubDirGeneral
                                        AND rpc.NombreCliente_OK <> 'ZZ_CARTERA DIFERIDA'
                                    GROUP BY
                                        ocdn.Orden_CodDDirNegocio,
                                        s.NombreDirNegocio,
                                        REPLACE(rpc.NombreCliente_OK,  '''', ''),
                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')
                                    HAVING
                                           SUM(rpc.ImporteContratado_OK) >=  @Importe
                                        OR SUM(rpc.ImporteContratado_OK) <= -@Importe";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        return (await conn.QueryAsync<ContratacionesSignificativasMesPoco>(
            sqlSelect,
            new {
                Anio             = anio,
                Mes              = mes,
                Mercado          = mercado,
                CodSubDirGeneral = codSubDirGeneral,
                Importe          = importe
            },
            commandTimeout: 300
        )).ToList();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFORME: Gerencias
    // └─ Método: ObtenerGerenciasAsync(int anio, int mes)
    // ═══════════════════════════════════════════════════════════════════════════

    public async Task<List<GerenciasPoco>> ObtenerGerenciasAsync(int anio, int mes)
    {
        // PASO 1: Vaciar tabla de trabajo
        const string sqlDelete = "DELETE FROM rptContratacion_GerenciaCentro";

        // PASO 2: Poblar desde el SP (columnas exactas que devuelve el SP)
        const string sqlInsertExec = @"INSERT INTO rptContratacion_GerenciaCentro (NombreGerente, CodCentro, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior)
                                       EXEC spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS @Anio, @Mes";

        // PASO 3: Asignar el año a todas las filas
        const string sqlUpdateAnio = "UPDATE rptContratacion_GerenciaCentro SET Año = @Anio";

        // PASO 4: SELECT enriquecido con JOINs
        const string sqlSelect = @"SELECT
                                        rpt.Año,
                                        cg.SumarizaGerentes,
                                        rpt.NombreGerente AS Actividad,
                                        cg.Orden,
                                        SUM(ISNULL(rpt.ImporteContratado, 0))                     AS ImporteContratado,
                                        SUM(ISNULL(rpt.ImporteContratadoAcumulado, 0))            AS ImporteContratadoAcumulado,
                                        SUM(ISNULL(rpt.ImporteContratadoAcumuladoAñoAnterior, 0)) AS ImporteContratadoAcumuladoAñoAnterior,
                                        SUM(ISNULL(vw.Importe, 0))                                AS Objetivos,
                                        SUM(ISNULL(act.CarteraPdteAñoActual, 0))                  AS CarteraPdteAñoActual,
                                        SUM(ISNULL(ant.CarteraPdteAñoAnterior, 0))                AS CarteraPdteAñoAnterior
                                    FROM rptContratacion_GerenciaCentro rpt WITH (NOLOCK)
                                    INNER JOIN Sumarigrama s WITH (NOLOCK)
                                        ON rpt.CodCentro = s.CodCentro
                                    INNER JOIN CentrosGerentesSQL cg WITH (NOLOCK)
                                        ON rpt.Año = cg.Año
                                        AND rpt.CodCentro = cg.CodCentro
                                        AND rpt.NombreGerente = cg.NombreGerente
                                    LEFT JOIN dbo.fn_veCarteraPdteProducirSQL_AnioActual(@Anio, @Mes) act
                                        ON rpt.CodCentro = act.CodCentro
                                    LEFT JOIN dbo.fn_veCarteraPdteProducirSQL_AnioAnterior(@Anio, @Mes) ant
                                        ON rpt.CodCentro = ant.CodCentro
                                    LEFT JOIN vwObjetivosActividadSQL_Nacional_Internacional vw WITH (NOLOCK)
                                        ON rpt.CodCentro = vw.CodCentro
                                        AND rpt.Año = vw.Año
                                    GROUP BY
                                        rpt.Año,
                                        cg.SumarizaGerentes,
                                        rpt.NombreGerente,
                                        cg.Orden";

        var parametros = new { 
            Anio = anio, 
            Mes = mes
        };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            await _connection.ExecuteAsync(sqlDelete, transaction: transaction);
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction, commandTimeout: 300);
            await _connection.ExecuteAsync(sqlUpdateAnio, parametros, transaction, commandTimeout: 300);
            var resultado = (await _connection.QueryAsync<GerenciasPoco>(sqlSelect, parametros, transaction, commandTimeout: 300)).ToList();

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
    // INFORME: Mercados SG Delegaciones
    // ═══════════════════════════════════════════════════════════════════════════

    public async Task<List<MercadoSGDelegacionPoco>> ObtenerMercadosSGDelegacionesAsync(
        int anio, int mes,
        string codSubDirGeneral = "221",
        string codSdgOrdenDel = "090")
    {
        const string sqlDelete = "DELETE FROM rptContratacion_SG_Mercado WHERE Año = @Anio OR Año IS NULL";

        const string sqlInsertExec = @"INSERT INTO rptContratacion_SG_Mercado
                                            (Pais, CodCentro, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior)
                                        EXEC spContratacion_Mensual_Acumulada_AñoAnterior_SG_Mercado @Anio, @Mes";

        const string sqlUpdateAnio = "UPDATE rptContratacion_SG_Mercado SET Año = @Anio WHERE Año IS NULL";

        const string sqlSelect = @"WITH CTE_Estructura_Delegacion AS (
                                        SELECT DISTINCT
                                            S.OrdenSubDirGeneral,
                                            S.CodSubDirGeneral,
                                            S.NombreSubDirGeneral,
                                            ONeg.Orden_CodDDirNegocio,
                                            S.CodDDirNegocio,
                                            S.NombreDirNegocio,
                                            S.CodDelegacion,
                                            S.NombreDelegacion,
                                            CASE WHEN S.CodSubDirGeneral = @codSubDirGeneral THEN '' ELSE S.NombreSubDirNegocioArea END AS Area
                                        FROM dbo.Sumarigrama S WITH (NOLOCK)
                                        INNER JOIN dbo.Orden_CodDDirNegocio ONeg WITH (NOLOCK) ON S.CodDDirNegocio = ONeg.CodDDirNegocio
                                        WHERE S.Año = @Anio
                                          AND S.CodSubDirGeneral = @codSubDirGeneral
                                    ),
                                    CTE_Contratacion_Del AS (
                                        SELECT S.CodDelegacion,
                                            SUM(C.ImporteContratado) AS ImporteContratado,
                                            SUM(CASE WHEN ISNULL(CG.Mercado, 'N') = 'N' THEN C.ImporteContratado ELSE 0 END) AS ImporteContratadoNacional,
                                            SUM(CASE WHEN CG.Mercado = 'I' THEN C.ImporteContratado ELSE 0 END) AS ImporteContratadoInternacional,
                                            SUM(C.ImporteContratadoAcumulado) AS ImporteContratadoAcumulado,
                                            SUM(CASE WHEN ISNULL(CG.Mercado, 'N') = 'N' THEN C.ImporteContratadoAcumulado ELSE 0 END) AS ImporteContratadoAcumuladoNacional,
                                            SUM(CASE WHEN CG.Mercado = 'I' THEN C.ImporteContratadoAcumulado ELSE 0 END) AS ImporteContratadoAcumuladoInternacional,
                                            SUM(C.ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnterior
                                        FROM dbo.rptContratacion_SG_Mercado C WITH (NOLOCK)
                                        INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON C.CodCentro = S.CodCentro AND C.Año = S.Año
                                        LEFT JOIN dbo.CentrosGerentesSQL CG WITH (NOLOCK) ON C.CodCentro = CG.CodCentro AND C.Año = CG.Año
                                        WHERE C.Año = @Anio
                                          AND S.CodSubDirGeneral = @codSubDirGeneral
                                        GROUP BY S.CodDelegacion
                                    ),
                                    CTE_Objetivos_Del AS (
                                        SELECT S.CodDelegacion,
                                            SUM(O.Importe) AS ImporteObjetivos,
                                            SUM(CASE WHEN ISNULL(O.Mercado, 'N') = 'N' THEN O.Importe ELSE 0 END) AS ObjetivosNacional,
                                            SUM(CASE WHEN O.Mercado = 'I' THEN O.Importe ELSE 0 END) AS ObjetivosInternacional
                                        FROM dbo.ObjetivosActividadSQL O WITH (NOLOCK)
                                        INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON O.CodCentro = S.CodCentro AND O.Año = S.Año
                                        WHERE O.Año = @Anio
                                          AND S.CodSubDirGeneral = @codSubDirGeneral
                                        GROUP BY S.CodDelegacion
                                    ),
                                    CTE_Cartera_Del AS (
                                        SELECT S.CodDelegacion,
                                            SUM(CASE WHEN Cart.Año = @Anio THEN Importe ELSE 0 END) AS CarteraPdteAñoActual,
                                            SUM(CASE WHEN Cart.Año = @Anio - 1 THEN Importe ELSE 0 END) AS CarteraPdteAñoAnterior
                                        FROM dbo.CarteraPdteProducirSQL Cart WITH (NOLOCK)
                                        INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON Cart.CodCentro = S.CodCentro
                                        WHERE Cart.Mes = (@Mes - 1) AND Cart.Año IN (@Anio, @Anio - 1)
                                          AND S.CodSubDirGeneral = @codSubDirGeneral
                                        GROUP BY S.CodDelegacion
                                    )
                                    SELECT
                                        E.OrdenSubDirGeneral, E.CodSubDirGeneral, E.NombreSubDirGeneral,
                                        E.Orden_CodDDirNegocio, E.CodDDirNegocio,
                                        E.NombreDirNegocio AS NomDirNegocio, E.Area, E.CodDelegacion,
                                        CASE WHEN E.CodSubDirGeneral = @CodSdgOrdenDel THEN E.NombreDelegacion ELSE '' END AS OrdenNombreDelegacion,
                                        E.NombreDelegacion,
                                        ISNULL(C.ImporteContratado, 0) AS ImporteContratado,
                                        ISNULL(C.ImporteContratadoNacional, 0) AS ImporteContratadoNacional,
                                        ISNULL(C.ImporteContratadoInternacional, 0) AS ImporteContratadoInternacional,
                                        ISNULL(C.ImporteContratadoAcumulado, 0) AS ImporteContratadoAcumulado,
                                        ISNULL(C.ImporteContratadoAcumuladoNacional, 0) AS ImporteContratadoAcumuladoNacional,
                                        ISNULL(C.ImporteContratadoAcumuladoInternacional, 0) AS ImporteContratadoAcumuladoInternacional,
                                        ISNULL(C.ImporteContratadoAcumuladoAñoAnterior, 0) AS ImporteContratadoAcumuladoAñoAnterior,
                                        ISNULL(OBJ.ImporteObjetivos, 0) AS Objetivos,
                                        ISNULL(OBJ.ObjetivosNacional, 0) AS ObjetivosNacional,
                                        ISNULL(OBJ.ObjetivosInternacional, 0) AS ObjetivosInternacional,
                                        ISNULL(CART.CarteraPdteAñoActual, 0) AS CarteraPdteAñoActual,
                                        ISNULL(CART.CarteraPdteAñoAnterior, 0) AS CarteraPdteAñoAnterior
                                    FROM CTE_Estructura_Delegacion E
                                    LEFT JOIN CTE_Contratacion_Del C ON E.CodDelegacion = C.CodDelegacion
                                    LEFT JOIN CTE_Objetivos_Del OBJ ON E.CodDelegacion = OBJ.CodDelegacion
                                    LEFT JOIN CTE_Cartera_Del CART ON E.CodDelegacion = CART.CodDelegacion
                                    ORDER BY E.OrdenSubDirGeneral, E.Orden_CodDDirNegocio, E.CodDelegacion";

        var parametros = new
        {
            Anio = anio,
            Mes = mes,
            CodSubDirGeneral = codSubDirGeneral,
            CodSdgOrdenDel = codSdgOrdenDel
        };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            await _connection.ExecuteAsync(sqlDelete, parametros, transaction: transaction);
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 300);
            await _connection.ExecuteAsync(sqlUpdateAnio, parametros, transaction: transaction);

            var resultado = (await _connection.QueryAsync<MercadoSGDelegacionPoco>(sqlSelect, parametros, transaction: transaction)).ToList();

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
    // INFORME: Cartera Contratación Detalle
    // ═══════════════════════════════════════════════════════════════════════════

    public async Task<List<CarteraContratacionDetallePoco>> ObtenerCarteraContratacionDetalleAsync(
        int anio, int mes, int todoInternacional, decimal limiteImporte, int limitePaises, string informe)
    {
        const string sqlDelete = @"DELETE FROM rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises 
                                   WHERE AnioInforme = @Anio AND MesInforme = @Mes";
        
        const string sqlExec = "EXEC spCarteraContratacionDetalle_DGDesarrolloInternacional_DosAños @Anio, @Mes, @TodoInternacional, @LimiteImporte, @LimitePaises, @Informe";

        const string sqlInsert = @"INSERT INTO rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises
                                            (AnioInforme, MesInforme, Pais, NomCliente, DesOferta, ImporteCarteraOferta, ImporteContratadoOferta, ImporteCarteraPais)
                                       VALUES
                                            (@AnioInforme, @MesInforme, @Pais, @NomCliente, @DesOferta, @ImporteCarteraOferta, @ImporteContratadoOferta, @ImporteCarteraPais)";
        
        const string sqlSelect = @"SELECT AnioInforme, MesInforme, Pais, DesOferta, NomCliente, ImporteCarteraOferta, ImporteContratadoOferta, ImporteCarteraPais
                                   FROM rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises WITH (NOLOCK)
                                   WHERE AnioInforme = @Anio 
                                     AND MesInforme = @Mes 
                                     AND (ISNULL(ImporteCarteraOferta, 0) + ISNULL(ImporteContratadoOferta, 0)) <> 0";

        var parametros = new { 
            Anio = anio, Mes = mes, TodoInternacional = todoInternacional, 
            LimiteImporte = limiteImporte, LimitePaises = limitePaises, Informe = informe 
        };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            await _connection.ExecuteAsync(sqlDelete, parametros, transaction: transaction);

            var datosSp = (await _connection.QueryAsync<CarteraContratacionDetallePoco>(sqlExec, parametros, transaction, commandTimeout: 600)).ToList();

            if (datosSp.Count > 0)
            {
                var datosTransformados = datosSp.Select(d => new
                {
                    d.AnioInforme,
                    d.MesInforme,
                    d.Pais,
                    d.NomCliente,
                    d.DesOferta,
                    d.ImporteCarteraOferta,
                    ImporteContratadoOferta = (d.ImporteContratadoOferta ?? 0) / 1000m,
                    d.ImporteCarteraPais
                }).ToList();

                await _connection.ExecuteAsync(sqlInsert, datosTransformados, transaction: transaction, commandTimeout: 600);
            }

            var resultado = (await _connection.QueryAsync<CarteraContratacionDetallePoco>(sqlSelect, parametros, transaction)).ToList();

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

