using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Models.Informes.Gerencias_Totales_Cruces;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// Endpoint para el informe de Gerencias Totales Cruces.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any)]
public class GerenciasTotalesCrucesController : ControllerBase
{
    private readonly InformeGerenciasTotalesCrucesService _service;

    public GerenciasTotalesCrucesController(InformeGerenciasTotalesCrucesService service)
    {
        _service = service;
    }

    /// <summary>
    /// Obtiene el informe estructurado por jerarquías para ser renderizado en el frontend.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes)
    {
        if (anio > DateTime.Now.Year) return BadRequest("El año de consulta no puede ser superior al año actual.");
        if (mes < 1 || mes > 12) return BadRequest("Mes inválido.");

        var resultado = await _service.ObtenerInformeAsync(anio, mes);
        return Ok(resultado);
    }
}
