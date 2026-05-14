using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text;
using Elecnor_Informes_Comerciales.DTOs.Informes;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// Controlador para la generación y descarga de Informes HTML Portables (Self-Contained).
/// Proporciona un único endpoint que recibe los parámetros del informe y los filtros data-*, y devuelve un archivo .html descargable.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class InformePortableController : ControllerBase
{
    private readonly InformePortableService _informePortableService;
    private readonly ILogger<InformePortableController> _logger;

    public InformePortableController(
        InformePortableService informePortableService,
        ILogger<InformePortableController> logger)
    {
        _informePortableService = informePortableService;
        _logger = logger;
    }

    /// <summary>
    /// Genera y descarga un Informe HTML Portable auto-contenido.
    /// </summary>
    /// <param name="tipoInforme">Identificador del tipo de informe (ej: 'mercados', 'paises').</param>
    /// <param name="anio">Año de consulta.</param>
    /// <param name="mes">Mes hasta el cual se acumulan los datos.</param>
    /// <param name="filtros">Diccionario dinámico de filtros data-* del botón.</param>
    /// <returns>Archivo HTML listo para descargar y usar offline.</returns>
    [HttpGet("{tipoInforme}")]
    public async Task<IActionResult> Get(
        [FromRoute] string tipoInforme,
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] string? meses = null,
        [FromQuery] string? label = null,
        [FromQuery] Dictionary<string, string>? filtros = null)
    {
        _logger.LogInformation("[InformePortableController] Solicitud recibida: Tipo={Tipo}, Año={Anio}, Mes={Mes}, Meses={Meses}, Filtros={@Filtros}", tipoInforme, anio, mes, meses, filtros);

        if (string.IsNullOrWhiteSpace(tipoInforme))
        {
            return BadRequest("El tipo de informe es obligatorio.");
        }

        try
        {
            var mesesSeleccionados = ParseMeses(meses);

            var htmlContent = await _informePortableService.GenerarInformePortableAsync(tipoInforme, anio, mes, mesesSeleccionados, filtros);

            if (string.IsNullOrWhiteSpace(htmlContent))
            {
                _logger.LogWarning("[InformePortableController] El servicio devolvió HTML vacío para {Tipo}.", tipoInforme);
                return StatusCode(500, "No se pudo generar el informe portable.");
            }

            // Sanitizar nombre de archivo
            var safeName = NormalizarNombreArchivo(!string.IsNullOrWhiteSpace(label) ? label : tipoInforme);
            var sufijoMeses = mesesSeleccionados != null && mesesSeleccionados.Count > 0
                ? "_" + string.Join("_", mesesSeleccionados.Select(m => _mesesAbrev[m - 1]))
                : "";
            var fileName = $"{safeName}{sufijoMeses}.html";

            var bytes = Encoding.UTF8.GetBytes(htmlContent);

            return File(bytes, "text/html; charset=utf-8", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[InformePortableController] Error generando informe portable para {Tipo}.", tipoInforme);
            return StatusCode(500, "Error interno del servidor al generar el informe portable.");
        }
    }

    private static readonly string[] _mesesAbrev = ["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"];

    private static List<int>? ParseMeses(string? meses)
    {
        if (string.IsNullOrWhiteSpace(meses)) return null;
        return meses.Split(',')
            .Select(s => int.TryParse(s.Trim(), out var m) ? m : -1)
            .Where(m => m >= 1 && m <= 12)
            .Distinct()
            .OrderBy(m => m)
            .ToList();
    }

    private static string NormalizarNombreArchivo(string nombre)
    {
        var chars = nombre.Normalize(System.Text.NormalizationForm.FormD)
            .Where(c => System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c) != System.Globalization.UnicodeCategory.NonSpacingMark)
            .ToArray();
        var sinAcentos = new string(chars);
        return string.Join("_", sinAcentos.Split(Path.GetInvalidFileNameChars()));
    }
}
