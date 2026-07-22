using Elecnor_Informes_Comerciales.DTOs.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio orquestador para la API REST de datos JSON de informes.
/// Obtiene los DTOs crudos reutilizando la resolución dinámica de <see cref="InformePortableService"/>,
/// sin ensamblar HTML ni renderizar PDF. Mantiene la paridad total de datos con el frontend web.
/// </summary>
public class JsonRptService
{
    private readonly InformePortableService _informePortableService;
    private readonly ILogger<JsonRptService> _logger;

    public JsonRptService(InformePortableService informePortableService, ILogger<JsonRptService> logger)
    {
        _informePortableService = informePortableService;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene el sobre JSON de un informe para un único mes.
    /// Retorna null si el tipo no está soportado o no hay datos.
    /// </summary>
    public async Task<JsonRptResponseDto?> GenerarJsonAsync(
        string tipoInforme,
        int anio,
        int mes,
        Dictionary<string, string>? filtros,
        string loginUsuario)
    {
        var filtrosNormalizados = NormalizarFiltros(filtros);

        _logger.LogInformation(
            "[JsonRptService] Solicitud de datos JSON: Tipo={Tipo}, Año={Anio}, Mes={Mes}, Usuario={Usuario}, Filtros={@Filtros}",
            tipoInforme, anio, mes, loginUsuario, filtrosNormalizados);

        var datos = await _informePortableService.ObtenerDatosInformeMesAsync(
            tipoInforme, anio, mes, filtrosNormalizados, loginUsuario);

        if (datos == null)
        {
            _logger.LogWarning("[JsonRptService] Sin datos para {Tipo} en {Anio}-{Mes}.", tipoInforme, anio, mes);
            return null;
        }

        return new JsonRptResponseDto
        {
            TipoInforme = tipoInforme,
            Anio = anio,
            Mes = mes,
            GeneradoEn = DateTime.Now,
            Usuario = loginUsuario,
            Datos = datos
        };
    }

    /// <summary>
    /// Obtiene el sobre JSON multi-mes de un informe. Bucle secuencial resiliente:
    /// un mes que falle o no tenga datos no interrumpe el resto (se reporta en MesesSinDatos).
    /// Retorna null si el tipo no está soportado o ningún mes devolvió datos.
    /// </summary>
    public async Task<JsonRptMultiMesResponseDto?> GenerarJsonMultiMesAsync(
        string tipoInforme,
        int anio,
        List<int> mesesSeleccionados,
        Dictionary<string, string>? filtros,
        string loginUsuario)
    {
        var filtrosNormalizados = NormalizarFiltros(filtros);

        _logger.LogInformation(
            "[JsonRptService] Solicitud de datos JSON multi-mes: Tipo={Tipo}, Año={Anio}, Meses={Meses}, Usuario={Usuario}, Filtros={@Filtros}",
            tipoInforme, anio, string.Join(",", mesesSeleccionados), loginUsuario, filtrosNormalizados);

        var datosPorMes = new Dictionary<int, object>();
        var mesesSinDatos = new List<int>();

        foreach (var mes in mesesSeleccionados)
        {
            try
            {
                var datosMes = await _informePortableService.ObtenerDatosInformeMesAsync(
                    tipoInforme, anio, mes, filtrosNormalizados, loginUsuario);

                if (datosMes != null)
                {
                    datosPorMes[mes] = datosMes;
                }
                else
                {
                    mesesSinDatos.Add(mes);
                    _logger.LogWarning("[JsonRptService] Mes {Mes}: Sin datos.", mes);
                }
            }
            catch (Exception ex)
            {
                mesesSinDatos.Add(mes);
                _logger.LogError(ex, "[JsonRptService] Error al obtener datos para mes {Mes}. Continuando con el resto.", mes);
            }
        }

        if (datosPorMes.Count == 0)
        {
            _logger.LogWarning("[JsonRptService] No se obtuvo ningún dato para ningún mes solicitado de {Tipo}.", tipoInforme);
            return null;
        }

        return new JsonRptMultiMesResponseDto
        {
            TipoInforme = tipoInforme,
            Anio = anio,
            MesesSolicitados = mesesSeleccionados,
            GeneradoEn = DateTime.Now,
            Usuario = loginUsuario,
            DatosPorMes = datosPorMes,
            MesesSinDatos = mesesSinDatos
        };
    }

    /// <summary>
    /// Normaliza los filtros a un diccionario case-insensitive (paridad con InformePortable/PdfRpt/HtmlRpt).
    /// </summary>
    private static Dictionary<string, string> NormalizarFiltros(Dictionary<string, string>? filtros)
    {
        var normalizados = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (filtros != null)
        {
            foreach (var kvp in filtros)
            {
                normalizados[kvp.Key] = kvp.Value;
            }
        }
        return normalizados;
    }
}
