using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class CD_Elecnor_DG_Centros_DGRI_NuevoController : ControllerBase
{
    private readonly CD_Elecnor_DG_Centros_DGRI_NuevoService _service;
    private readonly ILogger<CD_Elecnor_DG_Centros_DGRI_NuevoController> _logger;

    public CD_Elecnor_DG_Centros_DGRI_NuevoController(
        CD_Elecnor_DG_Centros_DGRI_NuevoService service,
        ILogger<CD_Elecnor_DG_Centros_DGRI_NuevoController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" }, VaryByHeader = "Authorization")]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] int? nroPagina = null, [FromQuery] string? codSubDirGeneral = null)
    {
        try
        {
            if (anio > DateTime.Now.Year)
                return BadRequest("El año de consulta no puede ser superior al año actual.");

            var loginUsuario = User.Identity?.Name ?? "ANONIMO";
            var result = await _service.ObtenerInformeAsync(anio, mes, nroPagina, loginUsuario, codSubDirGeneral);

            if (result == null || result.SubDireccionesGenerales.Count == 0)
                return NotFound("No se encontraron resultados para el periodo seleccionado.");

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener informe CD_Elecnor_DG_Centros_DGRI_Nuevo para {Mes}/{Anio}", mes, anio);
            return StatusCode(500, "Error interno al procesar el informe.");
        }
    }
}
