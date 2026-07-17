using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CarteraContratacionDetallePaisesController : ControllerBase
{
    private readonly InformeCarteraContratacionDetallePaisesService _service;

    public CarteraContratacionDetallePaisesController(InformeCarteraContratacionDetallePaisesService service)
    {
        _service = service;
    }

    /// <summary>
    /// Obtiene el informe Cartera Contratación Países (Detalle) Nacional - Internacional.
    /// </summary>
    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" }, VaryByHeader = "Authorization")]
    public async Task<IActionResult> Get(
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] int? nroPagina,
        [FromQuery] decimal limiteImporte = 17000,
        [FromQuery] int limitePaises = 20,
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
