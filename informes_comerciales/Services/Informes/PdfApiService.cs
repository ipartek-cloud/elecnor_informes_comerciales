using System.Reflection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Elecnor_Informes_Comerciales.Services;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio orquestador para la generación y compilación de informes PDF a nivel de servidor.
/// </summary>
public class PdfApiService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly HtmlAssemblerService _htmlAssemblerService;
    private readonly IPdfGeneratorService _pdfGeneratorService;
    private readonly ILogger<PdfApiService> _logger;

    public PdfApiService(
        IServiceProvider serviceProvider,
        HtmlAssemblerService htmlAssemblerService,
        IPdfGeneratorService pdfGeneratorService,
        ILogger<PdfApiService> logger)
    {
        _serviceProvider = serviceProvider;
        _htmlAssemblerService = htmlAssemblerService;
        _pdfGeneratorService = pdfGeneratorService;
        _logger = logger;
    }

    /// <summary>
    /// Genera los bytes del PDF de un informe específico de manera directa.
    /// </summary>
    public async Task<byte[]?> GenerarPdfAsync(
        string tipoInforme,
        int anio,
        int mes,
        Dictionary<string, string>? filtros,
        string loginUsuario)
    {
        _logger.LogInformation("[PdfApiService] Solicitud para generar PDF: Tipo={Tipo}, Año={Anio}, Mes={Mes}, Usuario={Usuario}", tipoInforme, anio, mes, loginUsuario);

        using var scope = _serviceProvider.CreateScope();

        // 1. Obtener los datos del mes reutilizando la lógica de reflection de InformePortableService
        var portableService = scope.ServiceProvider.GetRequiredService<InformePortableService>();
        
        // El método ObtenerDatosMesAsync es privado. Lo invocamos vía reflection para máxima reutilización.
        var methodObtener = typeof(InformePortableService).GetMethod("ObtenerDatosMesAsync",
            BindingFlags.NonPublic | BindingFlags.Instance);

        if (methodObtener == null)
        {
            _logger.LogError("[PdfApiService] Método ObtenerDatosMesAsync no encontrado en InformePortableService.");
            return null;
        }

        // Normalizar filtros a Case-Insensitive para asegurar resolución por reflection.
        var filtrosNormalizados = filtros != null
            ? new Dictionary<string, string>(filtros, StringComparer.OrdinalIgnoreCase)
            : new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        object? datosMes;
        try
        {
            var task = (Task<object?>)methodObtener.Invoke(portableService,
                new object?[] { scope, tipoInforme, anio, mes, filtrosNormalizados, loginUsuario })!;
            
            datosMes = await task;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[PdfApiService] Error al obtener datos para el informe {Tipo} por reflection.", tipoInforme);
            return null;
        }

        if (datosMes == null)
        {
            _logger.LogWarning("[PdfApiService] No se devolvieron datos para el informe {Tipo} en {Anio}-{Mes}.", tipoInforme, anio, mes);
            return null;
        }

        // 2. Ensamblar el HTML específico optimizado para impresión PDF
        string htmlContent;
        try
        {
            htmlContent = await _htmlAssemblerService.AssembleHtmlForPdfAsync(tipoInforme, anio, mes, datosMes, filtrosNormalizados);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[PdfApiService] Error al ensamblar HTML para el informe {Tipo}.", tipoInforme);
            return null;
        }

        if (string.IsNullOrWhiteSpace(htmlContent))
        {
            _logger.LogError("[PdfApiService] El HTML compilado está vacío para {Tipo}.", tipoInforme);
            return null;
        }

        // 3. Renderizar a PDF con Puppeteer y estampar números con PDFsharp
        // El número de página se obtiene de los filtros y se pasa a PdfGeneratorService
        // para el post-proceso de PDFsharp. El JS de AssembleHtmlForPdfAsync ya NO
        // pinta el span .rpt-page-number, así se evita la duplicación visual.
        int? nroPagina = null;
        if (filtros != null && filtros.TryGetValue("nroPagina", out var npStr) && int.TryParse(npStr, out var np))
        {
            nroPagina = np;
        }

        try
        {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(60));
            var pdfBytes = await _pdfGeneratorService.GeneratePdfFromHtmlAsync(htmlContent, nroPagina, tipoInforme, cts.Token);
            return pdfBytes;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[PdfApiService] Error en el renderizado de Puppeteer/PDFsharp para {Tipo}.", tipoInforme);
            return null;
        }
    }
}
