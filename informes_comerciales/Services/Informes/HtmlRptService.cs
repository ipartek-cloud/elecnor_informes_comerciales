using Microsoft.Extensions.Logging;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class HtmlRptService
{
    private readonly InformePortableService _informePortableService;
    private readonly ILogger<HtmlRptService> _logger;

    public HtmlRptService(InformePortableService informePortableService, ILogger<HtmlRptService> logger)
    {
        _informePortableService = informePortableService;
        _logger = logger;
    }

    public async Task<string?> GenerarHtmlAsync(
        string tipoInforme,
        int anio,
        int mes,
        List<int> mesesSeleccionados,
        Dictionary<string, string>? filtros,
        string loginUsuario)
    {
        var filtrosNormalizados = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (filtros != null)
        {
            foreach (var kvp in filtros)
                filtrosNormalizados[kvp.Key] = kvp.Value;
        }

        try
        {
            var htmlContent = await _informePortableService.GenerarInformePortableAsync(
                tipoInforme, anio, mes, mesesSeleccionados, filtrosNormalizados, loginUsuario);

            return htmlContent;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[HtmlRptService] Error al generar HTML Portable para {Tipo}.", tipoInforme);
            return null;
        }
    }
}
