using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

/// <summary>
/// Controller API para el informe de Gerencias.
/// Expone endpoint GET /api/Gerencias con caché HTTP.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class GerenciasController : ControllerBase
{
    private readonly InformeGerenciasService _informeGerenciasService;
    private readonly ILogger<GerenciasController> _logger;

    public GerenciasController(InformeGerenciasService informeGerenciasService, ILogger<GerenciasController> logger)
    {
        _informeGerenciasService = informeGerenciasService;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene el informe de Gerencias para un año y mes dados.
    /// </summary>
    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<ActionResult<GerenciasResponseDto>> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] int? nroPagina)
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

        try
        {
            var datos = await _informeGerenciasService.ObtenerInformeGerenciasAsync(anio, mes, nroPagina);
            return Ok(datos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener informe de Gerencias para {Anio}-{Mes}", anio, mes);
            return StatusCode(500, "Error interno al generar el informe de Gerencias.");
        }
    }
}
