using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any)]
public class PaisesController : ControllerBase
{
    private readonly InformePaisesService _service;

    public PaisesController(InformePaisesService service)
    {
        _service = service;
    }

    /// <summary>
    /// Punto de entrada para el informe de Países (Mercado Internacional).
    /// Soporta dos modos de filtrado:
    /// - umbral = 0 (por defecto): Muestra todos los países con importe > 0 -> "Países (Mercado Internacional)"
    /// - umbral = 100000: Muestra solo países con importe >= 100000 (Relevantes) -> "Países Relevantes (Mercado Internacional)"
    /// </summary>
    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] int? nroPagina, [FromQuery] int umbral = 0)
    {
        // Validaciones básicas
        if (anio > DateTime.Now.Year + 1)
            return BadRequest("El año de consulta es excesivamente alto.");
        if (mes < 1 || mes > 12)
            return BadRequest("El mes debe estar entre 1 y 12.");

        // Ejecución de servicio (Método estandarizado)
        var resultado = await _service.ObtenerInformePaisesAsync(anio, mes, nroPagina, umbral);

        return Ok(resultado);
    }

    /// <summary>
    /// Punto de entrada para el informe de Países (Nacional + Internacional) - Todos los países.
    /// Título: "Países Relevantes". Umbral fijo: 100000 (relevantes).
    /// </summary>
    [HttpGet("paises_all")]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<IActionResult> GetPaisesAll([FromQuery] int anio, [FromQuery] int mes, [FromQuery] int? nroPagina)
    {
        // Validaciones básicas
        if (anio > DateTime.Now.Year + 1)
            return BadRequest("El año de consulta es excesivamente alto.");
        if (mes < 1 || mes > 12)
            return BadRequest("El mes debe estar entre 1 y 12.");

        // Ejecución de servicio (Método estandarizado)
        var resultado = await _service.ObtenerInformePaisesAllAsync(anio, mes, nroPagina);

        return Ok(resultado);
    }
}
