using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.Models.Informes.GerenciasActividad;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// API REST del informe "Gerencias Actividad" (Gerente × Mercado × DN × Centro).
/// Benchmark: GerenciasTotalesCrucesController.cs.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class GerenciasActividadController : ControllerBase
{
    private readonly InformeGerenciasActividadService _service;
    private readonly ILogger<GerenciasActividadController> _logger;

    public GerenciasActividadController(
        InformeGerenciasActividadService service,
        ILogger<GerenciasActividadController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByHeader = "Authorization")]
    public async Task<IActionResult> Get(
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] string nombreGerente,
        [FromQuery] int? nroPagina = null)
    {
        if (anio > DateTime.Now.Year)
            return BadRequest("El año de consulta no puede ser superior al año actual.");
        if (anio < 2000)
            return BadRequest("El año de consulta debe ser posterior a 2000.");
        if (mes < 1 || mes > 12)
            return BadRequest("Mes inválido. Debe estar entre 1 y 12.");
        if (string.IsNullOrWhiteSpace(nombreGerente))
            return BadRequest("El parámetro nombreGerente es obligatorio.");
        if (nombreGerente.Length > 255)
            return BadRequest("El parámetro nombreGerente excede la longitud máxima permitida.");

        try
        {
            var loginUsuario = User.Identity?.Name ?? "ANONIMO";
            var result = await _service.ObtenerInformeAsync(
                anio, mes, nroPagina, loginUsuario, nombreGerente);

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Error al obtener informe Gerencias Actividad para {Anio}-{Mes} Gerente={NombreGerente}",
                anio, mes, nombreGerente);
            return StatusCode(500, "Error interno al procesar el informe.");
        }
    }
}
