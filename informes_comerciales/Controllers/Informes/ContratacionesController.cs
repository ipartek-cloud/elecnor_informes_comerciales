using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "anio", "mes" })]
public class ContratacionesController : ControllerBase
{
    private readonly InformeContratacionesService _service;

    public ContratacionesController(InformeContratacionesService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetInformeCompleto(int anio, int mes)
    {
        if (anio > DateTime.Now.Year)
            return BadRequest("El año de consulta no puede ser superior al año actual.");

        var result = await _service.ObtenerInformeCompletoAsync(anio, mes);
        return Ok(result);
    }

    [HttpPost("generarcontratacionobras")]
    public async Task<IActionResult> GenerarContratacionObras([FromBody] GenerarContratacionesRequest request)
    {
        try
        {
            await _service.GenerarDatosAsync(request.anio, request.mes);
            return Ok();
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Error al generar los datos: {ex.Message}");
        }
    }
}

public class GenerarContratacionesRequest
{
    public int anio { get; set; }
    public int mes { get; set; }
}
