using System.Data;
using Dapper;
using Elecnor_Informes_Comerciales.Models.Informes.Gerencias_Totales_Cruces;

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

    /// <summary>
    /// Obtiene los datos planos para el informe Gerencias Totales Cruces.
    /// </summary>
    public async Task<List<GerenciasTotalesCrucesPoco>> ObtenerGerenciasTotalesCrucesAsync(int anio, int mes)
    {
        //PASO 1: Vaciar la tabla de trabajo.
        const string sqlDelete = "DELETE FROM rptContratacion_GerenciaCentro";

        //PASO 2: Poblar desde el SP (columnas que devuelve el SP, sin Año).
        const string sqlInsertExec = @"INSERT INTO rptContratacion_GerenciaCentro (NombreGerente, CodCentro,ImporteContratado, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoAnterior)
                                       EXEC spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS @Anio, @Mes";

        //PASO 3: Asignar el año a todas las filas recién insertadas.
        const string sqlUpdateAnio = "UPDATE rptContratacion_GerenciaCentro SET Año = @Anio";

        //PASO 4: SELECT de datos enriquecidos.
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
}
