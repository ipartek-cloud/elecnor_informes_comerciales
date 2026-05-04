using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;
using System.Threading.Tasks;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[ApiController]
[Route("api/ranking-contratacion-clientes")]
public class RankingContratacionClientesController : ControllerBase
{
    private readonly InformeRankingContratacionClientesService _service;

    public RankingContratacionClientesController(InformeRankingContratacionClientesService service)
    {
        _service = service;
    }

    [HttpGet]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<IActionResult> Get([FromQuery] string? mercado, [FromQuery] int? anio, [FromQuery] int? mes, [FromQuery] int? nroPagina)
    {
        if (anio == null || mes == null)
            return BadRequest("Año y Mes son obligatorios.");

        if (string.IsNullOrEmpty(mercado)) mercado = "Nacional";
        
        var response = await _service.ObtenerRankingAsync(mercado, anio.Value, mes.Value, nroPagina);
        return Ok(response);
    }
}
