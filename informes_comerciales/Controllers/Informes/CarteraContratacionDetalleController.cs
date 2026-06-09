using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByHeader = "Authorization")]
public class CarteraContratacionDetalleController : ControllerBase
{
    private readonly InformeCarteraContratacionDetalleService _service;

    public CarteraContratacionDetalleController(InformeCarteraContratacionDetalleService service)
    {
        _service = service;
    }

    /// <summary>
    /// Obtiene el informe de Cartera Contratación (Detalle) Nacional - Internacional.
    /// </summary>
    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" }, VaryByHeader = "Authorization")]
    public async Task<IActionResult> Get(
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] int? nroPagina,
        [FromQuery] decimal limiteImporte = 13000,
        [FromQuery] int limitePaises = 1000,
        [FromQuery] string mercado = "Todo",
        [FromQuery] string informe = "9.1")
    {
        if (anio > DateTime.Now.Year + 1)
            return BadRequest("El año de consulta es excesivamente alto.");
        if (mes < 1 || mes > 12)
            return BadRequest("El mes debe estar entre 1 y 12.");

        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        var resultado = await _service.ObtenerInformeAsync(anio, mes, nroPagina, limiteImporte, limitePaises, mercado, informe, loginUsuario);
        return Ok(resultado);
    }
}
