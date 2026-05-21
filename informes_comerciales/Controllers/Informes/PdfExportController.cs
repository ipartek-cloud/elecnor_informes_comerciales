using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services;
using Elecnor_Informes_Comerciales.DTOs;
using System.Text;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// Controlador para exportar informes HTML a formato PDF utilizando Puppeteer.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class PdfExportController : ControllerBase
{
    private readonly IPdfGeneratorService _pdfGeneratorService;
    private readonly AssetInliningService _assetInliningService;
    private readonly IWebHostEnvironment _env;
    private readonly ILogger<PdfExportController> _logger;

    public PdfExportController(
        IPdfGeneratorService pdfGeneratorService,
        AssetInliningService assetInliningService,
        IWebHostEnvironment env,
        ILogger<PdfExportController> logger)
    {
        _pdfGeneratorService = pdfGeneratorService;
        _assetInliningService = assetInliningService;
        _env = env;
        _logger = logger;
    }

    /// <summary>
    /// Recibe el HTML de un informe y devuelve el archivo PDF generado.
    /// </summary>
    [HttpPost("download")]
    public async Task<IActionResult> DownloadPdf([FromBody] PdfExportRequest request)
    {
        _logger.LogInformation("[PdfExportController] Petición de PDF recibida: {FileName}, ReportName={ReportName}", request.FileName, request.ReportName);

        if (string.IsNullOrWhiteSpace(request.HtmlContent))
        {
            return BadRequest("El contenido HTML es obligatorio.");
        }

        if (request.HtmlContent.Length > 5_000_000)
        {
            return BadRequest("El contenido HTML excede el tamaño máximo permitido (5 MB).");
        }

        try
        {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(60));

            // 1. Obtener estilos CSS locales
            var siteCss = await _assetInliningService.GetAssetContentAsync("css/site.css", cts.Token);
            var baseCss = await _assetInliningService.GetAssetContentAsync("css/informes/informes_base.css", cts.Token);
            var reportCss = string.Empty;

            if (!string.IsNullOrWhiteSpace(request.ReportName))
            {
                reportCss = await _assetInliningService.GetAssetContentAsync($"css/informes/{request.ReportName}.css", cts.Token);
            }

            // 2. Cargar el logotipo local en Base64 para evitar problemas de resolución de recursos en Puppeteer
            var logoBase64 = await GetLogoBase64Async();
            var processedHtml = request.HtmlContent.Replace("/images/logoElecnor.png", logoBase64);

            // 3. Ensamblar la página HTML completa
            var htmlBuilder = new StringBuilder();
            htmlBuilder.AppendLine("<!DOCTYPE html>");
            htmlBuilder.AppendLine("<html lang=\"es\">");
            htmlBuilder.AppendLine("<head>");
            htmlBuilder.AppendLine("<meta charset=\"utf-8\" />");
            htmlBuilder.AppendLine("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />");
            htmlBuilder.AppendLine($"<title>{Path.GetFileNameWithoutExtension(request.FileName)}</title>");

            // CDN links para dependencias externas
            htmlBuilder.AppendLine("<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css\">");
            htmlBuilder.AppendLine("<link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css\" />");

            // Estilos CSS locales inline
            if (!string.IsNullOrWhiteSpace(siteCss))
            {
                htmlBuilder.AppendLine("<style>");
                htmlBuilder.AppendLine(siteCss);
                htmlBuilder.AppendLine("</style>");
            }

            if (!string.IsNullOrWhiteSpace(baseCss))
            {
                htmlBuilder.AppendLine("<style>");
                htmlBuilder.AppendLine(baseCss);
                htmlBuilder.AppendLine("</style>");
            }

            if (!string.IsNullOrWhiteSpace(reportCss))
            {
                htmlBuilder.AppendLine("<style>");
                htmlBuilder.AppendLine(reportCss);
                htmlBuilder.AppendLine("</style>");
            }

            // Reglas CSS específicas para optimizar la impresión en Puppeteer PDF
            htmlBuilder.AppendLine("<style>");
            htmlBuilder.AppendLine("html, body { background-color: #ffffff !important; margin: 0 !important; padding: 0 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }");
            htmlBuilder.AppendLine(".rpt-paper { border: none !important; box-shadow: none !important; margin: 0 !important; max-width: 100% !important; width: 100% !important; background-color: #ffffff !important; }");
            htmlBuilder.AppendLine(".no-print, header, footer { display: none !important; }");
            htmlBuilder.AppendLine("</style>");

            htmlBuilder.AppendLine("</head>");
            htmlBuilder.AppendLine("<body>");
            htmlBuilder.AppendLine("<div class=\"rpt-print-layer\">");
            htmlBuilder.AppendLine(processedHtml);
            htmlBuilder.AppendLine("</div>");
            htmlBuilder.AppendLine("</body>");
            htmlBuilder.AppendLine("</html>");

            var fullHtml = htmlBuilder.ToString();

            // 4. Generar PDF usando el servicio Puppeteer
            var pdfBytes = await _pdfGeneratorService.GeneratePdfFromHtmlAsync(fullHtml, cts.Token);

            // 5. Devolver archivo PDF para descarga directa
            return base.File(pdfBytes, "application/pdf", request.FileName);
        }
        catch (OperationCanceledException)
        {
            _logger.LogWarning("[PdfExportController] Timeout al generar PDF para {FileName}.", request.FileName);
            return StatusCode(504, "La generación del PDF excedió el tiempo límite (60 segundos).");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[PdfExportController] Error al generar PDF para {FileName}.", request.FileName);
            return StatusCode(500, "Error interno del servidor al compilar el PDF.");
        }
    }

    private async Task<string> GetLogoBase64Async()
    {
        var logoPath = Path.Combine(_env.WebRootPath, "images", "logoElecnor.png");
        if (!System.IO.File.Exists(logoPath))
        {
            _logger.LogWarning("[PdfExportController] Logo no encontrado en {Path}", logoPath);
            return "/images/logoElecnor.png";
        }

        try
        {
            var bytes = await System.IO.File.ReadAllBytesAsync(logoPath);
            return $"data:image/png;base64,{Convert.ToBase64String(bytes)}";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[PdfExportController] Error al leer logo de {Path}", logoPath);
            return "/images/logoElecnor.png";
        }
    }
}
