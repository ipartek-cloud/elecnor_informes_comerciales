using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.Models.Informes.GerenciasTotalesCruces;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class GerenciasTotalesCrucesController : ControllerBase
{
    private readonly InformeGerenciasTotalesCrucesService _service;
    private readonly ILogger<GerenciasTotalesCrucesController> _logger;

    public GerenciasTotalesCrucesController(
        InformeGerenciasTotalesCrucesService service,
        ILogger<GerenciasTotalesCrucesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByHeader = "Authorization")]
    public async Task<IActionResult> Get(
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] string? codSubDirGeneral = "221",
        [FromQuery] int? nroPagina = null)
    {
        if (anio > DateTime.Now.Year)
            return BadRequest("El año de consulta no puede ser superior al año actual.");
        if (anio < 2000)
            return BadRequest("El año de consulta debe ser posterior a 2000.");
        if (mes < 1 || mes > 12)
            return BadRequest("Mes inválido. Debe estar entre 1 y 12.");

        try
        {
            var loginUsuario = User.Identity?.Name ?? "ANONIMO";
            var result = await _service.ObtenerInformeAsync(
                anio, mes, nroPagina, loginUsuario, codSubDirGeneral);

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener informe Gerencias Totales Cruces para {Anio}-{Mes} SDG={CodSubDirGeneral}",
                anio, mes, codSubDirGeneral);
            return StatusCode(500, "Error interno al procesar el informe.");
        }
    }
}
