using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class HtmlRptController : ControllerBase
{
    private readonly HtmlRptService _htmlApiService;
    private readonly ILogger<HtmlRptController> _logger;

    public HtmlRptController(HtmlRptService htmlApiService, ILogger<HtmlRptController> logger)
    {
        _htmlApiService = htmlApiService;
        _logger = logger;
    }

    [HttpGet("{tipoInforme}")]
    public async Task<IActionResult> DescargarHtml(
        [FromRoute] string tipoInforme,
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] string? meses = null,
        [FromQuery] Dictionary<string, string>? filtros = null)
    {
        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        _logger.LogInformation("[HtmlRptController] Petición de HTML Portable recibida vía API para: {Tipo}, Año: {Anio}, Mes: {Mes}, Meses: {Meses}, Usuario: {Usuario}, Filtros: {@Filtros}",
            tipoInforme, anio, mes, meses, loginUsuario, filtros);

        if (string.IsNullOrWhiteSpace(tipoInforme))
        {
            return BadRequest("El tipo de informe es obligatorio.");
        }

        try
        {
            var mesesSeleccionados = ParseMeses(meses, mes);
            var htmlContent = await _htmlApiService.GenerarHtmlAsync(tipoInforme, anio, mes, mesesSeleccionados, filtros, loginUsuario);

            if (string.IsNullOrWhiteSpace(htmlContent))
            {
                return NotFound("No se encontraron datos o no se pudo compilar el HTML Portable para el informe solicitado.");
            }

            var safeFileName = $"{tipoInforme}_{anio}_{mes:D2}".ToLowerInvariant();
            if (mesesSeleccionados.Count > 1 || meses != null)
            {
                var mesesAbrev = new[] { "Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic" };
                safeFileName += "_" + string.Join("_", mesesSeleccionados.Select(m => mesesAbrev[m - 1]));
            }
            safeFileName += ".html";

            var bytes = Encoding.UTF8.GetBytes(htmlContent);
            return File(bytes, "text/html; charset=utf-8", safeFileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[HtmlRptController] Error generando HTML Portable vía API para {Tipo}", tipoInforme);
            return StatusCode(500, "Error interno del servidor al procesar el archivo HTML Portable.");
        }
    }

    private static List<int> ParseMeses(string? meses, int mesDefault)
    {
        if (string.IsNullOrWhiteSpace(meses))
        {
            return new List<int> { mesDefault };
        }
        return meses.Split(',')
            .Select(s => int.TryParse(s.Trim(), out var m) ? m : -1)
            .Where(m => m >= 1 && m <= 12)
            .Distinct()
            .OrderBy(m => m)
            .ToList();
    }
}
