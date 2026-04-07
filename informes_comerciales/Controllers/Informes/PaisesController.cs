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
    /// - umbral = 0 (por defecto): Muestra todos los países con importe > 0
    /// - umbral = 100000: Muestra solo países con importe >= 100000 (Relevantes)
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Get(int anio, int mes, int? nroPagina, int umbral = 0)
    {
        // Validaciones básicas
        if (anio > DateTime.Now.Year + 1) // Permitimos un poco de margen a futuro
            return BadRequest("El año de consulta es excesivamente alto.");
        if (mes < 1 || mes > 12)
            return BadRequest("El mes debe estar entre 1 y 12.");

        // Ejecución de servicio
        var resultado = await _service.ObtenerInformeAsync(anio, mes, nroPagina, umbral);

        return Ok(resultado);
    }
}
