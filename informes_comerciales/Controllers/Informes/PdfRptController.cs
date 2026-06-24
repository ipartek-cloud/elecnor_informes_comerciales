using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// API REST para descargar de forma directa y programática los informes en formato PDF.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class PdfRptController : ControllerBase
{
    private readonly PdfRptService _pdfApiService;
    private readonly ILogger<PdfRptController> _logger;

    public PdfRptController(PdfRptService pdfApiService, ILogger<PdfRptController> logger)
    {
        _pdfApiService = pdfApiService;
        _logger = logger;
    }

    /// <summary>
    /// Descarga directa del PDF de un informe comercial específico.
    /// </summary>
    /// <param name="tipoInforme">Nombre clave del informe (ej: 'actividades', 'mercados').</param>
    /// <param name="anio">Año de consulta.</param>
    /// <param name="mes">Mes de consulta.</param>
    /// <param name="filtros">Filtros dinámicos adicionales (limiteImporte, mercado, etc.).</param>
    [HttpGet("{tipoInforme}")]
    public async Task<IActionResult> DescargarPdf(
        [FromRoute] string tipoInforme,
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] Dictionary<string, string>? filtros = null)
    {
        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        _logger.LogInformation("[PdfRptController] Petición de PDF recibida vía API para: {Tipo}, Año: {Anio}, Mes: {Mes}, Usuario: {Usuario}, Filtros: {@Filtros}",
            tipoInforme, anio, mes, loginUsuario, filtros);

        if (string.IsNullOrWhiteSpace(tipoInforme))
        {
            return BadRequest("El tipo de informe es obligatorio.");
        }

        try
        {
            // NOTA: El middleware de seguridad global (InformeSeguridadMiddleware) ya valida
            // que el puesto del usuario tenga permisos sobre el informe consultado.
            
            var pdfBytes = await _pdfApiService.GenerarPdfAsync(tipoInforme, anio, mes, filtros, loginUsuario);

            if (pdfBytes == null || pdfBytes.Length == 0)
            {
                return NotFound("No se encontraron datos o no se pudo compilar el PDF para el informe solicitado.");
            }

            var safeFileName = $"{tipoInforme}_{anio}_{mes:D2}.pdf";
            return File(pdfBytes, "application/pdf", safeFileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[PdfRptController] Error generando PDF vía API para {Tipo}", tipoInforme);
            return StatusCode(500, "Error interno del servidor al procesar el archivo PDF.");
        }
    }
}
