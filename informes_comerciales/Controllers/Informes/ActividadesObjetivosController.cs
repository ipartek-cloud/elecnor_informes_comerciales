using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ActividadesObjetivosController : ControllerBase
{
    private readonly InformeActividadesObjetivosService _service;
    private readonly ILogger<ActividadesObjetivosController> _logger;

    public ActividadesObjetivosController(
        InformeActividadesObjetivosService service,
        ILogger<ActividadesObjetivosController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] int? nroPagina)
    {
        try
        {
            if (anio > DateTime.Now.Year)
                return BadRequest("El año de consulta no puede ser superior al año actual.");

            var result = await _service.ObtenerInformeAsync(anio, mes, nroPagina);

            if (result == null || result.Paises.Count == 0)
                return NotFound("No se encontraron resultados para el periodo seleccionado.");

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener informe Actividades_Objetivos para {Mes}/{Anio}", mes, anio);
            return StatusCode(500, "Error interno al procesar el informe.");
        }
    }
}
