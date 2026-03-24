using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ActividadesController : ControllerBase
{
    private readonly InformeActividadesService _service;
    private readonly ILogger<ActividadesController> _logger;

    public ActividadesController(InformeActividadesService service, ILogger<ActividadesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "anio", "mes" })]
    public async Task<IActionResult> Get(int anio, int mes)
    {
        try
        {
            if (anio > DateTime.Now.Year)
                return BadRequest("El año de consulta no puede ser superior al año actual.");

            _logger.LogInformation("Solicitando informe Actividades para el periodo {Mes}/{Anio}", mes, anio);
            
            var result = await _service.ObtenerInformeAsync(anio, mes);
            
            if (result == null)
                return NotFound("No se encontraron resultados para el periodo seleccionado.");

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener informe Actividades para {Mes}/{Anio}", mes, anio);
            return StatusCode(500, "Error interno al procesar el informe.");
        }
    }
}
