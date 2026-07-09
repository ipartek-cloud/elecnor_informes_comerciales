using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// Controller API para el informe Gerencias (Resumen) Nacional - Internacional.
/// Expone GET /api/GerenciasNacionalInternacional.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class GerenciasNacionalInternacionalController : ControllerBase
{
    private readonly InformeGerenciasNacionalInternacionalService _service;
    private readonly ILogger<GerenciasNacionalInternacionalController> _logger;

    public GerenciasNacionalInternacionalController(
        InformeGerenciasNacionalInternacionalService service,
        ILogger<GerenciasNacionalInternacionalController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any,
        VaryByQueryKeys = new[] { "*" }, VaryByHeader = "Authorization")]
    public async Task<ActionResult<GerenciasNacionalInternacionalResponseDto>> Get(
        [FromQuery] int anio,
        [FromQuery] int mes,
        [FromQuery] int? nroPagina = null)
    {
        if (anio > DateTime.Now.Year)
        {
            _logger.LogWarning("Año futuro solicitado: {Anio}", anio);
            return BadRequest("El año de consulta no puede ser superior al año actual.");
        }

        if (anio < 2000)
            return BadRequest("El año de consulta debe ser posterior a 2000.");

        if (mes < 1 || mes > 12)
            return BadRequest("Mes inválido. Debe estar entre 1 y 12.");

        try
        {
            var loginUsuario = User.Identity?.Name ?? "ANONIMO";
            var datos = await _service.ObtenerInformeAsync(anio, mes, nroPagina, loginUsuario);
            return Ok(datos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener Gerencias N/I para {Anio}-{Mes}", anio, mes);
            return StatusCode(500, "Error interno al generar el informe.");
        }
    }
}
