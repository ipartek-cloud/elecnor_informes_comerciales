using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.ContratacionesSignificativas;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any)]
public class ContratacionesSignificativasRiController : ControllerBase
{
    private readonly InformeContratacionesSignificativasRiService _service;
    private readonly ILogger<ContratacionesSignificativasRiController> _logger;

    public ContratacionesSignificativasRiController(InformeContratacionesSignificativasRiService service, ILogger<ContratacionesSignificativasRiController> logger)
    {
        _service = service;
        _logger  = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] string mercado = "Nacional", [FromQuery] string codSubDirGeneral = "221", [FromQuery] int? nroPagina = null, [FromQuery] decimal limiteImporte = 2000m)
    {
        if (anio > DateTime.Now.Year)
            return BadRequest("El año de consulta no puede ser superior al año actual.");
        if (anio <= 0)
            return BadRequest("El año es obligatorio.");
        if (mes < 1 || mes > 12)
            return BadRequest("El mes debe estar entre 1 y 12.");

        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        var resultado = await _service.ObtenerInformeAsync(anio, mes, mercado, codSubDirGeneral, nroPagina, loginUsuario, limiteImporte);
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
