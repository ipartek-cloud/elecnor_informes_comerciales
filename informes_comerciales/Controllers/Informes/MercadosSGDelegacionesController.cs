using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class MercadosSGDelegacionesController : ControllerBase
{
    private readonly InformeMercadosSGDelegacionesService _service;
    private readonly ILogger<MercadosSGDelegacionesController> _logger;

    public MercadosSGDelegacionesController(
        InformeMercadosSGDelegacionesService service,
        ILogger<MercadosSGDelegacionesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] int? nroPagina = null)
    {
        try
        {
            if (anio > DateTime.Now.Year)
                return BadRequest("El año de consulta no puede ser superior al año actual.");

            var result = await _service.ObtenerInformeAsync(anio, mes, nroPagina);

            if (result == null || result.SubDireccionesGenerales.Count == 0)
                return NotFound("No se encontraron resultados para el periodo seleccionado.");

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener informe Mercados SG Delegaciones para {Mes}/{Anio}", mes, anio);
            return StatusCode(500, "Error interno al procesar el informe.");
        }
    }
}
