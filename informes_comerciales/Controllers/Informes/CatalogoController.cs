using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// Endpoints para catálogos y datos auxiliares.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any)]
public class CatalogoController : ControllerBase
{
    private readonly CatalogoService _service;

    public CatalogoController(CatalogoService service)
    {
        _service = service;
    }

    /// <summary>
    /// Obtiene las SubDirecciones Generales para cargar combos.
    /// </summary>
    [HttpGet("subdirecciones")]
    public async Task<IActionResult> GetSubDirecciones()
    {
        var resultado = await _service.ObtenerSubDireccionesAsync();
        return Ok(resultado);
    }
}
