using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// Controller API para el informe Cartera de Contratación (Resumen SDG).
/// Expone endpoint GET /api/CarteraContratacionResumenSDG con caché HTTP.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class CarteraContratacionResumenSDGController : ControllerBase
{
    private readonly InformeCarteraContratacionResumenSDGService _service;
    private readonly ILogger<CarteraContratacionResumenSDGController> _logger;

    public CarteraContratacionResumenSDGController(
        InformeCarteraContratacionResumenSDGService service,
        ILogger<CarteraContratacionResumenSDGController> logger)
    {
        _service = service;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene el informe de Cartera de Contratación (Resumen SDG) para un año, mes y mercado dados.
    /// </summary>
    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" }, VaryByHeader = "Authorization")]
    public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] string mercado = "Todo")
    {
        if (anio > DateTime.Now.Year)
        {
            _logger.LogWarning("Intento de consulta con año futuro: {Anio}", anio);
            return BadRequest("El año de consulta no puede ser superior al año actual.");
        }

        if (mes < 1 || mes > 12)
        {
            return BadRequest("Mes inválido. Debe estar entre 1 y 12.");
        }

        int todoInt = mercado.Equals("Todo", StringComparison.OrdinalIgnoreCase) ? 1 : 0;

        try
        {
            var loginUsuario = User.Identity?.Name ?? "ANONIMO";
            var datos = await _service.ObtenerInformeAsync(anio, mes, todoInt, loginUsuario);
            return Ok(datos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener informe CarteraContratacionResumenSDG para {Anio}-{Mes}", anio, mes);
            return StatusCode(500, "Error interno al generar el informe.");
        }
    }
}
