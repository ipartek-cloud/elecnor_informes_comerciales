using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ActividadesInternacionalDetalleController : ControllerBase
{
    private readonly InformeActividadesInternacionalDetalleService _service;
    private readonly ILogger<ActividadesInternacionalDetalleController> _logger;

    public ActividadesInternacionalDetalleController(
        InformeActividadesInternacionalDetalleService service,
        ILogger<ActividadesInternacionalDetalleController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "anio", "mes" }, VaryByHeader = "Authorization")]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes)
    {
        if (anio > DateTime.Now.Year)
        {
            return BadRequest("El año de consulta no puede ser superior al año actual.");
        }

        if (anio < 2000)
        {
            return BadRequest("El año de consulta debe ser posterior a 2000.");
        }

        if (mes < 1 || mes > 12)
        {
            return BadRequest("El mes debe estar entre 1 y 12.");
        }

        _logger.LogInformation(
            "Consultando Detalle Actividades Internacional - Año: {Anio}, Mes: {Mes}", 
            anio, mes);
        
        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        var resultado = await _service.ObtenerInformeAsync(anio, mes, loginUsuario);
        return Ok(resultado);
    }
}
