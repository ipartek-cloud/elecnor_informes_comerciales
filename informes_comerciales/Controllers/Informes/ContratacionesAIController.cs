using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// API Controller para el informe de ContratacionesAI (Asociadas a Inversión).
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "anio", "mes", "umbral1", "umbral2" })]
public class ContratacionesAIController : ControllerBase
{
    private readonly InformeContratacionesAIService _service;

    public ContratacionesAIController(InformeContratacionesAIService service)
    {
        _service = service;
    }

    /// <summary>
    /// Obtiene el informe completo de Contrataciones AI.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Get(int anio, int mes, [FromQuery] decimal? umbral1 = null, [FromQuery] decimal? umbral2 = null)
    {
        if (anio > DateTime.Now.Year)
            return BadRequest("El año de consulta no puede ser superior al año actual.");

        var loginUsuario = User.Identity?.Name ?? "ANONIMO";
        var result = await _service.ObtenerInformeCompletoAsync(anio, mes, loginUsuario, umbral1, umbral2);
        return Ok(result);
    }

    /// <summary>
    /// Genera los datos de Contrataciones AI ejecutando el SP en el servidor.
    /// </summary>
    [HttpPost("generar")]
    public async Task<IActionResult> Generar([FromBody] GenerarContratacionesAIRequest request)
    {
        try
        {
            await _service.GenerarDatosAIAsync(request.anio, request.mes);
            return Ok(new { success = true, message = "Datos AI generados correctamente." });
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Error al generar los datos AI: {ex.Message}");
        }
    }
}

public class GenerarContratacionesAIRequest
{
    public int anio { get; set; }
    public int mes { get; set; }
}
