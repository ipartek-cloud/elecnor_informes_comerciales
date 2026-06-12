using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CarteraContratacionDetalleOrgPaisesController : ControllerBase
{
    private readonly InformeCarteraContratacionDetalleOrgPaisesService _service;

    public CarteraContratacionDetalleOrgPaisesController(InformeCarteraContratacionDetalleOrgPaisesService service)
    {
        _service = service;
    }

    /// <summary>
    /// Obtiene el informe Cartera Contratación DG (Detalle) por Organización de Países.
    /// </summary>
    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<IActionResult> Get(
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] int? nroPagina,
        [FromQuery] decimal limiteImporte = 13000,
        [FromQuery] int limitePaises = 20,
        [FromQuery] string mercado = "Todo",
        [FromQuery] string informe = "8.1",
        [FromQuery] string? codSubDirGeneral = "221")
    {
        if (anio > DateTime.Now.Year + 1)
            return BadRequest("El año de consulta es excesivamente alto.");
        if (mes < 1 || mes > 12)
            return BadRequest("El mes debe estar entre 1 y 12.");

        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        var resultado = await _service.ObtenerInformeAsync(
            anio, mes, nroPagina, limiteImporte, limitePaises, mercado, informe, codSubDirGeneral, loginUsuario);
        return Ok(resultado);
    }
}
