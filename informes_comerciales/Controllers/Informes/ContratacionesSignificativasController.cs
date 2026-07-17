using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "anio", "mes", "mercado", "codSubDirGeneral", "limiteImporte" }, VaryByHeader = "Authorization")]
public class ContratacionesSignificativasController : ControllerBase
{
    private readonly InformeContratacionesSignificativasService _service;
    private readonly ILogger<ContratacionesSignificativasController> _logger;

    public ContratacionesSignificativasController( InformeContratacionesSignificativasService service, ILogger<ContratacionesSignificativasController> logger)
    {
        _service = service;
        _logger  = logger;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] string mercado = "Nacional", [FromQuery] string codSubDirGeneral = "221", [FromQuery] decimal limiteImporte = 1000)
    {
        if (anio > DateTime.Now.Year)
            return BadRequest("El año de consulta no puede ser superior al año actual.");
        if (anio <= 0)
            return BadRequest("El año es obligatorio.");
        if (mes < 1 || mes > 12)
            return BadRequest("El mes debe estar entre 1 y 12.");

        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        var resultado = await _service.ObtenerInformeAsync(anio, mes, mercado, codSubDirGeneral, loginUsuario, limiteImporte);
        return Ok(resultado);
    }

    [HttpPost("generar")]
    public async Task<IActionResult> Generar([FromBody] GenerarContratacionesRequest request)
    {
        try
        {
            await _service.GenerarDatosSignificativosAsync(request.anio, request.mes);
            return Ok();
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Error al generar los datos significativos: {ex.Message}");
        }
    }
}
