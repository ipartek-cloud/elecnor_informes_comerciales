using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// API REST para obtener de forma directa y programática los DATOS crudos de los informes
/// comerciales en formato JSON (sin ensamblado HTML ni renderizado PDF).
/// Mantiene la misma seguridad que el resto de APIs de informes (JWT + puesto de trabajo).
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class JsonRptController : ControllerBase
{
    private readonly JsonRptService _jsonRptService;
    private readonly ILogger<JsonRptController> _logger;

    public JsonRptController(JsonRptService jsonRptService, ILogger<JsonRptController> logger)
    {
        _jsonRptService = jsonRptService;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene los datos de un informe comercial específico en formato JSON.
    /// </summary>
    /// <param name="tipoInforme">Nombre clave del informe (ej: 'actividades', 'mercados').</param>
    /// <param name="anio">Año de consulta.</param>
    /// <param name="mes">Mes de consulta (obligatorio si no se indica 'meses').</param>
    /// <param name="meses">Lista opcional de meses separados por coma (ej: '1,3,4') para respuesta multi-mes.</param>
    /// <param name="filtros">Filtros dinámicos adicionales (limiteImporte, mercado, etc.).</param>
    [HttpGet("{tipoInforme}")]
    public async Task<IActionResult> ObtenerJson(
        [FromRoute] string tipoInforme,
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] string? meses = null,
        [FromQuery] Dictionary<string, string>? filtros = null)
    {
        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        _logger.LogInformation("[JsonRptController] Petición de datos JSON recibida vía API para: {Tipo}, Año: {Anio}, Mes: {Mes}, Meses: {Meses}, Usuario: {Usuario}, Filtros: {@Filtros}",
            tipoInforme, anio, mes, meses, loginUsuario, filtros);

        if (string.IsNullOrWhiteSpace(tipoInforme))
        {
            return BadRequest("El tipo de informe es obligatorio.");
        }

        if (anio > DateTime.Now.Year)
        {
            return BadRequest("El año de consulta no puede ser superior al año actual.");
        }

        if (anio < 2000)
        {
            return BadRequest("El año de consulta debe ser posterior a 2000.");
        }

        // NOTA: El middleware de seguridad global (InformeSeguridadMiddleware) ya valida
        // que el puesto del usuario tenga permisos sobre el informe consultado.
        if (!InformePortableService.EsTipoSoportado(tipoInforme))
        {
            return NotFound($"El tipo de informe '{tipoInforme}' no está soportado.");
        }

        var mesesSeleccionados = ParseMeses(meses);

        try
        {
            if (mesesSeleccionados != null)
            {
                // ── Modo multi-mes ──
                if (mesesSeleccionados.Count == 0)
                {
                    return BadRequest("El parámetro 'meses' no contiene ningún mes válido (valores entre 1 y 12).");
                }

                var respuestaMulti = await _jsonRptService.GenerarJsonMultiMesAsync(
                    tipoInforme, anio, mesesSeleccionados, filtros, loginUsuario);

                if (respuestaMulti == null)
                {
                    return NotFound("No se encontraron datos para el informe solicitado en ninguno de los meses indicados.");
                }

                return Ok(respuestaMulti);
            }

            // ── Modo un solo mes ──
            if (mes < 1 || mes > 12)
            {
                return BadRequest("Mes inválido. Debe estar entre 1 y 12.");
            }

            var respuesta = await _jsonRptService.GenerarJsonAsync(tipoInforme, anio, mes, filtros, loginUsuario);

            if (respuesta == null)
            {
                return NotFound("No se encontraron datos para el informe solicitado.");
            }

            return Ok(respuesta);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[JsonRptController] Error obteniendo datos JSON vía API para {Tipo}", tipoInforme);
            return StatusCode(500, "Error interno del servidor al procesar los datos del informe.");
        }
    }

    /// <summary>
    /// Parsea el parámetro 'meses' (CSV). Devuelve null si no se proporcionó (modo un solo mes).
    /// </summary>
    private static List<int>? ParseMeses(string? meses)
    {
        if (string.IsNullOrWhiteSpace(meses))
        {
            return null;
        }
        return meses.Split(',')
            .Select(s => int.TryParse(s.Trim(), out var m) ? m : -1)
            .Where(m => m >= 1 && m <= 12)
            .Distinct()
            .OrderBy(m => m)
            .ToList();
    }
}
