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

using Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionResumenSDG;

using Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetalleOrgPaises;

using Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetallePaises;

using Elecnor_Informes_Comerciales.Models.Informes.ActividadesInternacionalDetalle;

using Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosSDGDN;

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

    public async Task<(List<CarteraDiferidaConsejoPoco> Principal, List<MercadoAIPoco> mercadoAI, List<CarteraProducirPoco> Cartera, List<CarteraDiferidaPoco> CarteraDiferida, List<VentasPoco> Ventas)> ObtenerCarteraDiferidaConsejoAsync(int anio, int mes, string loginUsuario)

    {

        // SECCIÓN A: INFORME PRINCIPAL (Mercados por País)

        const string sqlDeletePrincipal = @"DELETE FROM rptContratacion_DG_SDG_DN_SDNA 

                                            WHERE LoginUsuario = @LoginUsuario 

                                               OR FechaCreacion < DATEADD(hour, -1, GETDATE())";

        const string sqlExecPrincipal = "EXEC spContratacion_DG_SDG_DN_SDNA @Anio, @Mes, @LoginUsuario";

        const string sqlInsertManualPrincipal = @"INSERT INTO rptContratacion_DG_SDG_DN_SDNA (Año, CodSubDirGeneral, NombreSubDirGeneral, NombreDirNegocio, NombreSubDirNegocioArea, Pais, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteObjetivo, LoginUsuario)

                                                VALUES (@Anio, @CodSubDirGeneral, @NombreSubDirGeneral, @NombreDirNegocio, @NombreSubDirNegocioArea, @Pais, @ImporteContratado, @ImporteContratadoAcumulado, @ImporteContratadoAcumuladoAñoAnterior, @ImporteObjetivo, @LoginUsuario)";



        const string sqlSelectPrincipal = @"WITH CTE_Objetivos AS (

                                                SELECT DISTINCT

                                                    NombreDirNegocio,

                                                    Pais,

                                                    ImporteObjetivo

                                                FROM rptContratacion_DG_SDG_DN_SDNA

                                                WHERE LoginUsuario = @LoginUsuario

                                                  AND ImporteObjetivo > 0

                                            )

                                            SELECT

                                                c.Año,

                                                c.Pais,

                                                SUM(c.ImporteContratado)                        AS Importe_Contratado,

                                                SUM(c.ImporteContratadoAcumulado)               AS Importe_ContratadoAcumulado,

                                                SUM(c.ImporteContratadoAcumuladoAñoAnterior)    AS ImporteContratadoAcumuladoAñoAnterior,

                                                (SELECT ISNULL(SUM(ImporteObjetivo), 0)

                                                 FROM CTE_Objetivos

                                                 WHERE Pais = c.Pais)                          AS Objetivos,

                                                dbo.fgRedondear(

                                                    (SELECT ISNULL(SUM(ImporteObjetivo), 0)

                                                     FROM CTE_Objetivos

                                                     WHERE Pais = c.Pais) / 12, 0)             AS ObjetivosMensual

                                            FROM

                                                rptContratacion_DG_SDG_DN_SDNA AS c

                                            WHERE c.LoginUsuario = @LoginUsuario AND c.Pais <> ''

                                            GROUP BY c.Año, c.Pais;";



        // SECCIÓN B: ASOCIADO INVERSIÓN (MercadoAI)

        const string sqlDeleteSub = @"DELETE FROM rptContratacionAsociadoInversion 

                                      WHERE LoginUsuario = @LoginUsuario 

                                         OR FechaCreacion < DATEADD(hour, -1, GETDATE())";

        const string sqlInsertExecSub = "EXEC spWEB_ContratacionAsociadoInversion @Anio, @Mes, @LoginUsuario";

        const string sqlUpdateAnioSub = "UPDATE rptContratacionAsociadoInversion SET Año = @Anio WHERE LoginUsuario = @LoginUsuario";



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

                                                    r.Mercado = v.Mercado

                                                AND r.LoginUsuario = v.LoginUsuario

                                            WHERE r.LoginUsuario = @LoginUsuario AND (r.Acumulado_Contratacion <> 0 OR r.Mensual_Contratacion <> 0)";



    string sqlSelectCartera = @"

            IF EXISTS (SELECT 1 FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE UPPER(Usuario) = UPPER(@LoginUsuario) AND Puesto = 'DG')

            BEGIN

                SELECT 

                    Año, 

                    Mes, 

                    Concepto, 

                    ImporteInicial, 

                    ImporteActual, 

                    PorcentajeIncrementoAñoAnterior, 

                    SumarCartera, 

                    CarteraAñoAnterior

                FROM dbo.CarteraActual_CJO WITH (NOLOCK)

                WHERE Año = @Anio AND Mes = @Mes

                  AND (

                      SumarCartera = 1

                      OR (

                          SumarCartera = 0

                          AND (ImporteInicial <> 0 OR ImporteActual <> 0)

                      )

                  )

                ORDER BY 

                    SumarCartera DESC, 

                    CASE Concepto 

                        WHEN 'Nacional' THEN 1 

                        WHEN 'Internacional' THEN 2 

                        WHEN 'Asociado a Inversión' THEN 3 

                        ELSE 4 

                    END;

            END

            ELSE

            BEGIN

                -- 1. Crear y poblar centros permitidos del usuario

                CREATE TABLE #CentrosUsuario (CodCentro VARCHAR(10) PRIMARY KEY);

                

                INSERT INTO #CentrosUsuario (CodCentro)

                SELECT DISTINCT CodCentro

                FROM dbo.SumarigramaHistorico s WITH (NOLOCK)

                INNER JOIN dbo.WEB_Usuarios u WITH (NOLOCK) ON UPPER(u.Usuario) = UPPER(@LoginUsuario)

                WHERE s.Año = @Anio

                  AND (

                      (u.Puesto = 'SDG'  AND s.CodSubDirGeneral = u.CodEntidad)

                      OR (u.Puesto = 'DN'   AND s.CodDDirNegocio = u.CodEntidad)

                      OR (u.Puesto = 'AREA' AND s.CodSubDirNegocioArea = u.CodEntidad)

                      OR (u.Puesto = 'DEL'  AND s.CodDelegacion = u.CodEntidad)

                      OR (u.Puesto = 'CT'   AND s.CodCentro = u.CodEntidad)

                  );



                -- 2. Crear y poblar proporciones asociadas (filtrado temprano de centros)

                CREATE TABLE #Proporciones (

                    AnioInforme INT,

                    MesInforme INT,

                    CentroChar VARCHAR(10),

                    PaisPredominante VARCHAR(20),

                    ProporcionAsoc DECIMAL(18,6),

                    PRIMARY KEY (AnioInforme, MesInforme, CentroChar)

                );



                INSERT INTO #Proporciones (AnioInforme, MesInforme, CentroChar, PaisPredominante, ProporcionAsoc)

                SELECT 

                    cc.AnioInforme,

                    cc.MesInforme,

                    cc.CentroChar,

                    MAX(CASE WHEN cc.Pais = 'Nacional' THEN 'Nacional' ELSE 'Internacional' END),

                    CASE WHEN SUM(cc.ImporteEUR) = 0 THEN 0 ELSE SUM(CASE WHEN oa.JVAYNB IS NOT NULL THEN cc.ImporteEUR ELSE 0 END) / SUM(cc.ImporteEUR) END

                FROM dbo.CarterasContratacionSQL cc WITH (NOLOCK)

                LEFT JOIN dbo.OfertaAsociadaInversion oa WITH (NOLOCK) ON cc.CodOferta = oa.JVAYNB

                INNER JOIN #CentrosUsuario cu ON cc.CentroChar = cu.CodCentro

                WHERE 

                    (cc.AnioInforme = @Anio AND cc.MesInforme = @Mes)

                    OR (cc.AnioInforme = @Anio - 1 AND cc.MesInforme = 12)

                    OR (cc.AnioInforme = @Anio - 2 AND cc.MesInforme = 12)

                GROUP BY cc.AnioInforme, cc.MesInforme, cc.CentroChar;



                -- 3. Consulta de importes agregados por categorías usando CROSS APPLY y Agregación Condicional (Pivot)

                WITH CTE_CarteraBase AS (

                    SELECT 

                        c.CodCentro,

                        c.Año,

                        c.Mes,

                        c.Importe,

                        ISNULL(p.PaisPredominante, 'Nacional') AS PaisPredominante,

                        ISNULL(p.ProporcionAsoc, 0) AS ProporcionAsoc

                    FROM dbo.CarteraPdteProducirSQL c WITH (NOLOCK)

                    INNER JOIN #CentrosUsuario cu ON c.CodCentro = cu.CodCentro

                    LEFT JOIN #Proporciones p ON c.CodCentro = p.CentroChar AND c.Año = p.AnioInforme AND c.Mes = p.MesInforme

                    WHERE 

                        (c.Año = @Anio AND c.Mes = @Mes)

                        OR (c.Año = @Anio - 1 AND c.Mes = 12)

                        OR (c.Año = @Anio - 2 AND c.Mes = 12)

                ),

                CTE_Categorias AS (

                    SELECT 

                        v.Concepto,

                        v.SumarCartera,

                        c.Año,

                        c.Mes,

                        SUM(v.ImporteCalculado) AS Importe

                    FROM CTE_CarteraBase c

                    CROSS APPLY (

                        VALUES 

                            -- 1. Nacional (Sumable)

                            (CASE WHEN c.PaisPredominante = 'Nacional' THEN 'Nacional' END, 1, c.Importe * (1 - c.ProporcionAsoc)),

                            -- 2. Internacional (Sumable)

                            (CASE WHEN c.PaisPredominante = 'Internacional' THEN 'Internacional' END, 1, c.Importe * (1 - c.ProporcionAsoc)),

                            -- 3. Asociado a Inversión (Sumable)

                            ('Asociado a Inversión', 1, c.Importe * c.ProporcionAsoc),

                            -- 4. Nacional (Desglose no sumable)

                            (CASE WHEN c.PaisPredominante = 'Nacional' THEN 'Nacional' END, 0, c.Importe * c.ProporcionAsoc),

                            -- 5. Internacional (Desglose no sumable)

                            (CASE WHEN c.PaisPredominante = 'Internacional' THEN 'Internacional' END, 0, c.Importe * c.ProporcionAsoc)

                    ) v(Concepto, SumarCartera, ImporteCalculado)

                    WHERE v.Concepto IS NOT NULL

                    GROUP BY v.Concepto, v.SumarCartera, c.Año, c.Mes

                )

                SELECT 

                    @Anio AS Año,

                    @Mes AS Mes,

                    Concepto,

                    SUM(CASE WHEN Año = @Anio - 1 AND Mes = 12 THEN Importe ELSE 0 END) AS ImporteInicial,

                    SUM(CASE WHEN Año = @Anio AND Mes = @Mes THEN Importe ELSE 0 END) AS ImporteActual,

                    CASE 

                        WHEN SUM(CASE WHEN Año = @Anio - 1 AND Mes = 12 THEN Importe ELSE 0 END) = 0 THEN 0 

                        ELSE (SUM(CASE WHEN Año = @Anio AND Mes = @Mes THEN Importe ELSE 0 END) - SUM(CASE WHEN Año = @Anio - 1 AND Mes = 12 THEN Importe ELSE 0 END)) / SUM(CASE WHEN Año = @Anio - 1 AND Mes = 12 THEN Importe ELSE 0 END) 

                    END AS PorcentajeIncrementoAñoAnterior,

                    SumarCartera,

                    SUM(CASE WHEN Año = @Anio - 2 AND Mes = 12 THEN Importe ELSE 0 END) AS CarteraAñoAnterior

                FROM CTE_Categorias

                GROUP BY Concepto, SumarCartera

                HAVING 

                    SumarCartera = 1

                    OR (

                        SumarCartera = 0

                        AND (

                            SUM(CASE WHEN Año = @Anio - 1 AND Mes = 12 THEN Importe ELSE 0 END) <> 0

                            OR SUM(CASE WHEN Año = @Anio AND Mes = @Mes THEN Importe ELSE 0 END) <> 0

                        )

                    )

                ORDER BY 

                    SumarCartera DESC, 

                    CASE Concepto 

                        WHEN 'Nacional' THEN 1 

                        WHEN 'Internacional' THEN 2 

                        WHEN 'Asociado a Inversión' THEN 3 

                        ELSE 4 

                    END OPTION (RECOMPILE);



                -- 4. Limpieza de tablas temporales

                DROP TABLE #CentrosUsuario;

                DROP TABLE #Proporciones;

            END";





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

                                            [2025] AS Anio2025,

                                            [2026] AS Anio2026,

                                            [2027] AS Anio2027

                                         FROM VentasRPT

                                         ORDER BY Mercado DESC";



        // ─────────────────────────────────────────────────────────────────────────────────

        // ─────────────────────────────────────────────────────────────────────────────────



        var parametros = new { Anio = anio, Mes = mes, LoginUsuario = loginUsuario };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            // ── Ejecución Sección A: Informe Principal ──

            var datosSp = (await _connection.QueryAsync<dynamic>(sqlExecPrincipal, parametros, transaction: transaction, commandTimeout: 300)).ToList();

            await _connection.ExecuteAsync(sqlDeletePrincipal, new { LoginUsuario = loginUsuario }, transaction: transaction, commandTimeout: 300);

            

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

                    ImporteObjetivo = fila.ImporteObjetivo,

                    LoginUsuario = loginUsuario

                }, transaction: transaction, commandTimeout: 300);

            }



            var principal = (await _connection.QueryAsync<CarteraDiferidaConsejoPoco>(sqlSelectPrincipal, parametros, transaction, commandTimeout: 300)).ToList();



            // ── Ejecución Sección B: MercadoAI ──

            await _connection.ExecuteAsync(sqlDeleteSub, new { LoginUsuario = loginUsuario }, transaction: transaction, commandTimeout: 300);

            await _connection.ExecuteAsync(sqlInsertExecSub, parametros, transaction: transaction, commandTimeout: 300);

            await _connection.ExecuteAsync(sqlUpdateAnioSub, parametros, transaction: transaction, commandTimeout: 300);

            var mercadoAI = (await _connection.QueryAsync<MercadoAIPoco>(sqlSelectMercadoAI, parametros, transaction, commandTimeout: 300)).ToList();



            // ── Ejecución Sección C: CarteraProduccion ──

            var cartera = (await _connection.QueryAsync<CarteraProducirPoco>(sqlSelectCartera, parametros, transaction, commandTimeout: 300)).ToList();



            // ── Ejecución Sección D: CarteraDiferida (Consolidado oficial) ──

            string colCart1_1 = $"[01#01#{anio % 100:00}]";

            string colAnio1 = $"[{anio}]";

            string colAnio2 = $"[{anio + 1}]";

            string colAnio3 = $"[{anio + 2}]";



            string sqlSelectDiferida = $@"

                SELECT 

                    Año, Mes, Mercado, [Cartera Diferida] AS CarteraDiferida, 

                    {colCart1_1} AS ValorCart1_1, Nuevos, Total, Contr, 

                    {colAnio1} AS ValorAnio1, {colAnio2} AS ValorAnio2, {colAnio3} AS ValorAnio3, 

                    Orden

                FROM CarteraDiferida_CJO WITH (NOLOCK)

                WHERE Año = @Anio AND Mes = @Mes AND [Cartera Diferida] IS NOT NULL";



            var carteraDiferida = (await _connection.QueryAsync<CarteraDiferidaPoco>(sqlSelectDiferida, parametros, transaction, commandTimeout: 300)).ToList();



            // ── Ejecución Sección E: Ventas (lectura directa) ──

            var ventas = (await _connection.QueryAsync<VentasPoco>(sqlSelectVentas, transaction: transaction, commandTimeout: 300)).ToList();



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

    public async Task<List<MercadosPoco>> ObtenerMercadosAsync(int anio, int mes, string loginUsuario)

    {

        const string sqlDelete = @"DELETE FROM rptContratacion_DG_SDG_DN_SDNA 

                                   WHERE LoginUsuario = @LoginUsuario 

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";

        const string sqlExec = "EXEC spContratacion_DG_SDG_DN_SDNA @Anio, @Mes, @LoginUsuario";



        const string sqlInsertManual = @"INSERT INTO rptContratacion_DG_SDG_DN_SDNA (Año, CodSubDirGeneral, NombreSubDirGeneral, NombreDirNegocio, NombreSubDirNegocioArea, Pais, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteObjetivo, LoginUsuario)

                                         VALUES (@Anio, @CodSubDirGeneral, @NombreSubDirGeneral, @NombreDirNegocio, @NombreSubDirNegocioArea, @Pais, @ImporteContratado, @ImporteContratadoAcumulado, @ImporteContratadoAcumuladoAñoAnterior, @ImporteObjetivo, @LoginUsuario)";



        const string sqlSelect = @"WITH CTE_Objetivos AS (

                                        SELECT DISTINCT

                                            CodSubDirGeneral,

                                            NombreDirNegocio,

                                            Pais,

                                            ImporteObjetivo

                                        FROM rptContratacion_DG_SDG_DN_SDNA

                                        WHERE LoginUsuario = @LoginUsuario

                                          AND ImporteObjetivo > 0

                                    ),

                                    CTE_ObjetivosSDGPais AS (

                                        SELECT

                                            CodSubDirGeneral,

                                            Pais,

                                            SUM(ImporteObjetivo) AS ObjetivoSDGPais

                                        FROM CTE_Objetivos

                                        GROUP BY CodSubDirGeneral, Pais

                                    ),

                                    CTE_ObjetivosPais AS (

                                        SELECT

                                            Pais,

                                            SUM(ImporteObjetivo) AS ObjetivoPais

                                        FROM CTE_Objetivos

                                        GROUP BY Pais

                                    )

                                    SELECT

                                        rpt.Año,

                                        MAX(sg.Orden) AS Orden,

                                        rpt.Pais,

                                        rpt.NombreSubDirGeneral,

                                        rpt.NombreDirNegocio,

                                        SUM(rpt.ImporteContratado) AS ImporteContratado,

                                        SUM(rpt.ImporteContratadoAcumulado) AS ImporteContratadoAcumulado,

                                        SUM(rpt.ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnterior,

                                        MAX(ISNULL(rpt.ImporteObjetivo, 0)) AS ImporteObjetivo,

                                        MAX(ISNULL(sdgPais.ObjetivoSDGPais, 0)) AS ObjetivoSDGPais,

                                        MAX(ISNULL(pais.ObjetivoPais, 0)) AS ObjetivoPais

                                    FROM rptContratacion_DG_SDG_DN_SDNA rpt

                                    LEFT JOIN CTE_ObjetivosSDGPais sdgPais

                                        ON rpt.CodSubDirGeneral = sdgPais.CodSubDirGeneral

                                       AND rpt.Pais = sdgPais.Pais

                                    LEFT JOIN CTE_ObjetivosPais pais

                                        ON rpt.Pais = pais.Pais

                                    LEFT JOIN SubDirGeneral sg

                                        ON rpt.CodSubDirGeneral = sg.CodSubDirGeneral

                                    WHERE rpt.LoginUsuario = @LoginUsuario

                                      AND rpt.Pais <> ''

                                    GROUP BY

                                        rpt.Año, rpt.Pais, rpt.NombreSubDirGeneral, rpt.NombreDirNegocio";



        var parametros = new { Anio = anio, Mes = mes, LoginUsuario = loginUsuario };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            // 1. Obtener datos desde el procedimiento almacenado

            var datosSp = (await _connection.QueryAsync<dynamic>(sqlExec, parametros, transaction: transaction)).ToList();

            

            // 2. Limpiar tabla de trabajo para la sesión

            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);

            

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

                    ImporteObjetivo = fila.ImporteObjetivo,

                    LoginUsuario = loginUsuario

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



        string colCartPrev = $"[01#01#{(anio - 1).ToString().Substring(2)}]";

        string colCartAct  = $"[01#01#{(anio).ToString().Substring(2)}]";

        string colFuturo1  = $"[{anio}]";

        string colFuturo2  = $"[{anio + 1}]";

        string colFuturo3  = $"[{anio + 2}]";



        string sql = $@"

            SELECT

                [Cartera Diferida] AS CarteraDiferida,

                {colCartPrev}      AS ValorCartPrev,

                {colCartAct}       AS ValorCartAct,

                {colFuturo1}       AS ValorFuturo1,

                {colFuturo2}       AS ValorFuturo2,

                {colFuturo3}       AS ValorFuturo3,

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

    public async Task<List<PaisesPoco>> ObtenerPaisesAsync(int anio, int mes, string loginUsuario)

    {

        // ─── PASO 1: Vaciar la tabla de trabajo ───

        const string sqlDelete = @"DELETE FROM rptContratacion_Internacional 

                                   WHERE LoginUsuario = @LoginUsuario 

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";



        // ─── PASO 2: Poblado automático vía SP (el SP original de Access) ───

        // Sincronizado con las 5 columnas que devuelve el SP (según inspección)

        // WEB: Usa spContratacion_InternacionalWEB (versión optimizada con pushdown a AS/400).

        //      El SP original spContratacion_Internacional se mantiene intacto para otras apps.

        const string sqlInsertExec = @"INSERT INTO rptContratacion_Internacional (codProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)

                                       EXEC spContratacion_InternacionalWEB @Anio, @Mes, @LoginUsuario";



        // Asignamos el Año (campo extra) para que el SELECT lo encuentre

        const string sqlUpdateAnio = @"UPDATE rptContratacion_Internacional 

                                       SET Año = @Anio, LoginUsuario = @LoginUsuario 

                                       WHERE Año IS NULL AND LoginUsuario = 'ACCESS'";



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

                                            WHERE Año = @Anio AND LoginUsuario = @LoginUsuario



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



        var parametros = new { Anio = anio, Mes = mes, LoginUsuario = loginUsuario };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);

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

    public async Task<List<PaisesPoco>> ObtenerPaisesAllAsync(int anio, int mes, string loginUsuario)

    {

        // ─── PASO 1: Vaciar la tabla de trabajo (misma que el internacional) ───

        const string sqlDelete = @"DELETE FROM rptContratacion_Internacional 

                                   WHERE LoginUsuario = @LoginUsuario 

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";

 

        // ─── PASO 2: Poblado vía SP (Paises ALL: Nac + Int) ───

        const string sqlInsertExec = @"INSERT INTO rptContratacion_Internacional (codProv, Pais, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Ajuste)

                                       EXEC spContratacion_NacIntTODO @Anio, @Mes, '', @LoginUsuario";

 

        const string sqlUpdateAnio = @"UPDATE rptContratacion_Internacional 

                                       SET Año = @Anio, LoginUsuario = @LoginUsuario 

                                       WHERE Año IS NULL AND LoginUsuario = 'ACCESS'";

 

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

                                            WHERE Año = @Anio AND LoginUsuario = @LoginUsuario

 

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





        var parametros = new { Anio = anio, Mes = mes, LoginUsuario = loginUsuario };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);

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

    public async Task<List<ActividadPoco>> ObtenerActividadesAsync(int anio, int mes, string loginUsuario)

    {

        const string sqlDelete = @"DELETE FROM rptContratacion_Actividad 

                                   WHERE LoginUsuario = @LoginUsuario 

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";



        const string sqlInsertExec = @" INSERT INTO rptContratacion_Actividad (NombreDirGeneral, Pais, CodActividad, Actividad, Orden, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteContratadoAcumuladoLastYear, Año, LoginUsuario)

                                        EXEC spContratacion_Actividades_Ajuste @Anio, @Mes, @LoginUsuario";



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

                                    ON  a.Pais = c.Pais AND a.Agrupacion = c.Actividad AND c.LoginUsuario = @LoginUsuario

                                    GROUP BY

                                        a.Pais,

                                        a.Agrupacion,

                                        a.Orden

                                    ORDER BY

                                        ImporteContratadoAcumuladosAñoAnterior DESC";



        var parametros = new { Anio = anio, Mes = mes, LoginUsuario = loginUsuario };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);

            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 300);

            

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

    public async Task<List<ActividadObjetivoPoco>> ObtenerActividadesObjetivosAsync(int anio, int mes, string loginUsuario)

    {

        const string sqlDelete = @"DELETE FROM rptContratacion_Actividad 

                                   WHERE LoginUsuario = @LoginUsuario 

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";



        const string sqlInsertExec = @"INSERT INTO rptContratacion_Actividad (NombreDirGeneral, Pais, CodActividad, Actividad, Orden, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, ImporteContratadoAcumuladoLastYear, Año, LoginUsuario)

                                       EXEC spContratacion_Actividades_Ajuste @Anio, @Mes, @LoginUsuario";



        const string sqlSelect = @";WITH CTE_FiltroSumarigrama AS (

                                        SELECT DISTINCT s.CodCentro

                                        FROM dbo.Sumarigrama s WITH (NOLOCK)

                                        OUTER APPLY (

                                            SELECT TOP 1 u.Puesto, u.CodEntidad

                                            FROM dbo.WEB_Usuarios u WITH (NOLOCK)

                                            WHERE u.Usuario = @LoginUsuario

                                        ) u

                                        WHERE s.Año = @Anio

                                          AND (@LoginUsuario IS NULL OR

                                               u.Puesto IS NULL OR

                                               u.Puesto = 'DG' OR

                                               (u.Puesto = 'SDG'  AND s.CodSubDirGeneral = u.CodEntidad) OR

                                               (u.Puesto = 'DN'   AND s.CodDDirNegocio = u.CodEntidad) OR

                                               (u.Puesto = 'AREA' AND s.CodSubDirNegocioArea = u.CodEntidad) OR

                                               (u.Puesto = 'DEL'  AND s.CodDelegacion = u.CodEntidad) OR

                                               (u.Puesto = 'CT'   AND s.CodCentro = u.CodEntidad))

                                    ),

                                    CTE_BaseActividades AS (

                                        SELECT DISTINCT

                                            p.Pais,

                                            a.Agrupacion AS Actividad

                                        FROM ActividadesSQL a WITH (NOLOCK)

                                        CROSS JOIN Pais p WITH (NOLOCK)

                                    ),

                                    CTE_ActividadesCDAC AS (

                                        SELECT Agrupacion, dbo.fnCDAC(CDAC1, CDAC2) AS CDAC

                                        FROM dbo.ActividadesSQL WITH (NOLOCK)

                                        GROUP BY Agrupacion, dbo.fnCDAC(CDAC1, CDAC2)

                                    ),

                                    CTE_Objetivos AS (

                                        SELECT

                                            ac.Agrupacion,

                                            @Anio AS Año,

                                            CASE WHEN oa.Mercado = 'N' THEN 'Nacional' ELSE 'Internacional' END AS Mercados,

                                            SUM(oa.Importe) AS ImporteObjetivos

                                        FROM dbo.ObjetivosActividadSQL oa WITH (NOLOCK)

                                        INNER JOIN CTE_FiltroSumarigrama f ON oa.CodCentro = f.CodCentro

                                        INNER JOIN CTE_ActividadesCDAC ac ON dbo.fnCDAC(oa.CDAC1, oa.CDAC2) = ac.CDAC

                                        WHERE oa.Año = @Anio

                                        GROUP BY ac.Agrupacion,

                                                 CASE WHEN oa.Mercado = 'N' THEN 'Nacional' ELSE 'Internacional' END

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

                                        AND rpt.LoginUsuario = @LoginUsuario

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



        var parametros = new { Anio = anio, Mes = mes, LoginUsuario = loginUsuario };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);

            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 300);



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

    public async Task<decimal?> ObtenerTotalCarteraGeneralAsync(int anio, int mes, int todoInternacional)

    {

        string sql;

        if (todoInternacional == 1)

        {

            sql = @"

                SELECT SUM(ISNULL(C.ImporteEUR, 0))

                FROM CarterasContratacionSQL C WITH (NOLOCK)

                LEFT JOIN Sumarigrama S WITH (NOLOCK)

                    ON C.CentroChar = S.CodCentro AND C.AnioInforme = S.Año

                WHERE C.AnioInforme = @Anio

                  AND C.MesInforme = @Mes";

        }

        else

        {

            sql = @"

                SELECT SUM(ISNULL(C.ImporteEUR, 0))

                FROM CarterasContratacionSQL C WITH (NOLOCK)

                LEFT JOIN Sumarigrama S WITH (NOLOCK)

                    ON C.CentroChar = S.CodCentro AND C.AnioInforme = S.Año

                WHERE C.AnioInforme = @Anio

                  AND C.MesInforme = @Mes

                  AND C.Pais <> 'Nacional'";

        }



        using var conn = new SqlConnection(_connectionString);

        return await conn.ExecuteScalarAsync<decimal?>(sql, new { Anio = anio, Mes = mes });

    }



    /// <summary>

    /// Obtiene los datos para el informe de Principales Contrataciones del Año.

    /// Datos acumulados desde Enero hasta el mes seleccionado.

    /// </summary>

    public async Task<List<ContratacionesPoco>> ObtenerContratacionesAsync(int anio, int mes, decimal importe, string pais, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

                                         REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,

                                         REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,

                                         SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK

                                     FROM

                                         rptPrincipalesObras rpt WITH (NOLOCK)

                                     INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año

                                     WHERE rpt.Año = @Anio

                                       AND rpt.Mes = @Mes

                                       AND rpt.Ocultar = 0

                                       AND rpt.Pais = @Pais

                                       AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN'

                                       AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'

                                       AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'

                                       AND (

                                           @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                           OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)

                                           OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)

                                           OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)

                                           OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)

                                           OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)

                                       )

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

            Pais = pais,

            LoginUsuario = loginUsuario

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

    public async Task<List<ContratacionesAnnoNacionalAnteriorPoco>> ObtenerContratacionesAnnoNacionalAnteriorAsync(int anio, int mes, decimal importe, string pais, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

                                         '' AS Meses,

                                         REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,

                                         rpt.NombreDirNegocio_OK,

                                         REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,

                                         SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK,

                                         CASE WHEN oai.JVAYNB IS NOT NULL THEN 'AI' ELSE '' END AS AI

                                     FROM

                                         rptPrincipalesObras rpt WITH (NOLOCK)

                                     INNER JOIN

                                         dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año

                                     LEFT JOIN

                                         OfertaAsociadaInversion oai WITH (NOLOCK) ON rpt.CodOferta = oai.JVAYNB

                                     WHERE

                                         rpt.Año = @Anio

                                         AND rpt.Mes < @Mes

                                         AND rpt.Ocultar = 0

                                         AND rpt.Pais = @Pais

                                         AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN'

                                         AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'

                                         AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'

                                         AND (

                                             @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                             OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)

                                             OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)

                                             OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)

                                             OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)

                                             OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)

                                         )

                                     GROUP BY

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

                Pais = pais,

                LoginUsuario = loginUsuario

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

    public async Task<List<ContratacionesAnnoInternacionalMesPoco>> ObtenerContratacionesAnnoInternacionalMesAsync(int anio, int mes, decimal importe, string pais, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

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

                                     INNER JOIN

                                         dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año

                                     LEFT JOIN

                                         OfertaAsociadaInversion oai WITH (NOLOCK) ON rpt.CodOferta = oai.JVAYNB

                                     WHERE

                                         rpt.Año = @Anio

                                         AND rpt.Mes = @Mes

                                         AND rpt.Ocultar = 0

                                         AND rpt.Pais = @Pais

                                         AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN'

                                         AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'

                                         AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'

                                         AND (

                                             @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                             OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)

                                             OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)

                                             OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)

                                             OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)

                                             OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)

                                         )

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

                Pais = pais,

                LoginUsuario = loginUsuario

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

    public async Task<List<ContratacionesAnnoInternacionalAnteriorPoco>> ObtenerContratacionesAnnoInternacionalAnteriorAsync(int anio, int mes, decimal importe, string pais, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

                                        '' AS Meses,

                                        REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,

                                        REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,

                                        SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK,

                                        CASE WHEN oai.JVAYNB IS NOT NULL THEN 'AI' ELSE '' END AS AI,

                                        rpt.NombreDirNegocio_OK

                                    FROM

                                        rptPrincipalesObras rpt WITH (NOLOCK)

                                    INNER JOIN

                                        dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año

                                    LEFT JOIN

                                        OfertaAsociadaInversion oai WITH (NOLOCK) ON rpt.CodOferta = oai.JVAYNB

                                    WHERE

                                        rpt.Año = @Anio

                                        AND rpt.Mes < @Mes

                                        AND rpt.Ocultar = 0

                                        AND rpt.Pais = @Pais

                                        AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN'

                                        AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'

                                        AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'

                                        AND (

                                            @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                            OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)

                                            OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)

                                            OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)

                                            OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)

                                            OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)

                                        )

                                    GROUP BY

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

                Pais = pais,

                LoginUsuario = loginUsuario

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

    public async Task<List<ContratacionesAIPoco>> ObtenerContratacionesAIAsync(int anio, int mes, decimal importe, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

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

                                      INNER JOIN

                                          dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año

                                      WHERE

                                          rpt.Año = @Anio

                                          AND rpt.Mes = @Mes

                                          AND rpt.Ocultar = 0

                                          AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN'

                                          AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'

                                          AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'

                                          AND (

                                              @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                              OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)

                                              OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)

                                              OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)

                                              OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)

                                              OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)

                                          )

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

            new { Anio = anio, Mes = mes, Importe = importe, LoginUsuario = loginUsuario },

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

    public async Task<List<ContratacionesAIPoco>> ObtenerContratacionesAnnoAIAnteriorAsync(int anio, int mes, decimal importe, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

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

                                      INNER JOIN

                                          dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año

                                     WHERE

                                         rpt.Año = @Anio

                                         AND rpt.Mes < @Mes

                                         AND rpt.Ocultar = 0

                                         AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN'

                                         AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'

                                         AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'

                                         AND (

                                             @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                             OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)

                                             OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)

                                             OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)

                                             OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)

                                             OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)

                                         )

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

            new { Anio = anio, Mes = mes, Importe = importe, LoginUsuario = loginUsuario },

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

    public async Task EjecutarSPObrasRankingClientesAsync(string mercado, int anio, int mes, string loginUsuario)

    {

        using var conn = new SqlConnection(_connectionString);

        await conn.OpenAsync();

        using var transaction = await conn.BeginTransactionAsync();



        try

        {

            // 1. Limpiar tabla de trabajo

            await conn.ExecuteAsync(@"DELETE FROM rptContratacion_Clientes 

                                      WHERE LoginUsuario = @LoginUsuario 

                                         OR FechaCreacion < DATEADD(hour, -1, GETDATE())", 

                                    new { LoginUsuario = loginUsuario }, transaction: transaction);



            // 2. Ejecutar SP (4 parámetros: Mercado, Año, Mes, LoginUsuario) y obtener resultados en memoria

            // El SP devuelve ImporteContratadoAcumuladoAñoAnterior en Real Euros.

            var resultadosSp = (await conn.QueryAsync<RankingClientesSpResult>( "EXEC spContratacion_Clientes @Mercado, @Anio, @Mes, @LoginUsuario",

                                                                                    new { Mercado = mercado, Anio = anio, Mes = mes, LoginUsuario = loginUsuario },

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

            table.Columns.Add("LoginUsuario", typeof(string));



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

                    ajuste,

                    loginUsuario

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

            bulk.ColumnMappings.Add("LoginUsuario", "LoginUsuario");



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

    public async Task EjecutarSPObrasRankingClientesDesgloseAsync(string mercado, int anio, int mes, string loginUsuario)

    {

        using var conn = new SqlConnection(_connectionString);

        await conn.OpenAsync();

        using var transaction = await conn.BeginTransactionAsync();



        try

        {

            // 1. Limpiar tabla de trabajo de desglose

            await conn.ExecuteAsync(@"DELETE FROM rptContratacion_Clientes_Desglose 

                                      WHERE LoginUsuario = @LoginUsuario 

                                         OR FechaCreacion < DATEADD(hour, -1, GETDATE())", 

                                    new { LoginUsuario = loginUsuario }, transaction: transaction);



            // 2. Ejecutar SP de desglose (4 parámetros: Mercado, Año, Mes, LoginUsuario)

            var resultadosSp = (await conn.QueryAsync<RankingClientesDesgloseSpResult>( "EXEC spContratacion_Clientes_Desglose @Mercado, @Anio, @Mes, @LoginUsuario",

                                                                                            new { Mercado = mercado, Anio = anio, Mes = mes, LoginUsuario = loginUsuario },

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

            table.Columns.Add("LoginUsuario", typeof(string));



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

                    anterior,

                    loginUsuario

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

            bulk.ColumnMappings.Add("LoginUsuario", "LoginUsuario");



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

    public async Task<List<RankingContratacionClientesPoco>> ObtenerRankingContratacionClientesAsync(string mercado, int anio, int mes, decimal importe, string loginUsuario)

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

                                        AND LoginUsuario = @LoginUsuario

                                    ORDER BY Row ASC";



        using var conn = new SqlConnection(_connectionString);

        await conn.OpenAsync();



        return (await conn.QueryAsync<RankingContratacionClientesPoco>(

            sqlSelect,

            new { Importe = importe, LoginUsuario = loginUsuario },

            commandTimeout: 300

        )).ToList();

    }

    

    /// <summary>

    /// Obtiene el detalle de desglose de clientes desde la tabla de trabajo filtrando por mercado y año.

    /// </summary>

    public async Task<List<RankingContratacionClientesDesglosePoco>> ObtenerRankingContratacionClientesDesgloseAsync(string mercado, int anio, int mes, string loginUsuario)

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

                                AND D.LoginUsuario = @LoginUsuario

                            ORDER BY

                                D.ImporteContratadoAcumulado";



        using var conn = new SqlConnection(_connectionString);

        await conn.OpenAsync();



        return (await conn.QueryAsync<RankingContratacionClientesDesglosePoco>(

            sql, 

            new { Mercado = mercado, Año = anio, Mes = mes, LoginUsuario = loginUsuario }, 

            commandTimeout: 300

        )).ToList();

    }



    /// <summary>

    /// Obtiene la suma total de todo el mercado para el informe de Ranking de Clientes.

    /// </summary>

    public async Task<decimal> ObtenerSumaTotalMercadoClientesAsync(string mercado, int anio, string loginUsuario)

    {

        const string sqlSum = "SELECT ISNULL(Sum(ImporteContratadoAcumulado), 0) FROM rptContratacion_Clientes WHERE Mercado = @Mercado AND Año = @Anio AND LoginUsuario = @LoginUsuario";



        using var conn = new SqlConnection(_connectionString);

        await conn.OpenAsync();



        return await conn.ExecuteScalarAsync<decimal>(sqlSum, new { Mercado = mercado, Anio = anio, LoginUsuario = loginUsuario }, commandTimeout: 300);

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

        int anio, int mes, string mercado, string codSubDirGeneral, string loginUsuario)

    {

        int mesMenos1 = mes - 1;



        const string sqlSelect = @" DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

                                        ocdn.Orden_CodDDirNegocio AS Orden,

                                        s.NombreDirNegocio,

                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0) AS ImporteContratado

                                    FROM

                                        rptPrincipalesContratacion   rpc

                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro AND rpc.Año = s.Año

                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio

                                    WHERE

                                            rpc.Año            = @Anio

                                        AND rpc.Mes            IN (@Mes, @MesMenos1)

                                        AND rpc.Ocultar        = 0

                                        AND rpc.Pais           = @Mercado

                                        AND s.CodSubDirGeneral = @CodSubDirGeneral

                                        AND (

                                            @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                            OR (@vPuesto = 'SDG'  AND s.CodSubDirGeneral = @vCodEntidad)

                                            OR (@vPuesto = 'DN'   AND s.CodDDirNegocio = @vCodEntidad)

                                            OR (@vPuesto = 'AREA' AND s.CodSubDirNegocioArea = @vCodEntidad)

                                            OR (@vPuesto = 'DEL'  AND s.CodDelegacion = @vCodEntidad)

                                            OR (@vPuesto = 'CT'   AND s.CodCentro = @vCodEntidad)

                                        )

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

                                                                                CodSubDirGeneral = codSubDirGeneral,

                                                                                LoginUsuario     = loginUsuario

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

        int anio, int mes, string mercado, string codSubDirGeneral, decimal importe, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

                                        ocdn.Orden_CodDDirNegocio                   AS Orden,

                                        s.NombreDirNegocio,

                                        REPLACE(rpc.NombreCliente_OK,  '''', '')     AS NombreCliente_OK,

                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')  AS DescripcionOferta_OK,

                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0)    AS ImporteContratado

                                    FROM

                                        rptPrincipalesContratacion   rpc

                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro AND rpc.Año = s.Año

                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio

                                    WHERE

                                            rpc.Año            = @Anio

                                        AND rpc.Mes            = @Mes

                                        AND rpc.Ocultar        = 0

                                        AND rpc.Pais           = @Mercado

                                        AND s.CodSubDirGeneral = @CodSubDirGeneral

                                        AND rpc.NombreCliente_OK <> 'ZZ_CARTERA DIFERIDA'

                                        AND (

                                            @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                            OR (@vPuesto = 'SDG'  AND s.CodSubDirGeneral = @vCodEntidad)

                                            OR (@vPuesto = 'DN'   AND s.CodDDirNegocio = @vCodEntidad)

                                            OR (@vPuesto = 'AREA' AND s.CodSubDirNegocioArea = @vCodEntidad)

                                            OR (@vPuesto = 'DEL'  AND s.CodDelegacion = @vCodEntidad)

                                            OR (@vPuesto = 'CT'   AND s.CodCentro = @vCodEntidad)

                                        )

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

                Importe          = importe,

                LoginUsuario     = loginUsuario

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

        int anio, int mes, string mercado, string codSubDirGeneral, decimal importe, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

                                        ocdn.Orden_CodDDirNegocio                   AS Orden,

                                        s.NombreDirNegocio,

                                        REPLACE(rpc.NombreCliente_OK,  '''', '')     AS NombreCliente_OK,

                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')  AS DescripcionOferta_OK,

                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0)    AS ImporteContratado

                                    FROM

                                        rptPrincipalesContratacion   rpc

                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro AND rpc.Año = s.Año

                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio

                                    WHERE

                                            rpc.Año            = @Anio

                                        AND rpc.Mes            < @Mes

                                        AND rpc.Ocultar        = 0

                                        AND rpc.Pais           = @Mercado

                                        AND s.CodSubDirGeneral = @CodSubDirGeneral

                                        AND rpc.NombreCliente_OK <> 'ZZ_CARTERA DIFERIDA'

                                        AND (

                                            @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                            OR (@vPuesto = 'SDG'  AND s.CodSubDirGeneral = @vCodEntidad)

                                            OR (@vPuesto = 'DN'   AND s.CodDDirNegocio = @vCodEntidad)

                                            OR (@vPuesto = 'AREA' AND s.CodSubDirNegocioArea = @vCodEntidad)

                                            OR (@vPuesto = 'DEL'  AND s.CodDelegacion = @vCodEntidad)

                                            OR (@vPuesto = 'CT'   AND s.CodCentro = @vCodEntidad)

                                        )

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

                Importe          = importe,

                LoginUsuario     = loginUsuario

            },

            commandTimeout: 300

        )).ToList();

    }



    // ═══════════════════════════════════════════════════════════════════════════

    // INFORME: Contrataciones Significativas (COMITE)

    // ═══════════════════════════════════════════════════════════════════════════



    public async Task<List<ContratacionesSignificativasPoco>> ObtenerContratacionesSignificativasRiAsync(

        int anio, int mes, string mercado, string codSubDirGeneral, string loginUsuario)

    {

        const string sqlSelect = @" DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

                                        ocdn.Orden_CodDDirNegocio AS Orden,

                                        s.NombreDirNegocio,

                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0) AS ImporteContratado

                                    FROM

                                        rptPrincipalesContratacion   rpc

                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro AND rpc.Año = s.Año

                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio

                                    WHERE

                                            rpc.Año            = @Anio

                                        AND rpc.Mes            = @Mes

                                        AND rpc.Ocultar        = 0

                                        AND rpc.Pais           = @Mercado

                                        AND (

                                            @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                            OR (@vPuesto = 'SDG'  AND s.CodSubDirGeneral = @vCodEntidad)

                                            OR (@vPuesto = 'DN'   AND s.CodDDirNegocio = @vCodEntidad)

                                            OR (@vPuesto = 'AREA' AND s.CodSubDirNegocioArea = @vCodEntidad)

                                            OR (@vPuesto = 'DEL'  AND s.CodDelegacion = @vCodEntidad)

                                            OR (@vPuesto = 'CT'   AND s.CodCentro = @vCodEntidad)

                                        )

                                    GROUP BY

                                        s.OrdenSubDirGeneral,

                                        ocdn.Orden_CodDDirNegocio,

                                        s.NombreDirNegocio

                                    ORDER BY

                                        s.OrdenSubDirGeneral ASC,

                                        CASE WHEN @Mercado = 'Internacional' THEN s.NombreDirNegocio ELSE NULL END ASC,

                                        CASE WHEN @Mercado <> 'Internacional' THEN ocdn.Orden_CodDDirNegocio END ASC";



        using var conn = new SqlConnection(_connectionString);

        await conn.OpenAsync();



        return (await conn.QueryAsync<ContratacionesSignificativasPoco>(    sqlSelect,

                                                                            new {

                                                                                Anio             = anio,

                                                                                Mes              = mes,

                                                                                Mercado          = mercado,

                                                                                LoginUsuario     = loginUsuario

                                                                            },

                                                                            commandTimeout: 300

                                                                        )).ToList();

    }



    public async Task<List<ContratacionesSignificativasMesPoco>> ObtenerContratacionesSignificativasMesRiAsync(

        int anio, int mes, string mercado, string codSubDirGeneral, decimal importe, string loginUsuario)

    {

        const string sqlSelect = @"DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);

                                    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;



                                    SELECT

                                        ocdn.Orden_CodDDirNegocio                   AS Orden,

                                        s.NombreDirNegocio,

                                        REPLACE(rpc.NombreCliente_OK,  '''', '')     AS NombreCliente_OK,

                                        REPLACE(rpc.DescripcionOferta_OK, '''', '')  AS DescripcionOferta_OK,

                                        ISNULL(SUM(rpc.ImporteContratado_OK), 0)    AS ImporteContratado

                                    FROM

                                        rptPrincipalesContratacion   rpc

                                    INNER JOIN Sumarigrama           s    ON rpc.CodCentro    = s.CodCentro AND rpc.Año = s.Año

                                    INNER JOIN Orden_CodDDirNegocio  ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio

                                    WHERE

                                            rpc.Año            = @Anio

                                        AND rpc.Mes            = @Mes

                                        AND rpc.Ocultar        = 0

                                        AND rpc.Pais           = @Mercado

                                        AND rpc.NombreCliente_OK <> 'ZZ_CARTERA DIFERIDA'

                                        AND (

                                            @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL

                                            OR (@vPuesto = 'SDG'  AND s.CodSubDirGeneral = @vCodEntidad)

                                            OR (@vPuesto = 'DN'   AND s.CodDDirNegocio = @vCodEntidad)

                                            OR (@vPuesto = 'AREA' AND s.CodSubDirNegocioArea = @vCodEntidad)

                                            OR (@vPuesto = 'DEL'  AND s.CodDelegacion = @vCodEntidad)

                                            OR (@vPuesto = 'CT'   AND s.CodCentro = @vCodEntidad)

                                        )

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

                Importe          = importe,

                LoginUsuario     = loginUsuario

            },

            commandTimeout: 300

        )).ToList();

    }



    // ═══════════════════════════════════════════════════════════════════════════

    // INFORME: Gerencias

    // └─ Método: ObtenerGerenciasAsync(int anio, int mes)

    // ═══════════════════════════════════════════════════════════════════════════



    public async Task<List<GerenciasPoco>> ObtenerGerenciasAsync(int anio, int mes, string loginUsuario)

    {

        // PASO 1: Vaciar tabla de trabajo

        const string sqlDelete = @"DELETE FROM rptContratacion_GerenciaCentro 

                                   WHERE LoginUsuario = @LoginUsuario 

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";



        // PASO 2: Poblar desde el SP (columnas exactas que devuelve el SP)

        const string sqlInsertExec = @"INSERT INTO rptContratacion_GerenciaCentro (NombreGerente, CodCentro, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Año, LoginUsuario)

                                       EXEC spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS @Anio, @Mes, @LoginUsuario";



        // PASO 3: SELECT enriquecido con JOINs

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

                                    WHERE rpt.LoginUsuario = @LoginUsuario

                                    GROUP BY

                                        rpt.Año,

                                        cg.SumarizaGerentes,

                                        rpt.NombreGerente,

                                        cg.Orden";



        var parametros = new { 

            Anio = anio, 

            Mes = mes,

            LoginUsuario = loginUsuario

        };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);

            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction, commandTimeout: 300);

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

        int anio, int mes, string loginUsuario,

        string codSdgOrdenDel = "090")

    {

        const string sqlDelete = @"DELETE FROM rptContratacion_SG_Mercado 

                                   WHERE LoginUsuario = @LoginUsuario 

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";



        const string sqlExecSp = @"EXEC spContratacion_Mensual_Acumulada_AñoAnterior_SG_Mercado @Anio, @Mes, @LoginUsuario";



        const string sqlInsert = @"INSERT INTO rptContratacion_SG_Mercado

                                        (Pais, CodCentro, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Año, LoginUsuario)

                                        VALUES (@Pais, @CodCentro, @ImporteContratado, @ImporteContratadoAcumulado, @ImporteContratadoAcumuladoAñoAnterior, @Año, @LoginUsuario)";



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

                                            CASE WHEN S.CodSubDirGeneral = '221' THEN '' ELSE S.NombreSubDirNegocioArea END AS Area

                                        FROM dbo.Sumarigrama S WITH (NOLOCK)

                                        INNER JOIN dbo.Orden_CodDDirNegocio ONeg WITH (NOLOCK) ON S.CodDDirNegocio = ONeg.CodDDirNegocio

                                        WHERE S.Año = @Anio

                                    ),

                                    CTE_Contratacion_Del AS (

                                        SELECT S.CodDelegacion,

                                            SUM(C.ImporteContratado) AS ImporteContratado,

                                            SUM(CASE WHEN ISNULL(C.Pais, 'Nacional') = 'Nacional' THEN C.ImporteContratado ELSE 0 END) AS ImporteContratadoNacional,

                                            SUM(CASE WHEN C.Pais = 'Internacional' THEN C.ImporteContratado ELSE 0 END) AS ImporteContratadoInternacional,

                                            SUM(C.ImporteContratadoAcumulado) AS ImporteContratadoAcumulado,

                                            SUM(CASE WHEN ISNULL(C.Pais, 'Nacional') = 'Nacional' THEN C.ImporteContratadoAcumulado ELSE 0 END) AS ImporteContratadoAcumuladoNacional,

                                            SUM(CASE WHEN C.Pais = 'Internacional' THEN C.ImporteContratadoAcumulado ELSE 0 END) AS ImporteContratadoAcumuladoInternacional,

                                            SUM(C.ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnterior

                                        FROM dbo.rptContratacion_SG_Mercado C WITH (NOLOCK)

                                        INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON C.CodCentro = S.CodCentro AND C.Año = S.Año

                                        WHERE C.Año = @Anio AND C.LoginUsuario = @LoginUsuario

                                        GROUP BY S.CodDelegacion

                                    ),

                                    CTE_Objetivos_Del AS (

                                        SELECT 

                                            CodDelegacion,

                                            SUM(Importe) AS ImporteObjetivos,

                                            SUM(CASE WHEN Mercado LIKE 'N%' OR ISNULL(Mercado, 'N') = 'N' THEN Importe ELSE 0 END) AS ObjetivosNacional,

                                            SUM(CASE WHEN Mercado LIKE 'I%' THEN Importe ELSE 0 END) AS ObjetivosInternacional

                                        FROM dbo.ObjetivosDelegacionSQL WITH (NOLOCK)

                                        WHERE Año = @Anio

                                        GROUP BY CodDelegacion

                                    ),

                                    CTE_Cartera_Del AS (

                                        SELECT 

                                            S.CodDelegacion,

                                            SUM(ISNULL(Act.CarteraPdteAñoActual, 0)) AS CarteraPdteAñoActual,

                                            SUM(ISNULL(Ant.CarteraPdteAñoAnterior, 0)) AS CarteraPdteAñoAnterior

                                        FROM dbo.Sumarigrama S WITH (NOLOCK)

                                        LEFT JOIN dbo.fn_veCarteraPdteProducirSQL_AnioActual(@Anio, @Mes) Act ON S.CodCentro = Act.CodCentro AND S.Año = @Anio

                                        LEFT JOIN dbo.fn_veCarteraPdteProducirSQL_AnioAnterior(@Anio, @Mes) Ant ON S.CodCentro = Ant.CodCentro AND S.Año = @Anio

                                        WHERE S.Año = @Anio

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

            CodSdgOrdenDel = codSdgOrdenDel,

            LoginUsuario = loginUsuario

        };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);



            var spResult = await _connection.QueryAsync<SpContratacionMensualResult>(sqlExecSp, parametros, transaction: transaction, commandTimeout: 300);

            var insertList = spResult.Select(r => new

            {

                Pais = r.Pais,

                CodCentro = r.CodCentro,

                ImporteContratado = Convert.ToDecimal(r.ImporteContratado),

                ImporteContratadoAcumulado = Convert.ToDecimal(r.ImporteContratadoAcumulado),

                ImporteContratadoAcumuladoAñoAnterior = Convert.ToDecimal(r.ImporteContratadoAcumuladoAñoAnterior),

                Año = anio,

                LoginUsuario = loginUsuario

            }).ToList();



            if (insertList.Any())

                await _connection.ExecuteAsync(sqlInsert, insertList, transaction: transaction, commandTimeout: 300);



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

        int anio, int mes, int todoInternacional, decimal limiteImporte, int limitePaises, string informe, string loginUsuario)

    {

        const string sqlDelete = @"DELETE FROM rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises 

                                   WHERE (AnioInforme = @Anio AND MesInforme = @Mes AND LoginUsuario = @LoginUsuario)

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";

        

        const string sqlExec = "EXEC spCarteraContratacionDetalle_DGDesarrolloInternacional_DosAños @Anio, @Mes, @TodoInternacional, @LimiteImporte, @LimitePaises, @Informe, @LoginUsuario";



        const string sqlInsert = @"INSERT INTO rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises

                                            (AnioInforme, MesInforme, Pais, NomCliente, DesOferta, ImporteCarteraOferta, ImporteContratadoOferta, ImporteCarteraPais, LoginUsuario)

                                       VALUES

                                            (@AnioInforme, @MesInforme, @Pais, @NomCliente, @DesOferta, @ImporteCarteraOferta, @ImporteContratadoOferta, @ImporteCarteraPais, @LoginUsuario)";

        

        const string sqlSelect = @"SELECT AnioInforme, MesInforme, Pais, DesOferta, NomCliente, ImporteCarteraOferta, ImporteContratadoOferta, ImporteCarteraPais

                                   FROM rptCarteraContratacionDetalle_DGDesarrolloInternacional_Paises WITH (NOLOCK)

                                   WHERE AnioInforme = @Anio 

                                     AND MesInforme = @Mes 

                                     AND LoginUsuario = @LoginUsuario

                                     AND (ISNULL(ImporteCarteraOferta, 0) + ISNULL(ImporteContratadoOferta, 0)) <> 0";



        var parametros = new { 

            Anio = anio, Mes = mes, TodoInternacional = todoInternacional, 

            LimiteImporte = limiteImporte, LimitePaises = limitePaises, Informe = informe,

            LoginUsuario = loginUsuario

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

                    d.ImporteCarteraPais,

                    LoginUsuario = loginUsuario

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



    // Informe: Cartera Contratación Detalle Organización Países

    public async Task<List<CarteraContratacionDetalleOrgPaisesPoco>> ObtenerCarteraContratacionDetalleOrgPaisesAsync(

        int anio, int mes, int todoInternacional, decimal limiteImporte, int limitePaises, string informe, string loginUsuario)

    {

        const string sqlExec = "EXEC spCarteraContratacionDetalle_DGDesarrolloInternacional_DosAños @Anio, @Mes, @TodoInternacional, @LimiteImporte, @LimitePaises, @Informe, @LoginUsuario";



        var parametros = new { Anio = anio, Mes = mes, TodoInternacional = todoInternacional, 

                               LimiteImporte = limiteImporte, LimitePaises = limitePaises, Informe = informe, LoginUsuario = loginUsuario};



        var datos = (await _connection.QueryAsync<CarteraContratacionDetalleOrgPaisesPoco>(sqlExec, parametros, commandTimeout: 600)).ToList();



        // Transformación: ImporteContratadoOferta / 1000 (VBA Parity)

        foreach (var fila in datos)

        {

            fila.ImporteContratadoOferta = (fila.ImporteContratadoOferta ?? 0) / 1000m;

        }



        // Filtrar registros vacíos

        return datos.Where(d => (d.ImporteCarteraOferta ?? 0) + (d.ImporteContratadoOferta ?? 0) != 0).ToList();

    }



    // Informe: Cartera Contratación Detalle Países

    public async Task<List<CarteraContratacionDetallePaisesPoco>> ObtenerCarteraContratacionDetallePaisesAsync(

        int anio, int mes, int todoInternacional, decimal limiteImporte, int limitePaises, string informe, string loginUsuario)

    {

        const string sqlExec = "EXEC spCarteraContratacionDetalle_DGDesarrolloInternacional_DosAños @Anio, @Mes, @TodoInternacional, @LimiteImporte, @LimitePaises, @Informe, @LoginUsuario";



        var parametros = new

        {

            Anio = anio,

            Mes = mes,

            TodoInternacional = todoInternacional,

            LimiteImporte = limiteImporte,

            LimitePaises = limitePaises,

            Informe = informe,

            LoginUsuario = loginUsuario

        };



        var datos = (await _connection.QueryAsync<CarteraContratacionDetallePaisesPoco>(sqlExec, parametros, commandTimeout: 600)).ToList();



        // Transformación: ImporteContratadoOferta / 1000 (paridad VBA)

        foreach (var fila in datos)

        {

            fila.ImporteContratadoOferta = (fila.ImporteContratadoOferta ?? 0) / 1000m;

        }



        // Filtro post-query: excluir ofertas cuya suma cartera + contratado sea cero

        // (paridad exacta con HAVING del subinforme Access)

        //return datos.Where(d => (d.ImporteCarteraOferta ?? 0) + (d.ImporteContratadoOferta ?? 0) != 0).ToList();

        return datos.ToList();

    }



    // Target: replace_file_content target

    // Informe: Cartera Contratación (Resumen SDG)

    public async Task<List<CarteraContratacionResumenSDGPoco>> ObtenerCarteraContratacionResumenSDGAsync(int anio, int mes, int todoInt, string loginUsuario)

    {

        const string sqlExec = "EXEC spCartera_Contratacion_Resumen_SDG @Anio, @Mes, @TodoInt, @LoginUsuario";



        using var conn = new SqlConnection(_connectionString);

        await conn.OpenAsync();



        var parametros = new { Anio = anio, Mes = mes, TodoInt = todoInt, LoginUsuario = loginUsuario };



        return (await conn.QueryAsync<CarteraContratacionResumenSDGPoco>( sqlExec, parametros, commandTimeout: 300)).ToList();

    }



    // ═══════════════════════════════════════════════════════════════════════════

    // INFORME: Detalle Actividades Internacional

    // ═══════════════════════════════════════════════════════════════════════════



    public async Task<List<ActividadesInternacionalDetallePoco>> ObtenerActividadesInternacionalDetalleAsync(int anio, int mes, string loginUsuario)

    {

        const string sqlDelete = @"DELETE FROM rptContratacion_Actividad_SubActividad 

                                   WHERE LoginUsuario = @LoginUsuario 

                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";



        const string sqlExec = "EXEC spContratacion_Actividades_SubActividades @Anio, @Mes, @LoginUsuario";



        const string sqlInsertManual = @"INSERT INTO rptContratacion_Actividad_SubActividad

                                                (Año, Orden, CodActividad, Actividad, CodAct1, CodAct2, Pais,

                                                 ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, Desglose_AñoAnterior, LoginUsuario)

                                         VALUES

                                                (@Año, @Orden, @CodActividad, @Actividad, @CodAct1, @CodAct2, @Pais,

                                                 @ImporteContratadoAcumulado, @ImporteContratadoAcumuladoAñoAnterior, @Desglose_AñoAnterior, @LoginUsuario)";



        const string sqlSelect = @";WITH CTE_FiltroSumarigrama AS (

                                        SELECT DISTINCT s.CodCentro

                                        FROM dbo.Sumarigrama s WITH (NOLOCK)

                                        OUTER APPLY (

                                            SELECT TOP 1 u.Puesto, u.CodEntidad

                                            FROM dbo.WEB_Usuarios u WITH (NOLOCK)

                                            WHERE u.Usuario = @LoginUsuario

                                        ) u

                                        WHERE s.Año = @Anio

                                          AND (@LoginUsuario IS NULL OR

                                               u.Puesto IS NULL OR

                                               u.Puesto = 'DG' OR

                                               (u.Puesto = 'SDG'  AND s.CodSubDirGeneral = u.CodEntidad) OR

                                               (u.Puesto = 'DN'   AND s.CodDDirNegocio = u.CodEntidad) OR

                                               (u.Puesto = 'AREA' AND s.CodSubDirNegocioArea = u.CodEntidad) OR

                                               (u.Puesto = 'DEL'  AND s.CodDelegacion = u.CodEntidad) OR

                                               (u.Puesto = 'CT'   AND s.CodCentro = u.CodEntidad))

                                    ),

                                    CTE_ActividadesCDAC AS (

                                        SELECT Agrupacion, dbo.fnCDAC(CDAC1, CDAC2) AS CDAC

                                        FROM dbo.ActividadesSQL WITH (NOLOCK)

                                        GROUP BY Agrupacion, dbo.fnCDAC(CDAC1, CDAC2)

                                    ),

                                    CTE_ObjetivosInt AS (

                                        SELECT ac.Agrupacion, @Anio AS Año, SUM(oa.Importe) AS Importe

                                        FROM dbo.ObjetivosActividadSQL oa WITH (NOLOCK)

                                        INNER JOIN CTE_FiltroSumarigrama f ON oa.CodCentro = f.CodCentro

                                        INNER JOIN CTE_ActividadesCDAC ac ON dbo.fnCDAC(oa.CDAC1, oa.CDAC2) = ac.CDAC

                                        WHERE oa.Año = @Anio AND oa.Mercado = 'I'

                                        GROUP BY ac.Agrupacion

                                    ),

                                    Resumen AS (

                                        SELECT

                                            r.Año, r.Pais, r.Actividad AS ActividadPrincipal,

                                            CAST(NULL AS NVARCHAR(255)) AS ActividadDetalle,

                                            SUM(r.ImporteContratadoAcumulado) AS ImporteContratadoAcumulado,

                                            SUM(r.ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnterior,

                                            r.Orden,

                                            ISNULL(MAX(obj.Importe), 0) AS ImporteObjetivos,

                                            0 AS EsSubActividad

                                        FROM dbo.rptContratacion_Actividad_SubActividad r

                                        LEFT JOIN CTE_ObjetivosInt obj

                                            ON r.Actividad = obj.Agrupacion AND r.Año = obj.Año

                                        WHERE r.Desglose_AñoAnterior = 0

                                          AND r.Pais = 'internacional'

                                          AND r.Año = @Anio

                                          AND r.LoginUsuario = @LoginUsuario

                                        GROUP BY r.Año, r.Pais, r.Actividad, r.Orden



                                        UNION ALL



                                        SELECT

                                            r.Año, r.Pais, s.Descrip_Activ_Espec AS ActividadPrincipal,

                                            s.Descrip_Activ_Espec_Desglose AS ActividadDetalle,

                                            SUM(r.ImporteContratadoAcumulado) AS ImporteContratadoAcumulado,

                                            SUM(r.ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnterior,

                                            s.Ord_Descrip_Activ_Espec_Desglose AS Orden,

                                            0 AS ImporteObjetivos,

                                            1 AS EsSubActividad

                                        FROM dbo.rptContratacion_Actividad_SubActividad r

                                        INNER JOIN dbo.SubActividadesSQL s

                                            ON r.Actividad = s.Descrip_Activ_Espec AND r.CodAct2 = s.CDAC2

                                        WHERE r.Pais = 'internacional'

                                          AND r.Año = @Anio

                                          AND r.LoginUsuario = @LoginUsuario

                                          AND s.Descrip_Activ_Espec_Desglose <> ''

                                        GROUP BY r.Año, r.Pais, s.Descrip_Activ_Espec, 

                                                 s.Descrip_Activ_Espec_Desglose, s.Ord_Descrip_Activ_Espec_Desglose

                                    )

                                    SELECT * FROM Resumen";



        var parametros = new { Anio = anio, Mes = mes, LoginUsuario = loginUsuario };



        if (_connection.State != ConnectionState.Open)

            _connection.Open();



        using var transaction = _connection.BeginTransaction();

        try

        {

            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);

            var datosSp = (await _connection.QueryAsync<dynamic>(sqlExec, parametros, transaction: transaction)).ToList();



            foreach (var fila in datosSp)

            {

                await _connection.ExecuteAsync(sqlInsertManual, new {

                    Año = anio,

                    Orden = (int?)fila.Orden,

                    CodActividad = (string?)fila.CodActividad,

                    Actividad = (string?)fila.Actividad,

                    CodAct1 = (string?)fila.CodAct1,

                    CodAct2 = (string?)fila.CodAct2,

                    Pais = (string?)fila.Pais,

                    ImporteContratadoAcumulado = (decimal?)fila.ImporteContratadoAcumulado,

                    ImporteContratadoAcumuladoAñoAnterior = (decimal?)fila.ImporteContratadoAcumuladoAñoAnterior,

                    Desglose_AñoAnterior = (int?)fila.Desglose_AñoAnterior,

                    LoginUsuario = loginUsuario

                }, transaction: transaction);

            }



            var resultado = (await _connection.QueryAsync<ActividadesInternacionalDetallePoco>(sqlSelect, parametros, transaction)).ToList();

            transaction.Commit();

            return resultado;

        }

        catch

        {

            transaction.Rollback();

            throw;

        }

    }



    private class SpContratacionMensualResult

    {

        public string Pais { get; set; } = "";

        public string CodCentro { get; set; } = "";

        public double ImporteContratado { get; set; }

        public double ImporteContratadoAcumulado { get; set; }

        public double ImporteContratadoAcumuladoAñoAnterior { get; set; }

    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPCIONES DE GENERACIÓN — Sincronización de datos (spSincronizar_*)
    // ═══════════════════════════════════════════════════════════════════════════

    public async Task EjecutarSPSincronizarOfertasAsync(int anio, int mes)
    {
        const string sqlExec = @"EXEC spSincronizar_OfertasSQL @pAño, @pMes";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        await conn.ExecuteAsync(sqlExec, new { pAño = anio, pMes = mes }, commandTimeout: 300);
    }

    public async Task EjecutarSPSincronizarClientesAsync()
    {
        const string sqlExec = @"EXEC spSincronizar_ClientesSQL";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        await conn.ExecuteAsync(sqlExec, commandTimeout: 300);
    }

    public async Task EjecutarSPSincronizarSumarigramaAsync()
    {
        const string sqlExec = @"EXEC spSincronizar_Sumarigrama";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        await conn.ExecuteAsync(sqlExec, commandTimeout: 300);
    }

    public async Task EjecutarSPSincronizarObrasAsync(int anio, int mes)
    {
        const string sqlExec = @"EXEC spSincronizar_ObrasActualesSQL @pAño, @pMes";

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        await conn.ExecuteAsync(sqlExec, new { pAño = anio, pMes = mes }, commandTimeout: 300);
    }


    // ====================================================================
    // INFORME: Contratacion Mercados SDG Agrupado DN (Elecnor Servicios 221)
    // ====================================================================

    public async Task<List<ContratacionSDGDNPoco>> ObtenerContratacionSDGDNAsync(
        int anio, int mes, string loginUsuario, string? subdireccion)
    {
        // Patron atomico Elecnor: DELETE (RLS + TTL) -> INSERT EXEC -> SELECT.
        // La SP inyecta LoginUsuario/Año en su SELECT final, garantizando
        // aislamiento por sesion y consistencia transaccional.
        const string sqlDelete = @"DELETE FROM rptContratacion_DG_SDG_DN_SDNA_Deleg
                                   WHERE LoginUsuario = @LoginUsuario
                                      OR FechaCreacion < DATEADD(hour, -1, GETDATE())";

        const string sqlInsertExec = @"INSERT INTO rptContratacion_DG_SDG_DN_SDNA_Deleg
                                        (Año, CodSubDirGeneral, NombreSubDirGeneral, CodDDirNegocio, NombreDirNegocio,
                                         CodSubDirNegocioArea, NombreSubDirNegocioArea, CodDelegacion, NombreDelegacion,
                                         Pais, ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior, LoginUsuario)
                                        EXEC spContratacion_DG_SDG_DN_SDNA_Deleg_Ajuste @Anio, @Mes, @LoginUsuario";

        const string sqlSelect = @"
            DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);
            SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = @LoginUsuario;

            DECLARE @vSubDirFinal nvarchar(20);
            IF @vPuesto = 'SDG'
            BEGIN
                SET @vSubDirFinal = @vCodEntidad;
            END
            ELSE
            BEGIN
                SET @vSubDirFinal = NULLIF(@Subdireccion, '');
            END;

            WITH Contratacion AS (
                SELECT
                    CASE WHEN @vSubDirFinal IS NULL THEN '' ELSE rpt.CodSubDirGeneral END AS CodSubDirGeneral,
                    rpt.Año,
                    rpt.NombreDirNegocio,
                    rpt.Pais,
                    SUM(rpt.ImporteContratado) AS ImporteContratado,
                    SUM(rpt.ImporteContratadoAcumulado) AS ImporteContratadoAcumulado,
                    SUM(rpt.ImporteContratadoAcumuladoAñoAnterior) AS ImporteContratadoAcumuladoAñoAnterior
                FROM dbo.rptContratacion_DG_SDG_DN_SDNA_Deleg rpt WITH (NOLOCK)
                WHERE rpt.Año = @Anio
                  AND rpt.LoginUsuario = @LoginUsuario
                  AND (
                      @vSubDirFinal IS NULL 
                      OR rpt.CodSubDirGeneral = @vSubDirFinal
                  )
                  AND rpt.Pais <> ''
                GROUP BY CASE WHEN @vSubDirFinal IS NULL THEN '' ELSE rpt.CodSubDirGeneral END, rpt.Año, rpt.NombreDirNegocio, rpt.Pais
            ),
            ObjetivosArea AS (
                SELECT
                    s.Año,
                    CASE WHEN @vSubDirFinal IS NULL THEN '' ELSE s.CodSubDirGeneral END AS CodSubDirGeneral,
                    CASE WHEN @vSubDirFinal IS NULL THEN 'Dirección General (Consolidado)' ELSE MAX(s.NombreSubDirGeneral) END AS NombreSubDirGeneral,
                    s.CodDDirNegocio,
                    s.NombreDirNegocio,
                    m.Mercado AS Pais,
                    SUM(ISNULL(oa.Importe, 0)) AS Objetivo
                FROM (
                    SELECT DISTINCT
                        Año,
                        CodSubDirGeneral,
                        NombreSubDirGeneral,
                        CodDDirNegocio,
                        NombreDirNegocio,
                        CodDelegacion,
                        CodCentro
                    FROM dbo.Sumarigrama WITH (NOLOCK)
                    WHERE Año = @Anio
                      AND (
                          @vSubDirFinal IS NULL 
                          OR CodSubDirGeneral = @vSubDirFinal
                      )
                      AND (
                          @vPuesto = 'DG' OR @vPuesto IS NULL OR @LoginUsuario IS NULL
                          OR (@vPuesto = 'SDG' AND CodSubDirGeneral = @vCodEntidad)
                          OR (@vPuesto = 'DN'   AND CodDDirNegocio = @vCodEntidad)
                          OR (@vPuesto = 'AREA' AND CodSubDirNegocioArea = @vCodEntidad)
                          OR (@vPuesto = 'DEL'  AND CodDelegacion = @vCodEntidad)
                          OR (@vPuesto = 'CT'   AND CodCentro = @vCodEntidad)
                      )
                ) s
                CROSS JOIN (SELECT 'Nacional' AS Mercado UNION SELECT 'Internacional') m
                LEFT JOIN dbo.ObjetivosActividadSQL oa WITH (NOLOCK)
                    ON s.CodCentro = oa.CodCentro
                    AND s.Año = oa.Año
                    AND m.Mercado = (CASE WHEN oa.Mercado = 'I' THEN 'Internacional' ELSE 'Nacional' END)
                GROUP BY s.Año, CASE WHEN @vSubDirFinal IS NULL THEN '' ELSE s.CodSubDirGeneral END, s.CodDDirNegocio, s.NombreDirNegocio, m.Mercado
            ),
            OrdenDN AS (
                SELECT CodDDirNegocio, Orden_CodDDirNegocio
                FROM dbo.Orden_CodDDirNegocio WITH (NOLOCK)
            )
            SELECT
                oa.CodSubDirGeneral,
                oa.NombreSubDirGeneral,
                oa.CodDDirNegocio,
                oa.NombreDirNegocio,
                oa.Pais,
                ISNULL(c.ImporteContratado, 0) AS ImporteContratado,
                ISNULL(c.ImporteContratadoAcumulado, 0) AS ImporteContratadoAcumulado,
                ISNULL(c.ImporteContratadoAcumuladoAñoAnterior, 0) AS ImporteContratadoAcumuladoAnterior,
                oa.Objetivo,
                ISNULL(ord.Orden_CodDDirNegocio, 99) AS Orden_CodDDirNegocio
            FROM ObjetivosArea oa
            LEFT JOIN Contratacion c
                ON oa.NombreDirNegocio = c.NombreDirNegocio
                AND oa.Pais = c.Pais
                AND oa.CodSubDirGeneral = c.CodSubDirGeneral
            LEFT JOIN OrdenDN ord
                ON oa.CodDDirNegocio = ord.CodDDirNegocio;";

        var parametros = new { Anio = anio, Mes = mes, LoginUsuario = loginUsuario, Subdireccion = subdireccion };

        if (_connection.State != ConnectionState.Open)
            _connection.Open();

        using var transaction = _connection.BeginTransaction();
        try
        {
            // 1) DELETE: limpia la sesion y TTL.
            await _connection.ExecuteAsync(sqlDelete, new { LoginUsuario = loginUsuario }, transaction: transaction);

            // 2) INSERT EXEC atomico: la SP aplica RLS sobre #Sumarigrama y rellena la
            //    tabla de trabajo en un unico round-trip.
            await _connection.ExecuteAsync(sqlInsertExec, parametros, transaction: transaction, commandTimeout: 300);

            // 3) SELECT tipado filtrado por LoginUsuario.
            var resultado = (await _connection.QueryAsync<ContratacionSDGDNPoco>(
                sqlSelect, parametros, transaction)).ToList();

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
